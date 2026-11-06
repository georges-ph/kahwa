import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kahwa/features/me/security_screen.dart';
import 'package:kahwa/core/money.dart';
import 'package:kahwa/models/money_requests.dart';
import 'package:kahwa/router.dart';
import 'package:kahwa/state/providers.dart';
import 'package:kahwa/theme/app_theme.dart';
import 'package:kahwa/ui/context.dart';
import 'package:kahwa/ui/widgets.dart';

final _withdrawalsProvider = FutureProvider.autoDispose<List<WithdrawRequest>>((
  ref,
) {
  final id = ref.watch(userIdProvider);
  if (id == null) return Future.value(const []);
  return ref.watch(walletRepositoryProvider).withdrawals(id);
});

final _billingProvider = FutureProvider.autoDispose<BillingDetails>((ref) {
  final id = ref.watch(userIdProvider);
  if (id == null) return Future.value(const BillingDetails());
  return ref.watch(walletRepositoryProvider).billing(id);
});

/// Getting money out: one request waits at a time, paid by hand with WHISH.
class WithdrawScreen extends ConsumerStatefulWidget {
  const WithdrawScreen({super.key});

  @override
  ConsumerState<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends ConsumerState<WithdrawScreen> {
  final _lbp = TextEditingController();
  final _usd = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _lbp.dispose();
    _usd.dispose();
    super.dispose();
  }

  Future<void> _request(Amounts balance) async {
    final l10n = context.l10n;
    final id = ref.read(userIdProvider);
    if (id == null) return;
    final lbp = _lbp.text.trim().isEmpty ? 0 : parseAmount(_lbp.text);
    final usd = _usd.text.trim().isEmpty ? 0 : parseAmount(_usd.text);
    setState(() {
      _error = lbp == null || usd == null || lbp + usd == 0
          ? l10n.withdrawAmountMissing
          : lbp > balance.lbp || usd > balance.usd
          ? l10n.withdrawTooMuch
          : null;
    });
    if (_error != null) return;
    if (!await requireVerifiedEmail(context, ref)) return;
    try {
      await ref
          .read(walletRepositoryProvider)
          .requestWithdraw(id, Amounts(lbp: lbp!, usd: usd!));
      refreshMyData(ref.invalidate);
      ref.invalidate(_withdrawalsProvider);
      _lbp.clear();
      _usd.clear();
      if (mounted) showSnack(context, l10n.requestSent);
    } catch (_) {
      if (mounted) showSnack(context, l10n.somethingWrong);
    }
  }

  Future<void> _cancel(WithdrawRequest request) async {
    try {
      await ref.read(walletRepositoryProvider).cancelWithdraw(request);
      refreshMyData(ref.invalidate);
      ref.invalidate(_withdrawalsProvider);
    } catch (_) {
      if (mounted) showSnack(context, context.l10n.somethingWrong);
    }
  }

  String _amounts(Amounts a) {
    return [
      if (a.lbp > 0) context.money(a.lbp, Currency.lbp),
      if (a.usd > 0) context.money(a.usd, Currency.usd),
    ].join(' + ');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final wallet = ref.watch(myWalletProvider).valueOrNull;
    final balance = wallet?.current ?? const Amounts();
    final billing = ref.watch(_billingProvider);
    final withdrawals = ref.watch(_withdrawalsProvider);
    final waiting = withdrawals.valueOrNull
        ?.where((w) => w.isPending)
        .firstOrNull;

    return TitledPage(
      title: l10n.withdraw,
      subtitle: l10n.withdrawSubtitle,
      children: [
        Panel(
          color: context.kahwa.subtle,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.available,
                  style: context.text.bodyMedium?.copyWith(
                    color: context.kahwa.muted,
                  ),
                ),
              ),
              Text(
                '${context.money(balance.lbp, Currency.lbp)}  ·  ${context.money(balance.usd, Currency.usd)}',
                style: context.text.titleSmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        AsyncView(
          value: billing,
          builder: (details) {
            if (!details.isComplete) {
              return Notice(
                tone: Tone.warning,
                title: l10n.billingFirstTitle,
                message: l10n.billingFirst,
                action: FilledButton(
                  onPressed: () => context
                      .push(Routes.billing)
                      .then((_) => ref.invalidate(_billingProvider)),
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
                  child: Text(l10n.billingDetails),
                ),
              );
            }
            if (waiting != null) {
              return Notice(
                tone: Tone.warning,
                title: l10n.withdrawWaitingTitle,
                message: l10n.withdrawWaiting(_amounts(waiting.amounts)),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.paidTo(details.whishPhone),
                  style: context.text.bodyMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AmountField(
                        controller: _lbp,
                        currency: Currency.lbp,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AmountField(
                        controller: _usd,
                        currency: Currency.usd,
                      ),
                    ),
                  ],
                ),
                if (_error != null) ...[
                  const SizedBox(height: 6),
                  Text(_error!, style: TextStyle(color: context.kahwa.danger)),
                ],
                const SizedBox(height: 16),
                BusyButton(
                  label: l10n.requestWithdraw,
                  onPressed: () => _request(balance),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 28),
        SectionTitle(l10n.yourRequests),
        AsyncView(
          value: withdrawals,
          onRetry: () => ref.invalidate(_withdrawalsProvider),
          builder: (list) => list.isEmpty
              ? Text(
                  l10n.noRequests,
                  style: context.text.bodyMedium?.copyWith(
                    color: context.kahwa.muted,
                  ),
                )
              : TileGroup(
                  children: [
                    for (final w in list)
                      ListTile(
                        title: Text(_amounts(w.amounts)),
                        subtitle: Text(
                          [
                            switch (w.status) {
                              RequestStatus.paid => l10n.statusPaid,
                              RequestStatus.refused => l10n.statusRefused,
                              _ => l10n.statusWaiting,
                            },
                            dateTime(context, w.timestamp),
                          ].join(' · '),
                        ),
                        trailing: w.isPending
                            ? TextButton(
                                onPressed: () => _cancel(w),
                                child: Text(l10n.cancel),
                              )
                            : Icon(
                                w.status == RequestStatus.paid
                                    ? Icons.check_circle_rounded
                                    : Icons.cancel_rounded,
                                color: w.status == RequestStatus.paid
                                    ? context.kahwa.success
                                    : context.kahwa.muted,
                              ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}
