import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kahwa/features/me/security_screen.dart';
import 'package:kahwa/core/money.dart';
import 'package:kahwa/core/text.dart';
import 'package:kahwa/features/creator/share_sheet.dart';
import 'package:kahwa/models/membership.dart';
import 'package:kahwa/models/money_requests.dart';
import 'package:kahwa/models/post.dart';
import 'package:kahwa/models/profile.dart';
import 'package:kahwa/router.dart';
import 'package:kahwa/state/providers.dart';
import 'package:kahwa/theme/app_theme.dart';
import 'package:kahwa/ui/avatar.dart';
import 'package:kahwa/ui/context.dart';
import 'package:kahwa/ui/post_card.dart';
import 'package:kahwa/ui/widgets.dart';

/// Posts of the creators the user is a fan of, newest first.
final _feedProvider = FutureProvider.autoDispose<List<Post>>((ref) async {
  final creators = await ref.watch(myCreatorsProvider.future);
  return ref
      .watch(postRepositoryProvider)
      .feed(
        creators.map((c) => c.id).toList(),
        viewerId: ref.watch(userIdProvider),
      );
});

final _myGoalSetProvider = FutureProvider.autoDispose<bool>((ref) async {
  final id = ref.watch(userIdProvider);
  if (id == null) return false;
  return await ref.watch(supportRepositoryProvider).getGoal(id) != null;
});

final _myPostsCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final id = ref.watch(userIdProvider);
  if (id == null) return 0;
  return (await ref.watch(postRepositoryProvider).postsOf(id)).length;
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    // Profile, wallet and inbox, shown on this screen too.
    refreshMyData(ref.invalidate);
    ref
      ..invalidate(myCreatorsProvider)
      ..invalidate(pendingKahwaProvider)
      ..invalidate(myMembershipsProvider)
      ..invalidate(_myGoalSetProvider)
      ..invalidate(_myPostsCountProvider);
    await ref.read(_feedProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final me = ref.watch(myProfileProvider).valueOrNull;
    if (me == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final creators = ref.watch(myCreatorsProvider);
    final feed = ref.watch(_feedProvider);
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? l10n.goodMorning(firstNameOf(me.name))
        : hour < 18
        ? l10n.goodAfternoon(firstNameOf(me.name))
        : l10n.goodEvening(firstNameOf(me.name));

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: ListView(
          children: [
            PageFrame(
              maxWidth: 720,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SafeArea(
                    bottom: false,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            greeting,
                            style: context.text.headlineMedium,
                          ),
                        ),
                        const _WalletChip(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const _Alerts(),
                  if (me.isCreator) _Checklist(me: me) else _StartPageCard(),
                  const SizedBox(height: 28),
                  SectionTitle(
                    l10n.yourCreators,
                    action: l10n.explore,
                    onAction: () => context.go(Routes.explore),
                  ),
                  AsyncView(
                    value: creators,
                    onRetry: () => ref.invalidate(myCreatorsProvider),
                    builder: (list) => list.isEmpty
                        ? Panel(
                            child: EmptyState(
                              icon: Icons.favorite_rounded,
                              title: l10n.noCreatorsTitle,
                              message: l10n.noCreatorsBody,
                              action: FilledButton(
                                onPressed: () => context.go(Routes.explore),
                                child: Text(l10n.exploreCreators),
                              ),
                            ),
                          )
                        : _CreatorStrip(creators: list),
                  ),
                  const SizedBox(height: 28),
                  SectionTitle(l10n.latestPosts),
                  AsyncView(
                    value: feed,
                    onRetry: () => ref.invalidate(_feedProvider),
                    builder: (posts) {
                      if (posts.isEmpty) {
                        return Text(
                          l10n.feedEmpty,
                          style: context.text.bodyMedium?.copyWith(
                            color: context.kahwa.muted,
                          ),
                        );
                      }
                      final byId = {
                        for (final c in creators.valueOrNull ?? <Profile>[])
                          c.id: c,
                      };
                      return Column(
                        children: [
                          for (final post in posts) ...[
                            PostCard(
                              post: post,
                              creator: byId[post.creatorId],
                              showCreator: true,
                              onChanged: () => ref.invalidate(_feedProvider),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletChip extends ConsumerWidget {
  const _WalletChip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(myWalletProvider).valueOrNull;
    final current = wallet?.current ?? const Amounts();
    // One line per currency the user holds.
    final lines = current.isZero
        ? [context.l10n.topUp]
        : [
            if (current.lbp > 0)
              context.moneyCompact(current.lbp, Currency.lbp),
            if (current.usd > 0)
              context.moneyCompact(current.usd, Currency.usd),
          ];
    void open() => context.push(Routes.wallet);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(color: context.kahwa.border),
    );
    return Semantics(
      container: true,
      button: true,
      label: lines.join(', '),
      onTap: open,
      excludeSemantics: true,
      child: Material(
        shape: shape,
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: open,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 18,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    for (final line in lines)
                      Text(
                        line,
                        style: context.text.labelLarge,
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Things waiting on the user: a membership that could not renew, a kahwa
/// left for a top up, a top up being checked.
class _Alerts extends ConsumerWidget {
  const _Alerts();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final unpaid = ref.watch(unpaidMembershipsProvider);
    final pending = ref.watch(pendingKahwaProvider).valueOrNull;
    final topUp = ref.watch(myTopUpProvider).valueOrNull;
    final ids = ProfileIds([
      ...unpaid.map((m) => m.creatorId),
      ?pending?.creatorId,
    ]);
    final names = ref.watch(profilesProvider(ids)).valueOrNull ?? const {};

    final auth = ref.watch(authRepositoryProvider);
    final alerts = <Widget>[
      if (!(ref.watch(emailVerifiedProvider).valueOrNull ??
              auth.emailVerified) &&
          auth.email != null)
        Notice(
          tone: Tone.warning,
          icon: Icons.mark_email_unread_rounded,
          title: l10n.verifyEmailTitle,
          message: l10n.verifyEmailBanner(auth.email!),
          action: FilledButton(
            onPressed: () => sendVerification(context, ref),
            style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
            child: Text(l10n.sendLink),
          ),
        ),
      for (final Membership m in unpaid)
        Notice(
          tone: Tone.danger,
          title: l10n.membershipUnpaidTitle,
          message: l10n.membershipUnpaidBody(
            names[m.creatorId]?.name ?? '',
            context.money(m.total, m.currency),
          ),
          action: FilledButton(
            onPressed: () => context.push(
              Routes.topUp(amount: m.total, currency: m.currency),
            ),
            style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
            child: Text(l10n.topUp),
          ),
        ),
      if (pending != null)
        _PendingCard(pending: pending, creator: names[pending.creatorId]),
      if (topUp != null && topUp.isPending)
        Notice(
          tone: Tone.warning,
          title: l10n.topUpCheckingTitle,
          message: l10n.topUpChecking(
            context.money(topUp.amount, topUp.currency),
          ),
        ),
    ];
    if (alerts.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        for (final alert in alerts) ...[alert, const SizedBox(height: 12)],
        const SizedBox(height: 8),
      ],
    );
  }
}

class _PendingCard extends ConsumerWidget {
  const _PendingCard({required this.pending, required this.creator});

  final PendingKahwa pending;
  final Profile? creator;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = creator;
    // A membership left waiting is named by its tier, not its kahwas.
    final tier = pending.tierId == null ? null : c?.tier(pending.tierId!);
    return Panel(
      color: context.colors.primaryContainer,
      child: Row(
        children: [
          if (c != null) ProfileAvatar(profile: c, size: 44),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tier == null
                      ? l10n.finishKahwaTitle
                      : l10n.finishMembershipTitle,
                  style: context.text.titleSmall,
                ),
                Text(
                  tier == null
                      ? l10n.finishKahwaBody(pending.kahwas, c?.name ?? '')
                      : l10n.finishMembershipBody(tier.name, c?.name ?? ''),
                  style: context.text.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: l10n.forget,
            onPressed: () async {
              final id = ref.read(userIdProvider);
              if (id == null) return;
              await ref.read(supportRepositoryProvider).clearPending(id);
              ref.invalidate(pendingKahwaProvider);
            },
            icon: const Icon(Icons.close_rounded),
          ),
          FilledButton(
            onPressed: () => context
                .push(Routes.support(pending.creatorId))
                .then((_) => ref.invalidate(pendingKahwaProvider)),
            style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
            child: Text(l10n.finish),
          ),
        ],
      ),
    );
  }
}

class _StartPageCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Panel(
      onTap: () => context.push(Routes.prices),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: context.colors.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.brush_rounded, color: context.colors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.startPageTitle, style: context.text.titleMedium),
                Text(
                  l10n.startPageBody,
                  style: context.text.bodySmall?.copyWith(
                    color: context.kahwa.muted,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_rounded, color: context.colors.primary),
        ],
      ),
    );
  }
}

/// What a new creator can still do to make their page complete.
class _Checklist extends ConsumerWidget {
  const _Checklist({required this.me});

  final Profile me;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final hasGoal = ref.watch(_myGoalSetProvider).valueOrNull ?? true;
    final posts = ref.watch(_myPostsCountProvider).valueOrNull ?? 1;
    final items = [
      (me.username != null, l10n.checkUsername, Routes.editPage),
      (me.about.isNotEmpty, l10n.checkAbout, Routes.editPage),
      (me.links.isNotEmpty, l10n.checkLinks, Routes.editPage),
      (hasGoal, l10n.checkGoal, Routes.goal),
      (me.tiers.isNotEmpty, l10n.checkTiers, Routes.prices),
      (posts > 0, l10n.checkPost, Routes.post),
    ];
    final done = items.where((i) => i.$1).length;
    if (done == items.length) return const SizedBox.shrink();
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(l10n.setUpPage, style: context.text.titleMedium),
              ),
              Text(
                '$done/${items.length}',
                style: context.text.labelLarge?.copyWith(
                  color: context.kahwa.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: LinearProgressIndicator(
              value: done / items.length,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          for (final (isDone, label, route) in items)
            if (!isDone)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.radio_button_unchecked_rounded,
                  color: context.colors.primary,
                ),
                title: Text(label, style: context.text.bodyLarge),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push(route).then((_) {
                  ref
                    ..invalidate(_myGoalSetProvider)
                    ..invalidate(_myPostsCountProvider);
                }),
              ),
          const SizedBox(height: 4),
          OutlinedButton.icon(
            onPressed: () => showShareSheet(context, me),
            icon: const Icon(Icons.ios_share_rounded),
            label: Text(l10n.shareMyPage),
          ),
        ],
      ),
    );
  }
}

class _CreatorStrip extends StatelessWidget {
  const _CreatorStrip({required this.creators});

  final List<Profile> creators;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: creators.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          final c = creators[i];
          return InkWell(
            borderRadius: BorderRadius.circular(Radii.tile),
            onTap: () => context.push(Routes.page(c)),
            child: SizedBox(
              width: 76,
              child: Column(
                children: [
                  ProfileAvatar(profile: c, size: 68),
                  const SizedBox(height: 6),
                  Text(
                    firstNameOf(c.name),
                    style: context.text.labelLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
