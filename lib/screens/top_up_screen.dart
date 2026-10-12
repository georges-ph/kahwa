import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kahwa/core/colors.dart';
import 'package:kahwa/core/feedback.dart';
import 'package:kahwa/core/formatters.dart';
import 'package:kahwa/core/router.dart';
import 'package:kahwa/data/repositories.dart';
import 'package:kahwa/models/currency.dart';
import 'package:kahwa/models/top_up_destination.dart';
import 'package:kahwa/models/top_up_request.dart';
import 'package:kahwa/widgets/async_body.dart';
import 'package:kahwa/widgets/input_text.dart';
import 'package:kahwa/widgets/loading_button.dart';
import 'package:kahwa/widgets/page_body.dart';
import 'package:kahwa/widgets/sub_page.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/link.dart';

/// Adding money to the balance. The user picks an amount, pays it through
/// the admin's Whish Me link, and only then confirms here. An admin checks the transfer and
/// the balance goes up once it is found.
class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  late Future<(TopUpDestination, TopUpRequest?)> _data;

  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();

  Currency _currency = Currency.lbp;
  String? _amountError;
  String? _phoneError;
  bool _isLoading = false;

  /// Set once the user has picked an amount and is shown where to send it.
  String? _reference;

  String get _userId => authRepository.userId;

  @override
  void initState() {
    super.initState();
    _data = _load();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<(TopUpDestination, TopUpRequest?)> _load() async {
    final data = await (
      balanceRepository.getTopUpDestination(),
      balanceRepository.getTopUpRequest(_userId),
    ).wait;

    // Only the currencies that have a code can be picked.
    final currencies = data.$1.currencies;
    if (currencies.isNotEmpty && !currencies.contains(_currency)) {
      _currency = currencies.first;
    }

    // Most people always send from the same number, so the field starts
    // with the one of their last top up. It can still be changed.
    if (_phoneController.text.isEmpty) {
      _phoneController.text = data.$2?.senderPhone ?? '';
    }
    return data;
  }

  void _reload() => setState(() => _data = _load());

  void _continue() {
    final amount = parseAmount(_amountController.text) ?? 0;
    setState(() {
      _amountError = amount < 1 ? 'Enter an amount above 0' : null;
      if (_amountError == null) _reference = TopUpRequest.newReference();
    });
  }

  Future<void> _confirm() async {
    final phone = _phoneController.text.trim();
    setState(() {
      _phoneError = phone.length < 6
          ? 'Enter the number you sent the money from'
          : null;
    });
    if (_phoneError != null) return;

    await _run(() {
      return balanceRepository.requestTopUp(
        TopUpRequest(
          userId: _userId,
          amount: parseAmount(_amountController.text) ?? 0,
          currency: _currency,
          reference: _reference!,
          senderPhone: phone,
        ),
      );
    });
  }

  Future<void> _cancel() => _run(() => balanceRepository.cancelTopUp(_userId));

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _isLoading = true);
    try {
      await action();
      if (!mounted) return;
      _reference = null;
      _reload();
    } catch (_) {
      if (mounted) showSnack(context, 'Something went wrong, try again');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SubPage(
      fallback: Routes.balance,
      body: AsyncBody(
        future: _data,
        onRetry: _reload,
        builder: (context, data) {
          final (destination, request) = data;
          return PageBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const PageTitle('Top up'),
                const SizedBox(height: 40),
                if (!destination.isSet)
                  const Text('Top ups are not available right now.')
                else if (request?.status == TopUpStatus.pending)
                  ..._buildPending(request!)
                else if (_reference != null)
                  ..._buildTransfer(destination, request)
                else
                  ..._buildAmount(destination, request),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildAmount(TopUpDestination destination, TopUpRequest? last) {
    final currencies = destination.currencies;
    // What an admin answered to the last request, shown for a few days.
    final answered = last != null && last.hasRecentResult(DateTime.now())
        ? last
        : null;

    return [
      if (answered?.status == TopUpStatus.approved)
        _Notice(
          title: 'Your last top up',
          '${answered!.currency.format(answered.amount)} was added to your '
          'balance.',
        )
      else if (answered?.status == TopUpStatus.rejected)
        _Notice(
          title: 'Your last top up',
          'We could not find your transfer of '
          '${answered!.currency.format(answered.amount)}. Nothing was added '
          'to your balance. If you did send it, try again with the same '
          'details.',
        ),
      const Text(
        'Your balance is what you buy kahwas with. You add to it by sending '
        'money with WHISH MONEY.',
      ),
      const SizedBox(height: 24),
      InputText(
        controller: _amountController,
        title: 'Amount',
        hint: '0',
        prefixText: _currency.code,
        errorText: _amountError,
        digitsOnly: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _continue(),
      ),
      if (currencies.length > 1) ...[
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: [
            for (final currency in currencies)
              ChoiceChip(
                label: Text(currency.code),
                selected: _currency == currency,
                onSelected: (_) => setState(() => _currency = currency),
              ),
          ],
        ),
      ],
      const SizedBox(height: 24),
      LoadingButton(label: 'Continue', onPressed: _continue),
    ];
  }

  List<Widget> _buildTransfer(
    TopUpDestination destination,
    TopUpRequest? last,
  ) {
    final amount = _currency.format(parseAmount(_amountController.text) ?? 0);
    // The WHISH app cannot scan a code shown on its own phone, so phones get
    // a button that opens the payment in the app instead.
    final isPhone =
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
    final appLink = destination.appLink(_currency);
    final hasButton = isPhone && appLink != null;

    return [
      // WHISH refuses a code from a balance in another currency.
      Text(
        'Send $amount from your ${_currency.code} balance with WHISH MONEY, '
        'then come back and confirm.',
      ),
      const SizedBox(height: 24),
      // WHISH shows the sender a person's name, which nobody expects to see
      // when paying an app. The name itself is never shown here.
      const _Notice(
        'You are paying the founder of kahwa. Each transfer is checked by '
        'hand before it is added to your balance.',
      ),
      if (hasButton) ...[
        Link(
          uri: appLink,
          // A browser follows the link as a plain one, in the same tab. The
          // apps hand it to the phone, which would otherwise show it inside
          // kahwa.
          target: kIsWeb ? LinkTarget.self : LinkTarget.blank,
          builder: (context, followLink) => LoadingButton(
            label: 'Pay with WHISH',
            onPressed: followLink == null ? null : () => followLink(),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'WHISH did not open on the payment? Install or update the WHISH '
          'app and try again.',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: kGreyColor),
        ),
        const SizedBox(height: 24),
        const Text(
          'Paying from another phone? Scan this code in the WHISH app.',
          textAlign: TextAlign.center,
        ),
      ] else
        const Text(
          'Scan this code in the WHISH app.',
          textAlign: TextAlign.center,
        ),
      const SizedBox(height: 8),
      Center(
        child: QrImageView(
          data: destination.whishQr[_currency]!,
          size: 220,
          // Scanners need dark squares on a light ground with a margin.
          backgroundColor: kWhiteColor,
          padding: const EdgeInsets.all(12),
        ),
      ),
      const SizedBox(height: 24),
      InputText(
        controller: _phoneController,
        title: 'The WHISH number you sent from',
        // The field starts with the number of the last top up.
        subtitle: last == null || last.senderPhone.isEmpty
            ? 'So we can find your transfer.'
            : 'So we can find your transfer. Check it is the number you '
                  'sent from this time.',
        hint: '70 123 456',
        icon: Icons.phone_rounded,
        errorText: _phoneError,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.done,
      ),
      const SizedBox(height: 24),
      LoadingButton(
        label: 'I sent the money',
        isLoading: _isLoading,
        onPressed: _confirm,
      ),
      const SizedBox(height: 12),
      LoadingButton(
        label: 'Back',
        outlined: true,
        onPressed: _isLoading ? null : () => setState(() => _reference = null),
      ),
    ];
  }

  List<Widget> _buildPending(TopUpRequest request) {
    return [
      _Notice(
        'We are checking your transfer of '
        '${request.currency.format(request.amount)}. Your balance goes up as '
        'soon as it is found.',
      ),
      LoadingButton(
        label: 'Cancel request',
        outlined: true,
        isLoading: _isLoading,
        onPressed: _cancel,
      ),
    ];
  }
}

class _Notice extends StatelessWidget {
  const _Notice(this.text, {this.title});

  final String text;

  /// Shown in bold above [text], to say what the notice is about.
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kFillColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            SectionTitle(title!),
            const SizedBox(height: 4),
          ],
          Text(text),
        ],
      ),
    );
  }
}
