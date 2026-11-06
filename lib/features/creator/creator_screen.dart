import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kahwa/core/money.dart';
import 'package:kahwa/core/text.dart';
import 'package:kahwa/features/creator/share_sheet.dart';
import 'package:kahwa/features/creator/wall.dart';
import 'package:kahwa/features/support/support_screen.dart';
import 'package:kahwa/models/donation.dart';
import 'package:kahwa/models/membership.dart';
import 'package:kahwa/models/profile.dart';
import 'package:kahwa/models/tier.dart';
import 'package:kahwa/router.dart';
import 'package:kahwa/state/providers.dart';
import 'package:kahwa/theme/app_theme.dart';
import 'package:kahwa/ui/avatar.dart';
import 'package:kahwa/ui/context.dart';
import 'package:kahwa/ui/cover.dart';
import 'package:kahwa/ui/goal_card.dart';
import 'package:kahwa/ui/labels.dart';
import 'package:kahwa/ui/post_card.dart';
import 'package:kahwa/ui/widgets.dart';

/// Opens the page of whoever holds [username].
class UsernameScreen extends ConsumerWidget {
  const UsernameScreen({
    super.key,
    required this.username,
    this.builder = _page,
  });

  final String username;

  /// The screen to show for the creator once their id is known: their page,
  /// unless told otherwise.
  final Widget Function(String id) builder;

  static Widget _page(String id) => CreatorScreen(creatorId: id);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(usernameProvider(username.toLowerCase()));
    return id.when(
      data: (id) => id == null ? const _NotFound() : builder(id),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => Scaffold(
        appBar: AppBar(),
        body: ErrorView(
          onRetry: () => ref.invalidate(usernameProvider(username)),
        ),
      ),
    );
  }
}

enum _Tab { wall, posts, members, about }

class CreatorScreen extends ConsumerStatefulWidget {
  const CreatorScreen({super.key, required this.creatorId});

  final String creatorId;

  @override
  ConsumerState<CreatorScreen> createState() => _CreatorScreenState();
}

class _CreatorScreenState extends ConsumerState<CreatorScreen> {
  var _tab = _Tab.wall;
  bool _fanBusy = false;

  String get _id => widget.creatorId;

  void _refresh() {
    ref.invalidate(donationsToProvider(_id));
    ref.invalidate(postsOfProvider(_id));
    ref.invalidate(myMembershipsProvider);
  }

  /// Sends a visitor to sign in, then back here.
  bool _needsAccount() {
    if (ref.read(userIdProvider) != null) return false;
    context.push(Routes.signInThen(GoRouterState.of(context).uri.toString()));
    return true;
  }

  Future<void> _toggleFan(Profile creator) async {
    if (_needsAccount()) return;
    final me = ref.read(myProfileProvider).valueOrNull;
    if (me == null || _fanBusy) return;
    setState(() => _fanBusy = true);
    try {
      await ref
          .read(profileRepositoryProvider)
          .setFan(creatorId: creator.id, me: me, fan: !creator.isFan(me.id));
      refreshMyData(ref.invalidate);
      ref.invalidate(myCreatorsProvider);
    } catch (_) {
      if (mounted) showSnack(context, context.l10n.somethingWrong);
    } finally {
      if (mounted) setState(() => _fanBusy = false);
    }
  }

  void _support({Tier? tier}) {
    if (_needsAccount()) return;
    final username = ref.read(profileProvider(_id)).valueOrNull?.username;
    context
        .push(
          Routes.support(_id, username: username, tier: tier?.id),
          extra: SupportOpenedFrom.page,
        )
        .then((_) => _refresh());
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider(_id));
    return profile.when(
      skipLoadingOnReload: true,
      data: (creator) =>
          creator == null ? const _NotFound() : _page(context, creator),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => Scaffold(
        appBar: AppBar(),
        body: ErrorView(onRetry: () => ref.invalidate(profileProvider(_id))),
      ),
    );
  }

  Widget _page(BuildContext context, Profile creator) {
    final base = Theme.of(context);
    final theme = buildTheme(
      brightness: base.brightness,
      accent: Color(creator.color),
      arabic: context.isArabic,
    );
    return Theme(
      data: theme,
      child: Builder(builder: (context) => _themedPage(context, creator)),
    );
  }

  Widget _themedPage(BuildContext context, Profile creator) {
    final l10n = context.l10n;
    final meId = ref.watch(userIdProvider);
    final isOwner = meId == creator.id;
    final donations =
        ref.watch(donationsToProvider(_id)).valueOrNull ?? const <Donation>[];
    final counts = PageCounts.of(donations);
    final wide = context.isWide;
    final tabs = [
      _Tab.wall,
      _Tab.posts,
      if (creator.tiers.isNotEmpty) _Tab.members,
      _Tab.about,
    ];
    if (!tabs.contains(_tab)) _tab = _Tab.wall;

    final header = _Header(
      creator: creator,
      counts: counts,
      onFans: () => setState(() => _tab = _Tab.about),
    );
    final tabBar = _TabStrip(
      tabs: tabs,
      selected: _tab,
      onSelected: (t) => setState(() => _tab = t),
    );
    final content = _TabContent(
      tab: _tab,
      creator: creator,
      onChanged: _refresh,
      onJoin: (tier) => _support(tier: tier),
    );
    final goal = ref.watch(goalProvider(_id)).valueOrNull;
    final actions = _Actions(
      creator: creator,
      isOwner: isOwner,
      fanBusy: _fanBusy,
      onSupport: () => _support(),
      onFan: () => _toggleFan(creator),
    );

    final body = wide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 340,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    header,
                    const SizedBox(height: 18),
                    actions,
                    if (goal != null) ...[
                      const SizedBox(height: 18),
                      GoalCard(goal: goal),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 70),
                    tabBar,
                    const SizedBox(height: 16),
                    content,
                  ],
                ),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              if (goal != null) ...[
                const SizedBox(height: 16),
                GoalCard(goal: goal, compact: true),
              ],
              const SizedBox(height: 16),
              tabBar,
              const SizedBox(height: 16),
              content,
            ],
          );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        actions: [
          _RoundIcon(
            icon: Icons.ios_share_rounded,
            tooltip: l10n.share,
            onTap: () => showShareSheet(context, creator),
          ),
          if (isOwner)
            _RoundIcon(
              icon: Icons.edit_rounded,
              tooltip: l10n.editPage,
              onTap: () => context.push(Routes.editPage),
            ),
          const SizedBox(width: 12),
        ],
        leading: Navigator.canPop(context) || context.canPop()
            ? Padding(
                padding: const EdgeInsets.all(6),
                child: _RoundIcon(
                  icon: Icons.arrow_back_rounded,
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  onTap: () => context.pop(),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(6),
                child: _RoundIcon(
                  icon: Icons.home_rounded,
                  tooltip: l10n.tabHome,
                  onTap: () => context.go(Routes.home),
                ),
              ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _refresh();
          await ref.read(donationsToProvider(_id).future);
        },
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            CoverBanner(
              color: Color(creator.color),
              pattern: CoverPattern.of(creator.cover),
              height: wide ? 240 : 190,
            ),
            PageFrame(
              maxWidth: 1080,
              padding: EdgeInsets.fromLTRB(20, 0, 20, wide ? 48 : 120),
              child: body,
            ),
          ],
        ),
      ),
      bottomNavigationBar: wide
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  border: Border(top: BorderSide(color: context.kahwa.border)),
                ),
                child: actions,
              ),
            ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.creator,
    required this.counts,
    required this.onFans,
  });

  final Profile creator;
  final PageCounts counts;
  final VoidCallback onFans;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final category = creator.category;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The avatar sits half on the banner above.
        SizedBox(
          height: 64,
          child: OverflowBox(
            alignment: AlignmentDirectional.topStart,
            maxHeight: 120,
            child: Transform.translate(
              offset: const Offset(0, -52),
              child: ProfileAvatar(profile: creator, size: 104, ring: true),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(creator.name, style: context.text.headlineMedium),
            const SizedBox(height: 2),
            Wrap(
              spacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (creator.username != null)
                  Text(
                    '@${creator.username}',
                    style: context.text.bodyMedium?.copyWith(
                      color: context.kahwa.muted,
                    ),
                  ),
                if (category != null)
                  Chip(
                    visualDensity: VisualDensity.compact,
                    avatar: Icon(
                      category.icon,
                      size: 16,
                      color: context.colors.primary,
                    ),
                    label: Text(categoryLabel(context, category)),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
              ],
            ),
            if (creator.tagline.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(creator.tagline, style: context.text.bodyLarge),
            ],
            if (creator.links.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 4,
                children: [
                  for (final link in creator.links)
                    if (link.uri case final uri?)
                      IconButton.filledTonal(
                        tooltip: link.kind.label,
                        onPressed: () => openLink(context, uri),
                        icon: Icon(link.kind.icon, size: 18),
                      ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StatPill(
                    value: '${counts.kahwas}',
                    label: l10n.kahwasLabel(counts.kahwas),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatPill(
                    value: '${counts.supporters}',
                    label: l10n.supportersLabel(counts.supporters),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatPill(
                    value: '${creator.fans}',
                    label: l10n.fansLabel(creator.fans),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// The main buttons of a page: buy a kahwa and become a fan, or, on one's
/// own page, share it.
class _Actions extends ConsumerWidget {
  const _Actions({
    required this.creator,
    required this.isOwner,
    required this.fanBusy,
    required this.onSupport,
    required this.onFan,
  });

  final Profile creator;
  final bool isOwner;
  final bool fanBusy;
  final VoidCallback onSupport;
  final VoidCallback onFan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    if (isOwner) {
      return FilledButton.icon(
        onPressed: () => showShareSheet(context, creator),
        icon: const Icon(Icons.ios_share_rounded),
        label: Text(l10n.shareMyPage),
      );
    }
    final isFan = creator.isFan(ref.watch(userIdProvider));
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: creator.isCreator ? onSupport : null,
            icon: const KahwaCup(size: 24),
            label: Text(
              creator.isCreator
                  ? l10n.buyKahwaFor(firstNameOf(creator.name))
                  : l10n.notAcceptingYet,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 52,
          height: 52,
          child: OutlinedButton(
            onPressed: fanBusy ? null : onFan,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              side: BorderSide(color: context.colors.primary, width: 1.5),
            ),
            child: Tooltip(
              message: isFan ? l10n.unfan : l10n.becomeFan,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, a) =>
                    ScaleTransition(scale: a, child: child),
                child: Icon(
                  isFan
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  key: ValueKey(isFan),
                  color: context.colors.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TabStrip extends StatelessWidget {
  const _TabStrip({
    required this.tabs,
    required this.selected,
    required this.onSelected,
  });

  final List<_Tab> tabs;
  final _Tab selected;
  final ValueChanged<_Tab> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    String label(_Tab tab) => switch (tab) {
      _Tab.wall => l10n.tabWall,
      _Tab.posts => l10n.tabPosts,
      _Tab.members => l10n.tabMemberships,
      _Tab.about => l10n.tabAbout,
    };
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final tab in tabs)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: ChoiceChip(
                selected: tab == selected,
                onSelected: (_) => onSelected(tab),
                label: Text(label(tab)),
              ),
            ),
        ],
      ),
    );
  }
}

class _TabContent extends ConsumerWidget {
  const _TabContent({
    required this.tab,
    required this.creator,
    required this.onChanged,
    required this.onJoin,
  });

  final _Tab tab;
  final Profile creator;
  final VoidCallback onChanged;
  final ValueChanged<Tier> onJoin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = creator.id;
    return switch (tab) {
      _Tab.wall => AsyncView(
        value: ref.watch(donationsToProvider(id)),
        onRetry: () => ref.invalidate(donationsToProvider(id)),
        builder: (donations) =>
            Wall(creator: creator, donations: donations, onChanged: onChanged),
      ),
      _Tab.posts => _Posts(creator: creator, onChanged: onChanged),
      _Tab.members => _Memberships(creator: creator, onJoin: onJoin),
      _Tab.about => _About(creator: creator),
    };
  }
}

class _Posts extends ConsumerWidget {
  const _Posts({required this.creator, required this.onChanged});

  final Profile creator;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isOwner = ref.watch(userIdProvider) == creator.id;
    return AsyncView(
      value: ref.watch(postsOfProvider(creator.id)),
      onRetry: () => ref.invalidate(postsOfProvider(creator.id)),
      builder: (posts) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isOwner) ...[
            OutlinedButton.icon(
              onPressed: () =>
                  context.push(Routes.post).then((_) => onChanged()),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.newPost),
            ),
            const SizedBox(height: 12),
          ],
          if (posts.isEmpty)
            EmptyState(
              icon: Icons.article_rounded,
              title: l10n.postsEmptyTitle,
              message: isOwner
                  ? l10n.postsEmptyOwner
                  : l10n.postsEmptyBody(creator.name),
            ),
          for (final post in posts) ...[
            PostCard(post: post, creator: creator, onChanged: onChanged),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _Memberships extends ConsumerWidget {
  const _Memberships({required this.creator, required this.onJoin});

  final Profile creator;
  final ValueChanged<Tier> onJoin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isOwner = ref.watch(userIdProvider) == creator.id;
    final mine = (ref.watch(myMembershipsProvider).valueOrNull ?? const [])
        .where((m) => m.creatorId == creator.id)
        .firstOrNull;
    final now = DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.membershipsIntro(firstNameOf(creator.name)),
          style: context.text.bodyMedium?.copyWith(color: context.kahwa.muted),
        ),
        const SizedBox(height: 14),
        for (final tier in creator.tiers) ...[
          TierCard(
            creator: creator,
            tier: tier,
            current:
                mine != null && mine.tierId == tier.id && mine.isPaidAt(now)
                ? mine
                : null,
            onJoin: isOwner ? null : () => onJoin(tier),
          ),
          const SizedBox(height: 12),
        ],
        Text(
          l10n.membershipsHowItWorks,
          style: context.text.bodySmall?.copyWith(color: context.kahwa.muted),
        ),
      ],
    );
  }
}

/// A membership tier: its price each month and what it gives.
class TierCard extends StatelessWidget {
  const TierCard({
    super.key,
    required this.creator,
    required this.tier,
    this.current,
    this.onJoin,
  });

  final Profile creator;
  final Tier tier;

  /// The viewer's membership, when it is of this tier.
  final Membership? current;
  final VoidCallback? onJoin;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mine = current;
    String price(Currency c) =>
        context.money(tier.monthly(creator.price(c) ?? 0), c);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.card),
        side: BorderSide(
          color: mine != null ? context.colors.primary : context.kahwa.border,
          width: mine != null ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(tier.name, style: context.text.titleLarge),
                ),
                if (mine != null)
                  Chip(
                    label: Text(
                      mine.isActive
                          ? l10n.yourTier
                          : l10n.cancelledUntil(context.date(mine.nextCharge)),
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: price(Currency.lbp),
                    style: context.text.titleMedium,
                  ),
                  TextSpan(text: '  ·  ${price(Currency.usd)}  '),
                  TextSpan(
                    text: l10n.perMonth,
                    style: TextStyle(color: context.kahwa.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const KahwaCup(size: 18),
                const SizedBox(width: 6),
                Text(
                  l10n.kahwasEachMonth(tier.kahwas),
                  style: context.text.bodySmall?.copyWith(
                    color: context.kahwa.muted,
                  ),
                ),
              ],
            ),
            if (tier.perks.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(tier.perks, style: context.text.bodyMedium),
            ],
            if (onJoin != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: mine != null && mine.isActive
                    ? OutlinedButton(
                        onPressed: null,
                        child: Text(l10n.youAreMember),
                      )
                    : FilledButton(
                        onPressed: onJoin,
                        child: Text(mine != null ? l10n.rejoin : l10n.join),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _About extends ConsumerWidget {
  const _About({required this.creator});

  final Profile creator;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final goal = ref.watch(goalProvider(creator.id)).valueOrNull;
    final fans = ref.watch(
      profilesProvider(ProfileIds(creator.fanIds.take(30))),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (goal != null && !context.isWide) ...[
          GoalCard(goal: goal),
          const SizedBox(height: 16),
        ],
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.aboutTitle(firstNameOf(creator.name)),
                style: context.text.titleMedium,
              ),
              const SizedBox(height: 8),
              SelectableText(
                creator.about.isEmpty ? l10n.noAbout : creator.about,
                textDirection: creator.about.isEmpty
                    ? null
                    : textDirectionOf(creator.about),
                style: context.text.bodyLarge,
              ),
              if (creator.createdAt != null) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      size: 16,
                      color: context.kahwa.muted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.joinedOn(context.date(creator.createdAt)),
                      style: context.text.bodySmall?.copyWith(
                        color: context.kahwa.muted,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        if (creator.links.isNotEmpty) ...[
          const SizedBox(height: 16),
          TileGroup(
            children: [
              for (final link in creator.links)
                if (link.uri case final uri?)
                  NavTile(
                    icon: link.kind.icon,
                    title: link.kind.label,
                    subtitle: displayLink(uri),
                    onTap: () => openLink(context, uri),
                    trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                  ),
            ],
          ),
        ],
        if (creator.fanIds.isNotEmpty) ...[
          const SizedBox(height: 24),
          SectionTitle(l10n.fansTitle),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final fan in (fans.valueOrNull ?? const {}).values)
                Tooltip(
                  message: fan.name,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => context.push(Routes.page(fan)),
                    child: ProfileAvatar(profile: fan, size: 40),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.black.withValues(alpha: 0.28),
        shape: const CircleBorder(),
        child: IconButton(
          tooltip: tooltip,
          onPressed: onTap,
          icon: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: EmptyState(
          icon: Icons.search_off_rounded,
          title: l10n.pageNotFound,
          message: l10n.pageNotFoundBody,
          action: FilledButton(
            onPressed: () => context.go(Routes.explore),
            child: Text(l10n.exploreCreators),
          ),
        ),
      ),
    );
  }
}
