import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kahwa/models/donation.dart';
import 'package:kahwa/models/membership.dart';
import 'package:kahwa/router.dart';
import 'package:kahwa/state/providers.dart';
import 'package:kahwa/theme/app_theme.dart';
import 'package:kahwa/ui/avatar.dart';
import 'package:kahwa/ui/context.dart';
import 'package:kahwa/ui/widgets.dart';

final _membersProvider = FutureProvider.autoDispose<List<Membership>>((ref) {
  final id = ref.watch(userIdProvider);
  if (id == null) return Future.value(const []);
  return ref.watch(supportRepositoryProvider).membersOf(id);
});

/// Who supports the creator: members, and everyone who bought kahwas.
class SupportersScreen extends ConsumerWidget {
  const SupportersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final id = ref.watch(userIdProvider) ?? '';
    final donations = ref.watch(donationsToProvider(id));
    final members = ref.watch(_membersProvider);
    final now = DateTime.now();

    return TitledPage(
      title: l10n.supportersAndMembers,
      maxWidth: TitledPage.wideMaxWidth,
      onRefresh: () async {
        ref
          ..invalidate(donationsToProvider(id))
          ..invalidate(_membersProvider);
      },
      children: [
        // Side by side on a wide screen: members, and everyone who bought.
        WideColumns(
          startFlex: 1,
          endFlex: 1,
          start: [
            SectionTitle(l10n.memberships),
            AsyncView(
              value: members,
              onRetry: () => ref.invalidate(_membersProvider),
              builder: (list) {
                final current = list.where((m) => m.isPaidAt(now)).toList();
                if (current.isEmpty) {
                  return Text(
                    l10n.noMembersYet,
                    style: context.text.bodyMedium?.copyWith(
                      color: context.kahwa.muted,
                    ),
                  );
                }
                final people =
                    ref
                        .watch(
                          profilesProvider(
                            ProfileIds(current.map((m) => m.supporterId)),
                          ),
                        )
                        .valueOrNull ??
                    const {};
                return TileGroup(
                  children: [
                    for (final m in current)
                      ListTile(
                        onTap: people[m.supporterId] == null
                            ? null
                            : () => context.push(
                                Routes.page(people[m.supporterId]!),
                              ),
                        leading: ProfileAvatar(profile: people[m.supporterId]),
                        title: Text(people[m.supporterId]?.name ?? ''),
                        subtitle: Text(
                          m.isActive
                              ? '${m.tierName} · ${l10n.renewsOn(context.date(m.nextCharge))}'
                              : '${m.tierName} · ${l10n.cancelledUntil(context.date(m.nextCharge))}',
                        ),
                        trailing: Text(
                          context.money(m.total, m.currency),
                          style: context.text.titleSmall,
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 28),
          ],
          end: [
            SectionTitle(l10n.allSupporters),
            AsyncView(
              value: donations,
              onRetry: () => ref.invalidate(donationsToProvider(id)),
              builder: (list) {
                final supporters = SupporterSummary.of(list);
                if (supporters.isEmpty) {
                  return EmptyState(
                    icon: Icons.coffee_rounded,
                    title: l10n.noSupportersYet,
                    message: l10n.noSupportersBody,
                  );
                }
                final people =
                    ref
                        .watch(
                          profilesProvider(
                            ProfileIds(supporters.map((s) => s.supporterId)),
                          ),
                        )
                        .valueOrNull ??
                    const {};
                return TileGroup(
                  children: [
                    for (final s in supporters)
                      ListTile(
                        onTap: people[s.supporterId] == null
                            ? null
                            : () => context.push(
                                Routes.page(people[s.supporterId]!),
                              ),
                        leading: ProfileAvatar(profile: people[s.supporterId]),
                        title: Text(people[s.supporterId]?.name ?? ''),
                        subtitle: Text(
                          l10n.supporterSummary(s.count, context.ago(s.last)),
                        ),
                        trailing: Text(
                          l10n.kahwasCount(s.kahwas),
                          style: context.text.titleSmall,
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
