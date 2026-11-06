import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kahwa/core/money.dart';
import 'package:kahwa/features/creator/share_sheet.dart';
import 'package:kahwa/models/profile.dart';
import 'package:kahwa/router.dart';
import 'package:kahwa/state/providers.dart';
import 'package:kahwa/theme/app_theme.dart';
import 'package:kahwa/ui/avatar.dart';
import 'package:kahwa/ui/context.dart';
import 'package:kahwa/ui/cover.dart';
import 'package:kahwa/ui/labels.dart';
import 'package:kahwa/ui/widgets.dart';

/// The user's own corner: their page, wallet, and settings.
class MeScreen extends ConsumerWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final me = ref.watch(myProfileProvider).valueOrNull;
    if (me == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final isAdmin = ref.watch(isAdminProvider).valueOrNull ?? false;
    final memberships = ref.watch(myMembershipsProvider).valueOrNull ?? [];
    final active = memberships.where((m) => m.isActive).length;
    final waitingPayments = me.isCreator
        ? (ref.watch(myDirectPaymentsProvider).valueOrNull ?? const [])
              .where((p) => p.isPending)
              .length
        : 0;

    return Scaffold(
      body: ListView(
        children: [
          PageFrame(
            maxWidth: 720,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ProfileHeader(me: me),
                  const SizedBox(height: 16),
                  _WalletCard(waitingPayments: waitingPayments),
                  const SizedBox(height: 24),
                  if (me.isCreator) ...[
                    SectionTitle(l10n.yourPage),
                    TileGroup(
                      children: [
                        NavTile(
                          icon: Icons.palette_rounded,
                          title: l10n.editPage,
                          subtitle: l10n.editPageHint,
                          onTap: () => context.push(Routes.editPage),
                        ),
                        NavTile(
                          icon: Icons.sell_rounded,
                          title: l10n.pricesAndMemberships,
                          subtitle: l10n.pricesHint(
                            context.money(me.priceLbp ?? 0, Currency.lbp),
                            me.tiers.length,
                          ),
                          onTap: () => context.push(Routes.prices),
                        ),
                        NavTile(
                          icon: Icons.flag_rounded,
                          title: l10n.goal,
                          subtitle: l10n.goalHint,
                          onTap: () => context.push(Routes.goal),
                        ),
                        NavTile(
                          icon: Icons.edit_note_rounded,
                          title: l10n.newPost,
                          subtitle: l10n.newPostHint,
                          onTap: () => context.push(Routes.post),
                        ),
                        NavTile(
                          icon: Icons.insights_rounded,
                          title: l10n.stats,
                          subtitle: l10n.statsHint,
                          onTap: () => context.push(Routes.stats),
                        ),
                        NavTile(
                          icon: Icons.groups_rounded,
                          title: l10n.supportersAndMembers,
                          onTap: () => context.push(Routes.supporters),
                        ),
                        NavTile(
                          icon: Icons.phone_iphone_rounded,
                          title: l10n.directPayTitle,
                          subtitle: l10n.directPayHint,
                          onTap: () => context.push(Routes.directPaySettings),
                        ),
                      ],
                    ),
                  ] else
                    Panel(
                      onTap: () => context.push(Routes.prices),
                      child: Row(
                        children: [
                          Icon(
                            Icons.brush_rounded,
                            color: context.colors.primary,
                            size: 28,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.startPageTitle,
                                  style: context.text.titleMedium,
                                ),
                                Text(
                                  l10n.startPageBody,
                                  style: context.text.bodySmall?.copyWith(
                                    color: context.kahwa.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  SectionTitle(l10n.youSupport),
                  TileGroup(
                    children: [
                      NavTile(
                        icon: Icons.workspace_premium_rounded,
                        title: l10n.myMemberships,
                        subtitle: l10n.activeMemberships(active),
                        onTap: () => context.push(Routes.memberships),
                      ),
                      NavTile(
                        icon: Icons.receipt_long_rounded,
                        title: l10n.history,
                        subtitle: l10n.historyHint,
                        onTap: () => context.push(Routes.history),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SectionTitle(l10n.account),
                  TileGroup(
                    children: [
                      NavTile(
                        icon: Icons.tune_rounded,
                        title: l10n.settings,
                        subtitle: l10n.settingsHint,
                        onTap: () => context.push(Routes.settings),
                      ),
                      NavTile(
                        icon: Icons.badge_rounded,
                        title: l10n.billingDetails,
                        subtitle: l10n.billingHint,
                        onTap: () => context.push(Routes.billing),
                      ),
                      if (isAdmin)
                        NavTile(
                          icon: Icons.admin_panel_settings_rounded,
                          title: l10n.admin,
                          onTap: () => context.push(Routes.admin),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.me});

  final Profile me;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The avatar sits on the edge of the banner, centered, with the
          // name and username centered under it.
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              CoverBanner(
                color: Color(me.color),
                pattern: CoverPattern.of(me.cover),
                height: 84,
              ),
              Positioned(
                bottom: -38,
                child: ProfileAvatar(profile: me, size: 76, ring: true),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 46, 18, 16),
            child: Column(
              children: [
                Text(
                  me.name,
                  style: context.text.titleLarge,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  me.username == null ? l10n.noUsername : '@${me.username}',
                  style: context.text.bodyMedium?.copyWith(
                    color: context.kahwa.muted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () => context.push(Routes.page(me)),
                    icon: const Icon(Icons.visibility_rounded),
                    label: Text(l10n.viewMyPage),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.outlined(
                  tooltip: l10n.share,
                  onPressed: () => showShareSheet(context, me),
                  icon: const Icon(Icons.ios_share_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletCard extends ConsumerWidget {
  const _WalletCard({required this.waitingPayments});

  /// Direct WHISH payments the creator has not answered yet. They are
  /// answered from the balance page, which this card opens.
  final int waitingPayments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final wallet = ref.watch(myWalletProvider).valueOrNull;
    final onPrimary = context.colors.onPrimary;
    return Card(
      color: context.colors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.card),
      ),
      child: InkWell(
        onTap: () => context.push(Routes.wallet),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.account_balance_wallet_rounded, color: onPrimary),
                  const SizedBox(width: 8),
                  Text(
                    l10n.balance,
                    style: context.text.titleSmall?.copyWith(color: onPrimary),
                  ),
                  const Spacer(),
                  if (waitingPayments > 0)
                    Text(
                      l10n.directPaymentsWaiting(waitingPayments),
                      style: context.text.labelMedium?.copyWith(
                        color: onPrimary,
                      ),
                    ),
                  Icon(Icons.chevron_right_rounded, color: onPrimary),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  for (final currency in Currency.values)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currencyName(context, currency),
                            style: context.text.labelMedium?.copyWith(
                              color: onPrimary.withValues(alpha: 0.75),
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              context.money(
                                wallet?.current.of(currency) ?? 0,
                                currency,
                              ),
                              style: context.text.headlineSmall?.copyWith(
                                color: onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () => context.push(Routes.topUp()),
                      style: FilledButton.styleFrom(
                        backgroundColor: onPrimary,
                        foregroundColor: context.colors.primary,
                        minimumSize: const Size(0, 44),
                      ),
                      child: Text(l10n.topUp),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.push(Routes.withdraw),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: onPrimary,
                        side: BorderSide(
                          color: onPrimary.withValues(alpha: 0.6),
                        ),
                        minimumSize: const Size(0, 44),
                      ),
                      child: Text(l10n.withdraw),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
