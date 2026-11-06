import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kahwa/features/me/security_screen.dart';
import 'package:kahwa/core/money.dart';
import 'package:kahwa/core/text.dart';
import 'package:kahwa/models/money_requests.dart';
import 'package:kahwa/state/providers.dart';
import 'package:kahwa/theme/app_theme.dart';
import 'package:kahwa/ui/context.dart';
import 'package:kahwa/ui/whish_pay.dart';
import 'package:kahwa/ui/widgets.dart';

final _destinationProvider = FutureProvider.autoDispose<TopUpDestination>(
  (ref) => ref.watch(walletRepositoryProvider).topUpDestination(),
);

/// Adding money to the balance. The user picks an amount, pays it through
/// the founder's Whish Me link, and only then confirms here. An admin
/// checks the transfer and the balance goes up once it is found.
/// Where the top up was opened from, passed as the route's extra.
enum TopUpOpenedFrom { support }

class TopUpScreen extends ConsumerStatefulWidget {
  const TopUpScreen({
    super.key,
    this.amount,
    this.currency,
    this.fromSupport = false,
  });

  /// Opened while buying a kahwa that the balance did not cover. Once the
  /// request is sent, this screen closes with true.
  final bool fromSupport;

  /// What to fill in, when the user came to top up a missing amount.
  final int? amount;
  final Currency? currency;

  @override
  ConsumerState<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends ConsumerState<TopUpScreen> {
  late final _amount = TextEditingController(
    text: widget.amount == null ? '' : groupDigits(widget.amount!),
  );
  final _phone = TextEditingController();
  late Currency _currency = widget.currency ?? Currency.lbp;
  String? _amountError;
  String? _phoneError;

  /// Set once the user picked an amount and is shown where to send it.
  bool _paying = false;
  bool _phoneFilled = false;

  @override
  void dispose() {
    _amount.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final l10n = context.l10n;
    final amount = parseAmount(_amount.text);
    if (amount != null &&
        amount > 0 &&
        !await requireVerifiedEmail(context, ref)) {
      return;
    }
    if (!mounted) return;
    setState(() {
      _amountError = amount == null || amount < 1 ? l10n.amountInvalid : null;
      _paying = _amountError == null;
    });
  }

  Future<void> _confirm() async {
    final l10n = context.l10n;
    final id = ref.read(userIdProvider);
    final phone = _phone.text.trim();
    if (id == null) return;
    if (phone.isEmpty || !isPhoneNumber(phone)) {
      setState(
        () => _phoneError = phone.isEmpty
            ? l10n.senderPhoneMissing
            : l10n.phoneInvalid,
      );
      return;
    }
    setState(() => _phoneError = null);
    try {
      await ref
          .read(walletRepositoryProvider)
          .requestTopUp(
            userId: id,
            amount: parseAmount(_amount.text)!,
            currency: _currency,
            senderPhone: phone,
          );
      refreshMyData(ref.invalidate);
      if (!mounted) return;
      if (widget.fromSupport) {
        context.pop(true);
        return;
      }
      setState(() => _paying = false);
    } catch (_) {
      if (mounted) showSnack(context, l10n.somethingWrong);
    }
  }

  Future<void> _cancel() async {
    final id = ref.read(userIdProvider);
    if (id == null) return;
    try {
      await ref.read(walletRepositoryProvider).cancelTopUp(id);
      refreshMyData(ref.invalidate);
    } catch (_) {
      if (mounted) showSnack(context, context.l10n.somethingWrong);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final destination = ref.watch(_destinationProvider);
    final request = ref.watch(myTopUpProvider);
    final last = request.valueOrNull;
    if (!_phoneFilled && request.hasValue) {
      _phoneFilled = true;
      // Starts with the number of the last top up.
      _phone.text = last?.senderPhone ?? '';
    }

    return TitledPage(
      title: l10n.topUp,
      subtitle: l10n.topUpSubtitle,
      children: [
        AsyncView(
          value: destination,
          onRetry: () => ref.invalidate(_destinationProvider),
          builder: (d) {
            if (!d.isSet) {
              return Notice(tone: Tone.warning, message: l10n.topUpUnavailable);
            }
            if (!d.currencies.contains(_currency)) {
              _currency = d.currencies.first;
            }
            if (last != null && last.isPending) return _pending(last);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (last != null && last.hasRecentResult(DateTime.now())) ...[
                  Notice(
                    tone: last.status.isOk ? Tone.success : Tone.danger,
                    title: l10n.lastTopUp,
                    message: [
                      last.status.isOk
                          ? l10n.topUpAdded(
                              context.money(last.amount, last.currency),
                            )
                          : l10n.topUpNotFound(
                              context.money(last.amount, last.currency),
                            ),
                      dateTime(context, last.resolvedAt),
                    ].join('\n'),
                  ),
                  const SizedBox(height: 20),
                ],
                if (_paying) ..._pay(d, last) else ..._choose(d),
              ],
            );
          },
        ),
      ],
    );
  }

  List<Widget> _choose(TopUpDestination d) {
    final l10n = context.l10n;
    return [
      FieldLabel(
        l10n.amount,
        child: AmountField(
          controller: _amount,
          currency: _currency,
          autofocus: widget.amount == null,
          style: context.text.headlineSmall,
          errorText: _amountError,
          onSubmitted: (_) => _continue(),
        ),
      ),
      if (d.currencies.length > 1)
        FieldLabel(
          l10n.currency,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: CurrencyToggle(
              value: _currency,
              options: d.currencies,
              onChanged: (c) => setState(() => _currency = c),
            ),
          ),
        ),
      const SizedBox(height: 8),
      FilledButton(onPressed: _continue, child: Text(l10n.continueAction)),
    ];
  }

  List<Widget> _pay(TopUpDestination d, TopUpRequest? last) {
    final l10n = context.l10n;
    final amount = context.money(parseAmount(_amount.text) ?? 0, _currency);
    return [
      // WHISH refuses a code from a balance in another currency.
      Text(
        l10n.sendWith(amount, _currency.sign(arabic: context.isArabic)),
        style: context.text.titleMedium,
      ),
      const SizedBox(height: 16),
      // WHISH shows the sender a person's name, which nobody expects to see
      // when paying an app. The name itself is never shown here.
      Notice(message: l10n.payingFounder, icon: Icons.verified_user_rounded),
      const SizedBox(height: 20),
      WhishPayBox(code: d.whishQr[_currency]!),
      const SizedBox(height: 24),
      FieldLabel(
        l10n.senderPhone,
        hint: last == null || last.senderPhone.isEmpty
            ? l10n.senderPhoneHint
            : l10n.senderPhoneCheck,
        child: TextField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: '70 123 456',
            errorText: _phoneError,
            prefixIcon: const Icon(Icons.phone_rounded),
          ),
        ),
      ),
      BusyButton(label: l10n.iSentTheMoney, onPressed: _confirm),
      const SizedBox(height: 10),
      OutlinedButton(
        onPressed: () => setState(() => _paying = false),
        child: Text(l10n.back),
      ),
    ];
  }

  Widget _pending(TopUpRequest request) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Notice(
          tone: Tone.warning,
          title: l10n.topUpCheckingTitle,
          message: l10n.topUpChecking(
            context.money(request.amount, request.currency),
          ),
        ),
        const SizedBox(height: 16),
        BusyButton(
          label: l10n.cancelRequest,
          outlined: true,
          onPressed: _cancel,
        ),
      ],
    );
  }
}
