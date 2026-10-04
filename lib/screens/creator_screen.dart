import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kahwa/core/config.dart';
import 'package:kahwa/core/feedback.dart';
import 'package:kahwa/core/formatters.dart';
import 'package:kahwa/core/responsive.dart';
import 'package:kahwa/core/router.dart';
import 'package:kahwa/core/theme.dart';
import 'package:kahwa/data/repositories.dart';
import 'package:kahwa/models/app_user.dart';
import 'package:kahwa/models/donation.dart';
import 'package:kahwa/models/goal.dart';
import 'package:kahwa/widgets/async_body.dart';
import 'package:kahwa/widgets/creator_counter_card.dart';
import 'package:kahwa/widgets/goal_card.dart';
import 'package:kahwa/widgets/page_body.dart';
import 'package:kahwa/widgets/supporter_card.dart';
import 'package:kahwa/widgets/user_avatar.dart';
import 'package:readmore/readmore.dart';
import 'package:share_plus/share_plus.dart';

/// Everything shown on the page of a creator.
class _CreatorPage {
  _CreatorPage({required this.creator, this.goal, required this.donations});

  final AppUser creator;
  final Goal? goal;
  final List<DonationSupporter> donations;

  late final int supporters = {
    for (final item in donations) item.donation.supporterId,
  }.length;

  late final int kahwas = donations.fold(
    0,
    (sum, item) => sum + item.donation.kahwas,
  );
}

class CreatorScreen extends StatefulWidget {
  const CreatorScreen({super.key, required this.creatorId});

  final String creatorId;

  @override
  State<CreatorScreen> createState() => _CreatorScreenState();
}

class _CreatorScreenState extends State<CreatorScreen> {
  late Future<_CreatorPage> _page;

  String get _userId => authRepository.userId;

  bool get _isOwner => _userId == widget.creatorId;

  @override
  void initState() {
    super.initState();
    _page = _load();
  }

  @override
  void didUpdateWidget(CreatorScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.creatorId != widget.creatorId) _page = _load();
  }

  Future<_CreatorPage> _load() async {
    final (creator, goal, donations) = await (
      userRepository.getUser(widget.creatorId),
      goalRepository.getGoal(widget.creatorId),
      donationRepository.getDonations(
        creatorId: widget.creatorId,
        viewerId: _userId,
      ),
    ).wait;

    if (creator == null) throw StateError('Creator not found');
    return _CreatorPage(creator: creator, goal: goal, donations: donations);
  }

  void _reload() {
    if (!mounted) return;
    setState(() => _page = _load());
  }

  /// Opens [location] and refreshes the page when the user comes back.
  Future<void> _open(String location) async {
    await context.push(location);
    _reload();
  }

  /// Updates the page right away and puts it back if saving fails.
  Future<void> _toggleFan(_CreatorPage page) async {
    final creator = page.creator;
    final isFan = !creator.hasFan(_userId);
    final fans = isFan
        ? [...creator.fans, _userId]
        : creator.fans.where((id) => id != _userId).toList();

    setState(() {
      _page = SynchronousFuture(
        _CreatorPage(
          creator: creator.copyWith(fans: fans),
          goal: page.goal,
          donations: page.donations,
        ),
      );
    });
    try {
      await userRepository.setFan(
        creatorId: creator.id,
        userId: _userId,
        isFan: isFan,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _page = SynchronousFuture(page));
      showSnack(context, 'Could not update, try again');
    }
  }

  void _share() {
    SharePlus.instance.share(
      ShareParams(uri: Uri.parse(AppConfig.creatorLink(widget.creatorId))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            context.canPop() ? context.pop() : context.go(Routes.home);
          },
        ),
        actions: [
          if (AppConfig.appUrl.isNotEmpty)
            IconButton(
              onPressed: _share,
              tooltip: 'Share',
              icon: const Icon(Icons.share_rounded),
            ),
          SizedBox(width: context.pagePadding - 16),
        ],
      ),
      body: AsyncBody(
        future: _page,
        onRetry: _reload,
        builder: (context, page) {
          return Theme(
            data: appTheme(primary: page.creator.color.color),
            child: Builder(builder: (context) => _buildPage(context, page)),
          );
        },
      ),
    );
  }

  Widget _buildPage(BuildContext context, _CreatorPage page) {
    final profile = _buildProfile(context, page);
    final supporters = _buildSupporters(page);

    if (context.isExpanded) {
      return PageBody(
        maxWidth: ContentWidth.wide,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 400, child: profile),
            const SizedBox(width: 48),
            Expanded(child: supporters),
          ],
        ),
      );
    }

    return PageBody(
      maxWidth: ContentWidth.list,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [profile, const SizedBox(height: 24), supporters],
      ),
    );
  }

  Widget _buildProfile(BuildContext context, _CreatorPage page) {
    final creator = page.creator;
    final goal = page.goal;
    final about = creator.about ?? '';
    final website = creator.website ?? '';
    final fans = creator.fans.length;
    final theme = Theme.of(context);
    final linkStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w700,
      color: theme.colorScheme.primary,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: UserAvatar(
            name: creator.name,
            image: creator.image,
            radius: context.isCompact ? 64 : 80,
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            creator.name,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: CreatorCounterCard(
                counter: fans,
                title: pluralWord(fans, 'Fan'),
                onTap: _isOwner && fans > 0
                    ? () => context.push(Routes.fans(creator.id))
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CreatorCounterCard(
                counter: page.supporters,
                title: pluralWord(page.supporters, 'Supporter'),
                onTap: _isOwner && page.supporters > 0
                    ? () => context.push(Routes.supporters(creator.id))
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CreatorCounterCard(
                counter: page.kahwas,
                title: pluralWord(page.kahwas, 'kahwa'),
              ),
            ),
          ],
        ),
        if (!_isOwner) ...[
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _open(Routes.donate(creator.id)),
                  icon: Image.asset('assets/cup.png', width: 24),
                  label: const Text('Buy a kahwa'),
                ),
              ),
              const SizedBox(width: 16),
              _FanButton(
                isFan: creator.hasFan(_userId),
                onTap: () => _toggleFan(page),
              ),
            ],
          ),
        ],
        if (goal != null) ...[
          const SizedBox(height: 24),
          GoalCard(
            goal: goal,
            onTap: _isOwner ? () => _open(Routes.goal) : null,
          ),
        ] else if (_isOwner) ...[
          const SizedBox(height: 24),
          AddGoalCard(onTap: () => _open(Routes.goal)),
        ],
        if (about.isNotEmpty) ...[
          const SizedBox(height: 24),
          const SectionTitle('About'),
          const SizedBox(height: 8),
          ReadMoreText(
            about,
            style: theme.textTheme.bodyMedium,
            trimMode: TrimMode.Line,
            trimLines: 3,
            trimCollapsedText: 'Show More',
            trimExpandedText: ' Show Less',
            moreStyle: linkStyle,
            lessStyle: linkStyle,
          ),
        ],
        if (website.isNotEmpty) ...[
          const SizedBox(height: 16),
          InkWell(
            onTap: () => openLink(context, _websiteUri(website)),
            child: Row(
              children: [
                const Icon(Icons.link_rounded),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    website,
                    overflow: TextOverflow.ellipsis,
                    style: linkStyle?.copyWith(fontWeight: FontWeight.w400),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSupporters(_CreatorPage page) {
    if (page.donations.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Recent Supporters'),
        const SizedBox(height: 16),
        for (final donation in page.donations) ...[
          SupporterCard(donationSupporter: donation),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

/// Creators type their website with or without the scheme.
Uri? _websiteUri(String website) {
  final hasScheme = website.startsWith(RegExp(r'https?://'));
  return Uri.tryParse(hasScheme ? website : 'https://$website');
}

class _FanButton extends StatelessWidget {
  const _FanButton({required this.isFan, required this.onTap});

  final bool isFan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;

    return Tooltip(
      message: isFan ? 'Stop being a fan' : 'Become a fan',
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: color),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isFan
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: color,
                ),
                Text('Fan', style: theme.textTheme.labelSmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
