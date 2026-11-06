import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kahwa/core/money.dart';
import 'package:kahwa/features/studio/direct_pay_screen.dart';
import 'package:kahwa/models/money_requests.dart';
import 'package:kahwa/router.dart';
import 'package:kahwa/state/providers.dart';
import 'package:kahwa/theme/app_theme.dart';
import 'package:kahwa/ui/context.dart';
import 'package:kahwa/ui/labels.dart';
import 'package:kahwa/ui/money_stats.dart';
import 'package:kahwa/ui/widgets.dart';

/// The user's balance in each currency, and the ways to move it.
class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final wallet = ref.watch(myWalletProvider);
    final topUp = ref.watch(myTopUpProvider).valueOrNull;
    final isCreator =
        ref.watch(myProfileProvider).valueOrNull?.isCreator ?? false;
    final waiting = isCreator
        ? (ref.watch(myDirectPaymentsProvider).valueOrNull ?? const [])
              .where((p) => p.isPending)
              .toList()
        : const <DirectPayment>[];
    final now = DateTime.now();

    return TitledPage(
      title: l10n.balance,
      subtitle: l10n.walletSubtitle,
      children: [
        AsyncView(
          value: wallet,
          builder: (w) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final currency in Currency.values) ...[
                Card(
                  color: currency == Currency.lbp
                      ? context.colors.primary
                      : context.colors.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: _BalanceRow(
                      currency: currency,
                      amount: w.current.of(currency),
                      onColor: currency == Currency.lbp
                          ? context.colors.onPrimary
                          : context.colors.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => context.push(Routes.topUp()),
                      icon: const Icon(Icons.add_rounded),
                      label: Text(l10n.topUp),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push(Routes.withdraw),
                      icon: const Icon(Icons.arrow_outward_rounded),
                      label: Text(l10n.withdraw),
                    ),
                  ),
                ],
              ),
              if (topUp != null && topUp.isPending) ...[
                const SizedBox(height: 16),
                Notice(
                  tone: Tone.warning,
                  title: l10n.topUpCheckingTitle,
                  message: l10n.topUpChecking(
                    context.money(topUp.amount, topUp.currency),
                  ),
                ),
              ] else if (topUp != null && topUp.hasRecentResult(now)) ...[
                const SizedBox(height: 16),
                Notice(
                  tone: topUp.status.isOk ? Tone.success : Tone.danger,
                  title: l10n.lastTopUp,
                  message: [
                    topUp.status.isOk
                        ? l10n.topUpAdded(
                            context.money(topUp.amount, topUp.currency),
                          )
                        : l10n.topUpNotFound(
                            context.money(topUp.amount, topUp.currency),
                          ),
                    dateTime(context, topUp.resolvedAt),
                  ].join('\n'),
                ),
              ],
              // Kahwas paid straight to a creator's WHISH wait here for them
              // to confirm. Answered ones are under "See all".
              if (isCreator) ...[
                const SizedBox(height: 24),
                SectionTitle(
                  l10n.directPaymentsTitle,
                  action: l10n.seeAll,
                  onAction: () => context.push(Routes.directPayments),
                ),
                if (waiting.isEmpty)
                  Panel(
                    child: Row(
                      children: [
                        Icon(
                          Icons.mark_email_read_rounded,
                          color: context.kahwa.muted,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.directPaymentsNoneWaiting,
                            style: context.text.bodyMedium?.copyWith(
                              color: context.kahwa.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  for (final p in waiting) ...[
                    DirectPaymentCard(payment: p),
                    const SizedBox(height: 10),
                  ],
              ],
              const SizedBox(height: 24),
              SectionTitle(l10n.allTime),
              MoneyStats(
                stats: [
                  (l10n.received, w.received),
                  (l10n.spent, w.spent),
                  (l10n.withdrawn, w.withdrawn),
                ],
              ),
              const SizedBox(height: 16),
              TileGroup(
                children: [
                  NavTile(
                    icon: Icons.receipt_long_rounded,
                    title: l10n.history,
                    subtitle: l10n.historyHint,
                    onTap: () => context.push(Routes.history),
                  ),
                  NavTile(
                    icon: Icons.badge_rounded,
                    title: l10n.billingDetails,
                    subtitle: l10n.billingHint,
                    onTap: () => context.push(Routes.billing),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BalanceRow extends StatelessWidget {
  const _BalanceRow({
    required this.currency,
    required this.amount,
    required this.onColor,
  });

  final Currency currency;
  final int amount;
  final Color onColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: onColor.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            currency == Currency.lbp ? 'L.L' : r'$',
            style: context.text.titleMedium?.copyWith(color: onColor),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currencyName(context, currency),
                style: context.text.labelLarge?.copyWith(
                  color: onColor.withValues(alpha: 0.75),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  context.money(amount, currency),
                  style: context.text.headlineMedium?.copyWith(color: onColor),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
