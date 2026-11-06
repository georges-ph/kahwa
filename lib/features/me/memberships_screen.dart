import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kahwa/models/membership.dart';
import 'package:kahwa/models/profile.dart';
import 'package:kahwa/router.dart';
import 'package:kahwa/state/providers.dart';
import 'package:kahwa/theme/app_theme.dart';
import 'package:kahwa/ui/avatar.dart';
import 'package:kahwa/ui/context.dart';
import 'package:kahwa/ui/widgets.dart';

/// The memberships the user pays for.
class MembershipsScreen extends ConsumerWidget {
  const MembershipsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final memberships = ref.watch(myMembershipsProvider);
    return TitledPage(
      title: l10n.myMemberships,
      subtitle: l10n.myMembershipsSubtitle,
      onRefresh: () async => ref.invalidate(myMembershipsProvider),
      children: [
        AsyncView(
          value: memberships,
          onRetry: () => ref.invalidate(myMembershipsProvider),
          builder: (list) {
            if (list.isEmpty) {
              return EmptyState(
                icon: Icons.workspace_premium_rounded,
                title: l10n.noMembershipsTitle,
                message: l10n.noMembershipsBody,
                action: FilledButton(
                  onPressed: () => context.go(Routes.explore),
                  child: Text(l10n.exploreCreators),
                ),
              );
            }
            final creators =
                ref
                    .watch(
                      profilesProvider(
                        ProfileIds(list.map((m) => m.creatorId)),
                      ),
                    )
                    .valueOrNull ??
                const {};
            return Column(
              children: [
                for (final m in list) ...[
                  _MembershipCard(
                    membership: m,
                    creator: creators[m.creatorId],
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _MembershipCard extends ConsumerWidget {
  const _MembershipCard({required this.membership, required this.creator});

  final Membership membership;
  final Profile? creator;

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final ok = await confirm(
      context,
      title: l10n.cancelMembershipTitle,
      message: l10n.cancelMembershipBody(context.date(membership.nextCharge)),
      confirm: l10n.cancelMembership,
      dismiss: l10n.keepMembership,
      danger: true,
    );
    if (!ok) return;
    try {
      await ref.read(supportRepositoryProvider).cancel(membership);
      ref.invalidate(myMembershipsProvider);
    } catch (_) {
      if (context.mounted) showSnack(context, l10n.somethingWrong);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final m = membership;
    final c = creator;
    final now = DateTime.now();
    final (status, tone) = m.isActive
        ? m.isDue(now)
              ? (l10n.membershipDue, context.kahwa.warning)
              : (
                  l10n.renewsOn(context.date(m.nextCharge)),
                  context.kahwa.success,
                )
        : m.isPaidAt(now)
        ? (l10n.cancelledUntil(context.date(m.nextCharge)), context.kahwa.muted)
        : (l10n.membershipEnded, context.kahwa.muted);

    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (c != null)
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => context.push(Routes.page(c)),
                  child: ProfileAvatar(profile: c, size: 48),
                ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c?.name ?? '', style: context.text.titleMedium),
                    Text(
                      '${m.tierName} · ${context.money(m.total, m.currency)} ${l10n.perMonth}',
                      style: context.text.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.circle, size: 10, color: tone),
              const SizedBox(width: 8),
              Expanded(child: Text(status, style: context.text.bodySmall)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (m.isActive)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _cancel(context, ref),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                    ),
                    child: Text(l10n.cancelMembership),
                  ),
                ),
              if (m.isActive) const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: c == null
                      ? null
                      : () => context
                            .push(
                              Routes.support(
                                c.id,
                                username: c.username,
                                tier: m.tierId,
                                currency: m.currency,
                              ),
                            )
                            .then((_) => ref.invalidate(myMembershipsProvider)),
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
                  child: Text(
                    m.isActive
                        ? l10n.changeTier
                        : m.canResume(DateTime.now())
                        ? l10n.resume
                        : l10n.rejoin,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
