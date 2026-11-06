import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kahwa/features/me/security_screen.dart';
import 'package:kahwa/core/money.dart';
import 'package:kahwa/core/text.dart';
import 'package:kahwa/data/support_repository.dart';
import 'package:kahwa/features/creator/share_sheet.dart';
import 'package:kahwa/features/wallet/top_up_screen.dart';
import 'package:kahwa/models/membership.dart';
import 'package:kahwa/models/money_requests.dart';
import 'package:kahwa/models/profile.dart';
import 'package:kahwa/models/tier.dart';
import 'package:kahwa/router.dart';
import 'package:kahwa/state/providers.dart';
import 'package:kahwa/theme/app_theme.dart';
import 'package:kahwa/ui/avatar.dart';
import 'package:kahwa/ui/context.dart';
import 'package:kahwa/ui/whish_pay.dart';
import 'package:kahwa/ui/widgets.dart';

/// Where the support screen was opened from, passed as the route's extra.
enum SupportOpenedFrom { page }

/// Buying a creator kahwas, or joining one of their memberships.
class SupportScreen extends ConsumerWidget {
  const SupportScreen({
    super.key,
    required this.creatorId,
    this.fromPage = false,
    this.tierId,
    this.kahwas,
    this.currency,
  });

  final String creatorId;

  /// Opened from the creator's page, which is right under this screen.
  final bool fromPage;
  final String? tierId;
  final int? kahwas;
  final Currency? currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creator = ref.watch(profileProvider(creatorId));
    final me = ref.watch(myProfileProvider);
    final pending = ref.watch(pendingKahwaProvider);
    // Not pending.isLoading: it reloads while a payment finishes, and the
    // form below has to stay to show the thank you.
    if (!creator.hasValue ||
        !me.hasValue ||
        (pending.isLoading && !pending.hasValue)) {
      if (creator.hasError || me.hasError) {
        return Scaffold(
          appBar: AppBar(),
          body: ErrorView(
            onRetry: () => ref.invalidate(profileProvider(creatorId)),
          ),
        );
      }
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final c = creator.value;
    final m = me.value;
    // Only for signed in users: no profile yet means it is still loading.
    if (m == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (c == null || !c.isCreator || c.id == m.id) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(
          icon: Icons.coffee_rounded,
          title: context.l10n.cannotSupportTitle,
          message: context.l10n.cannotSupportBody,
        ),
      );
    }
    // A kahwa left waiting for a top up comes back filled in, unless this
    // was opened for another tier, such as "Join again" on a membership.
    final kept = pending.valueOrNull;
    final resume =
        kept != null &&
            kept.creatorId == c.id &&
            (tierId == null || tierId == kept.tierId)
        ? kept
        : null;
    return Theme(
      data: buildTheme(
        brightness: Theme.of(context).brightness,
        accent: Color(c.color),
        arabic: context.isArabic,
      ),
      child: _SupportForm(
        creator: c,
        me: m,
        tierId: tierId ?? resume?.tierId,
        kahwas: kahwas ?? resume?.kahwas,
        currency: currency ?? resume?.currency,
        message: resume?.message ?? '',
        keepPrivate: resume?.keepPrivate ?? false,
        resumed: resume != null,
        fromPage: fromPage,
      ),
    );
  }
}

class _SupportForm extends ConsumerStatefulWidget {
  const _SupportForm({
    required this.creator,
    required this.me,
    required this.tierId,
    required this.kahwas,
    required this.currency,
    required this.message,
    required this.keepPrivate,
    required this.resumed,
    required this.fromPage,
  });

  final Profile creator;
  final Profile me;
  final String? tierId;
  final int? kahwas;
  final Currency? currency;
  final String message;
  final bool keepPrivate;
  final bool resumed;
  final bool fromPage;

  @override
  ConsumerState<_SupportForm> createState() => _SupportFormState();
}

class _SupportFormState extends ConsumerState<_SupportForm> {
  static const _quick = [1, 3, 5, 10];

  late Tier? _tier = widget.creator.tier(widget.tierId ?? '');
  late int _kahwas = (widget.kahwas ?? 1).clamp(1, 1000);

  /// The currency the user picked, or the one given when opened. Without
  /// either, an existing membership's currency, else LBP.
  late Currency? _chosenCurrency = widget.currency;

  /// The user's membership to this creator, as of the last build.
  Membership? _membership;

  Currency get _currency =>
      _chosenCurrency ?? _membership?.currency ?? Currency.lbp;
  late final _message = TextEditingController(text: widget.message);
  late bool _private = widget.keepPrivate;

  /// Set while paying: the form is locked so nothing changes under it.
  bool _busy = false;
  bool _done = false;

  /// Paying straight to the creator's WHISH account rather than from the
  /// balance. Only for kahwas, when the creator takes it.
  bool _direct = false;
  final _sender = TextEditingController();
  String? _senderError;

  /// A direct payment was sent and waits for the creator to confirm it.
  bool _waiting = false;

  Profile get _creator => widget.creator;

  int get _price => _creator.price(_currency) ?? 0;

  int get _count => _tier?.kahwas ?? _kahwas;

  int get _total => _count * _price;

  @override
  void dispose() {
    _message.dispose();
    _sender.dispose();
    super.dispose();
  }

  /// Tells the creator the kahwas were sent to their WHISH account.
  Future<void> _sendDirect() async {
    final l10n = context.l10n;
    final phone = _sender.text.trim();
    if (!isPhoneNumber(phone)) {
      setState(
        () => _senderError = phone.isEmpty
            ? l10n.senderPhoneMissing
            : l10n.phoneInvalid,
      );
      return;
    }
    setState(() => _senderError = null);
    if (!await requireVerifiedEmail(context, ref) || !mounted) return;
    final ok = await confirm(
      context,
      title: l10n.directSentTitle(context.money(_total, _currency)),
      message: l10n.directSentBody(firstNameOf(_creator.name)),
      confirm: l10n.iSentTheMoney,
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(supportRepositoryProvider)
          .sendDirectPayment(
            creator: _creator,
            me: widget.me,
            kahwas: _kahwas,
            currency: _currency,
            senderPhone: phone,
            message: _message.text,
            keepPrivate: _private,
          );
      refreshMyData(ref.invalidate);
      if (mounted) setState(() => _waiting = true);
    } catch (_) {
      if (mounted) showSnack(context, l10n.somethingWrong);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pay(int balance) async {
    final l10n = context.l10n;
    final tier = _tier;
    final total = _total;
    final currency = _currency;
    final missing = total - balance;

    if (!await requireVerifiedEmail(context, ref) || !mounted) return;
    if (missing > 0) {
      await _offerTopUp(missing, currency);
      return;
    }
    final ok = await confirm(
      context,
      title: tier == null
          ? l10n.confirmBuyTitle(_kahwas)
          : l10n.confirmJoinTitle(tier.name),
      message: tier == null
          ? l10n.confirmBuyBody(context.money(total, currency), _creator.name)
          : l10n.confirmJoinBody(context.money(total, currency)),
      confirm: tier == null ? l10n.buy : l10n.join,
    );
    if (!ok || !mounted) return;

    setState(() => _busy = true);
    final repo = ref.read(supportRepositoryProvider);
    try {
      final result = tier == null
          ? await repo.buy(
              creator: _creator,
              me: widget.me,
              kahwas: _kahwas,
              currency: currency,
              message: _message.text,
              keepPrivate: _private,
            )
          : await repo.join(
              creator: _creator,
              me: widget.me,
              tier: tier,
              currency: currency,
              message: _message.text,
              keepPrivate: _private,
            );
      refreshMyData(ref.invalidate);
      if (!mounted) return;
      switch (result) {
        case BuyResult.done:
          if (widget.resumed) {
            await repo.clearPending(widget.me.id).catchError((_) {});
            ref.invalidate(pendingKahwaProvider);
          }
          ref.invalidate(myMembershipsProvider);
          setState(() => _done = true);
        case BuyResult.notEnough:
          final wallet = ref.read(myWalletProvider).valueOrNull;
          await _offerTopUp(
            total - (wallet?.current.of(currency) ?? 0),
            currency,
          );
        case BuyResult.changed:
          showSnack(context, l10n.pageChanged);
      }
    } catch (_) {
      if (mounted) showSnack(context, l10n.paymentFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Takes back [membership], cancelled with its month still paid, without
  /// charging anything.
  Future<void> _resume(Membership membership) async {
    final l10n = context.l10n;
    final ok = await confirm(
      context,
      title: l10n.resumeTitle(membership.tierName),
      message: l10n.resumeBody(context.date(membership.nextCharge)),
      confirm: l10n.resume,
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    final repo = ref.read(supportRepositoryProvider);
    try {
      await repo.resume(membership);
      if (!mounted) return;
      if (widget.resumed) {
        await repo.clearPending(widget.me.id).catchError((_) {});
        ref.invalidate(pendingKahwaProvider);
      }
      ref.invalidate(myMembershipsProvider);
      setState(() => _done = true);
    } catch (_) {
      if (mounted) showSnack(context, l10n.paymentFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Keeps this kahwa and opens a top up of exactly what is missing.
  Future<void> _offerTopUp(int missing, Currency currency) async {
    final l10n = context.l10n;
    final go = await confirm(
      context,
      title: l10n.notEnoughTitle,
      message: l10n.notEnoughBody(context.money(missing, currency)),
      confirm: l10n.topUpAmount(context.money(missing, currency)),
    );
    if (!go || !mounted) return;
    try {
      await ref
          .read(supportRepositoryProvider)
          .savePending(
            widget.me.id,
            PendingKahwa(
              creatorId: _creator.id,
              kahwas: _count,
              currency: currency,
              message: _message.text.trim(),
              keepPrivate: _private,
              tierId: _tier?.id,
            ),
          );
      ref.invalidate(pendingKahwaProvider);
    } catch (_) {
      // The top up still works without it.
    }
    if (!mounted) return;
    final sent = await context.push<bool>(
      Routes.topUp(amount: missing, currency: currency),
      extra: TopUpOpenedFrom.support,
    );
    // The top up is on its way: nothing more to do here until it is in.
    // Home has the kahwa ready to finish then.
    if (sent == true && mounted) {
      showSnack(context, l10n.kahwaKeptForTopUp);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_done || _waiting) {
      return _ThankYou(
        creator: _creator,
        kahwas: _count,
        membership: _tier,
        fromPage: widget.fromPage,
        waiting: _waiting,
      );
    }
    final directPay = ref.watch(directPayProvider(_creator.id)).valueOrNull;
    final canDirect = _tier == null && (directPay?.isOn ?? false);
    final direct = _direct && canDirect;
    if (direct && !directPay!.currencies.contains(_currency)) {
      // The creator removed the link of the chosen currency meanwhile.
      _chosenCurrency = directPay.currencies.first;
    }
    final l10n = context.l10n;
    final wallet = ref.watch(myWalletProvider).valueOrNull;
    final balance = wallet?.current.of(_currency) ?? 0;
    final membership = (ref.watch(myMembershipsProvider).valueOrNull ?? [])
        .where((m) => m.creatorId == _creator.id)
        .firstOrNull;
    _membership = membership;
    final tiers = _creator.tiers;
    final enough = balance >= _total;
    // A month already paid for this tier: paying again would be refused.
    final paidTier =
        _tier != null &&
        membership != null &&
        membership.isActive &&
        membership.tierId == _tier!.id &&
        !membership.isDue(DateTime.now());
    // A cancelled membership whose month is still paid comes back for free
    // in the same tier, and keeps its currency. Another tier is a new month.
    final resumable =
        _tier != null &&
        membership != null &&
        membership.tierId == _tier!.id &&
        membership.canResume(DateTime.now());

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          PageFrame(
            maxWidth: 560,
            child: AbsorbPointer(
              absorbing: _busy,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      ProfileAvatar(profile: _creator, size: 60),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _tier == null
                              ? l10n.buyTitle(firstNameOf(_creator.name))
                              : l10n.joinTitle(_creator.name),
                          style: context.text.headlineSmall,
                        ),
                      ),
                    ],
                  ),
                  if (widget.resumed) ...[
                    const SizedBox(height: 16),
                    Notice(
                      tone: Tone.success,
                      message: l10n.resumedKahwa,
                      icon: Icons.restore_rounded,
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (tiers.isNotEmpty) ...[
                    SegmentedButton<bool>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(value: false, label: Text(l10n.oneTime)),
                        ButtonSegment(value: true, label: Text(l10n.monthly)),
                      ],
                      selected: {_tier != null},
                      // Monthly starts on the tier the user already has.
                      onSelectionChanged: (s) => setState(
                        () => _tier = s.first
                            ? (_creator.tier(membership?.tierId ?? '') ??
                                  tiers.first)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _tier == null ? l10n.oneTimeHint : l10n.monthlyHint,
                      style: context.text.bodySmall?.copyWith(
                        color: context.kahwa.muted,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (_tier == null)
                    _KahwaPicker(
                      value: _kahwas,
                      quick: _quick,
                      onChanged: (n) => setState(() => _kahwas = n),
                    )
                  else
                    _TierPicker(
                      creator: _creator,
                      selected: _tier!,
                      currency: _currency,
                      membership: membership,
                      onChanged: (t) => setState(() => _tier = t),
                    ),
                  if (resumable) ...[
                    const SizedBox(height: 4),
                    Notice(
                      tone: Tone.success,
                      message: l10n.resumeHint(
                        context.date(membership.nextCharge),
                      ),
                      icon: Icons.workspace_premium_rounded,
                    ),
                  ],
                  if (paidTier) ...[
                    const SizedBox(height: 4),
                    Notice(
                      tone: Tone.success,
                      message: l10n.alreadyInTier(
                        context.date(membership.nextCharge),
                      ),
                      icon: Icons.workspace_premium_rounded,
                    ),
                  ],
                  const SizedBox(height: 20),
                  if (!resumable)
                    FieldLabel(
                      l10n.payIn,
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: CurrencyToggle(
                          value: _currency,
                          options: direct
                              ? directPay!.currencies
                              : Currency.values,
                          onChanged: (c) => setState(() => _chosenCurrency = c),
                        ),
                      ),
                    ),
                  if (canDirect)
                    FieldLabel(
                      l10n.payWith,
                      child: SegmentedButton<bool>(
                        showSelectedIcon: false,
                        segments: [
                          ButtonSegment(
                            value: false,
                            label: Text(l10n.payWithBalance),
                          ),
                          ButtonSegment(
                            value: true,
                            label: Text(
                              l10n.payWithWhishTo(firstNameOf(_creator.name)),
                            ),
                          ),
                        ],
                        selected: {direct},
                        onSelectionChanged: (s) => setState(() {
                          _direct = s.first;
                          // A creator may have a WHISH link in one currency only.
                          final currencies = directPay!.currencies;
                          if (_direct && !currencies.contains(_currency)) {
                            _chosenCurrency = currencies.first;
                          }
                        }),
                      ),
                    ),
                  if (direct) ...[
                    _DirectPayPanel(
                      code: directPay!.whishLinks[_currency]!,
                      amount: context.money(_total, _currency),
                      name: firstNameOf(_creator.name),
                    ),
                    const SizedBox(height: 16),
                    FieldLabel(
                      l10n.senderPhone,
                      hint: l10n.senderPhoneHintDirect,
                      child: TextField(
                        controller: _sender,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: '70 123 456',
                          errorText: _senderError,
                          prefixIcon: const Icon(Icons.phone_rounded),
                        ),
                      ),
                    ),
                  ],
                  // Taking a membership back sends no message.
                  if (!resumable) ...[
                    FieldLabel(
                      l10n.message,
                      child: TextField(
                        controller: _message,
                        maxLength: 500,
                        minLines: 2,
                        maxLines: 4,
                        decoration: InputDecoration(hintText: l10n.messageHint),
                      ),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _private,
                      onChanged: (v) => setState(() => _private = v),
                      title: Text(l10n.keepPrivate),
                      subtitle: Text(
                        l10n.keepPrivateHint(firstNameOf(_creator.name)),
                        style: TextStyle(color: context.kahwa.muted),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Nothing is paid when taking a membership back.
                  if (!resumable && !direct)
                    _Summary(
                      total: _total,
                      currency: _currency,
                      balance: balance,
                      monthly: _tier != null,
                    ),
                  if (_tier != null && !resumable) ...[
                    const SizedBox(height: 12),
                    Text(
                      l10n.membershipRenewHint,
                      style: context.text.bodySmall?.copyWith(
                        color: context.kahwa.muted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: PageFrame(
          maxWidth: 560,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _busy || paidTier
                  ? null
                  : direct
                  ? _sendDirect
                  : resumable
                  ? () => _resume(membership)
                  : () => _pay(balance),
              child: _busy
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    )
                  : Text(
                      paidTier
                          ? l10n.youAreMember
                          : direct
                          ? l10n.iSentAmount(context.money(_total, _currency))
                          : resumable
                          ? l10n.resume
                          : !enough
                          ? l10n.topUpToContinue
                          : _tier == null
                          ? l10n.supportFor(context.money(_total, _currency))
                          : l10n.joinFor(context.money(_total, _currency)),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Where to send a direct payment: the creator's own WHISH pay link, opened
/// in the WHISH app. Their phone number is never shown.
class _DirectPayPanel extends StatelessWidget {
  const _DirectPayPanel({
    required this.code,
    required this.amount,
    required this.name,
  });

  final String code;
  final String amount;
  final String name;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Panel(
      color: context.kahwa.subtle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.directSendTo(amount, name), style: context.text.titleSmall),
          const SizedBox(height: 16),
          WhishPayBox(code: code),
          const SizedBox(height: 12),
          Text(
            l10n.directNotice(name),
            style: context.text.bodySmall?.copyWith(color: context.kahwa.muted),
          ),
        ],
      ),
    );
  }
}

class _KahwaPicker extends StatelessWidget {
  const _KahwaPicker({
    required this.value,
    required this.quick,
    required this.onChanged,
  });

  final int value;
  final List<int> quick;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Panel(
      child: Column(
        children: [
          SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Five places, always there: a cup grows in when the count
                // goes up and shrinks away when it goes down.
                for (var i = 0; i < 5; i++) _Cup(shown: i < value),
                if (value > 5)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 6),
                    child: Text(
                      '+${value - 5}',
                      style: context.text.titleLarge,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                tooltip: l10n.fewer,
                onPressed: value > 1 ? () => onChanged(value - 1) : null,
                icon: const Icon(Icons.remove_rounded),
              ),
              SizedBox(
                width: 110,
                child: Text(
                  l10n.kahwasCount(value),
                  textAlign: TextAlign.center,
                  style: context.text.titleLarge,
                ),
              ),
              IconButton.filledTonal(
                tooltip: l10n.more,
                onPressed: value < 1000 ? () => onChanged(value + 1) : null,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final n in quick)
                ChoiceChip(
                  selected: n == value,
                  onSelected: (_) => onChanged(n),
                  label: Text('$n'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One cup of the picker, animated in and out.
class _Cup extends StatelessWidget {
  const _Cup({required this.shown});

  final bool shown;

  static const _duration = Duration(milliseconds: 320);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: _duration,
      curve: Curves.easeOutCubic,
      width: shown ? 56 : 0,
      child: AnimatedScale(
        scale: shown ? 1 : 0.2,
        duration: _duration,
        curve: shown ? Curves.easeOutBack : Curves.easeInCubic,
        child: AnimatedOpacity(
          opacity: shown ? 1 : 0,
          duration: _duration,
          child: const OverflowBox(
            maxWidth: 56,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2),
              child: KahwaCup(size: 52),
            ),
          ),
        ),
      ),
    );
  }
}

class _TierPicker extends StatelessWidget {
  const _TierPicker({
    required this.creator,
    required this.selected,
    required this.currency,
    required this.membership,
    required this.onChanged,
  });

  final Profile creator;
  final Tier selected;
  final Currency currency;
  final Membership? membership;
  final ValueChanged<Tier> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        for (final tier in creator.tiers)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Radii.tile),
                side: BorderSide(
                  color: tier.id == selected.id
                      ? context.colors.primary
                      : context.kahwa.border,
                  width: tier.id == selected.id ? 2 : 1,
                ),
              ),
              child: RadioListTile<String>(
                value: tier.id,
                // ignore: deprecated_member_use
                groupValue: selected.id,
                // ignore: deprecated_member_use
                onChanged: (_) => onChanged(tier),
                title: Text(tier.name, style: context.text.titleMedium),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${context.money(tier.monthly(creator.price(currency) ?? 0), currency)} ${l10n.perMonth}',
                    ),
                    if (tier.perks.isNotEmpty)
                      Text(
                        tier.perks,
                        style: TextStyle(color: context.kahwa.muted),
                      ),
                    if (membership?.tierId == tier.id && membership!.isActive)
                      Text(
                        l10n.yourTier,
                        style: TextStyle(
                          color: context.colors.onPrimaryContainer,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.total,
    required this.currency,
    required this.balance,
    required this.monthly,
  });

  final int total;
  final Currency currency;
  final int balance;
  final bool monthly;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final after = balance - total;
    Widget row(
      String label,
      String value, {
      bool strong = false,
      Color? color,
    }) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: strong
                    ? context.text.titleMedium
                    : context.text.bodyMedium?.copyWith(
                        color: context.kahwa.muted,
                      ),
              ),
            ),
            Text(
              value,
              style:
                  (strong ? context.text.titleMedium : context.text.bodyMedium)
                      ?.copyWith(color: color),
            ),
          ],
        ),
      );
    }

    return Panel(
      color: context.kahwa.subtle,
      child: Column(
        children: [
          row(
            monthly ? l10n.eachMonth : l10n.total,
            context.money(total, currency),
            strong: true,
          ),
          const Divider(height: 20),
          row(l10n.yourBalance, context.money(balance, currency)),
          row(
            l10n.afterThis,
            after >= 0 ? context.money(after, currency) : l10n.notEnoughShort,
            color: after >= 0 ? null : context.kahwa.danger,
          ),
        ],
      ),
    );
  }
}

/// Shown after a purchase: the creator's thanks.
class _ThankYou extends StatelessWidget {
  const _ThankYou({
    required this.creator,
    required this.kahwas,
    required this.membership,
    required this.fromPage,
    this.waiting = false,
  });

  final Profile creator;
  final int kahwas;
  final Tier? membership;
  final bool fromPage;

  /// Paid straight to the creator, who still has to confirm it.
  final bool waiting;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final thanks = creator.thanks.trim().isNotEmpty
        ? creator.thanks
        : l10n.defaultThanks;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.elasticOut,
                    builder: (context, t, child) => Transform.scale(
                      scale: 0.5 + t * 0.5,
                      child: Transform.rotate(
                        angle: (1 - t) * -0.5,
                        child: child,
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: context.colors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const KahwaCup(size: 96),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    waiting
                        ? l10n.directWaitingTitle
                        : membership == null
                        ? l10n.thankYouKahwas(kahwas)
                        : l10n.thankYouMember(membership!.name),
                    style: context.text.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  if (waiting) ...[
                    const SizedBox(height: 12),
                    Text(
                      l10n.directWaitingBody(firstNameOf(creator.name)),
                      textAlign: TextAlign.center,
                      style: context.text.bodyLarge?.copyWith(
                        color: context.kahwa.muted,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Panel(
                    child: Column(
                      children: [
                        ProfileAvatar(profile: creator, size: 44),
                        const SizedBox(height: 10),
                        Text(
                          '“$thanks”',
                          textDirection: textDirectionOf(thanks),
                          style: context.text.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '— ${creator.name}',
                          style: TextStyle(color: context.kahwa.muted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      // Back to the page under this screen, or, when this
                      // was opened from elsewhere such as Home, to the page
                      // in its place.
                      onPressed: () => fromPage && context.canPop()
                          ? context.pop()
                          : context.canPop()
                          ? context.pushReplacement(Routes.page(creator))
                          : context.go(Routes.page(creator)),
                      child: Text(l10n.backToPage(firstNameOf(creator.name))),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => showShareSheet(context, creator),
                      icon: const Icon(Icons.ios_share_rounded),
                      label: Text(l10n.tellFriends),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
