import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kahwa/core/colors.dart';
import 'package:kahwa/core/config.dart';
import 'package:kahwa/core/feedback.dart';
import 'package:kahwa/core/formatters.dart';
import 'package:kahwa/core/responsive.dart';
import 'package:kahwa/core/router.dart';
import 'package:kahwa/data/repositories.dart';
import 'package:kahwa/models/app_user.dart';
import 'package:kahwa/models/billing_details.dart';
import 'package:kahwa/models/pending_kahwa.dart';
import 'package:kahwa/widgets/async_body.dart';
import 'package:kahwa/widgets/creator_card.dart';
import 'package:kahwa/widgets/input_text.dart';
import 'package:kahwa/widgets/page_body.dart';
import 'package:kahwa/widgets/page_link_dialog.dart';
import 'package:kahwa/widgets/user_avatar.dart';

/// What the home screen shows: the creators the user is a fan of, and what
/// is still missing on their own page.
class _Home {
  const _Home({
    required this.creators,
    required this.me,
    required this.billing,
    this.pending,
    this.pendingCreator,
  });

  final List<AppUser> creators;
  final AppUser? me;
  final BillingDetails billing;

  /// The kahwa the user was buying when they went to top up, and for whom.
  final PendingKahwa? pending;
  final AppUser? pendingCreator;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<_Home> _data;

  final _searchController = TextEditingController();

  /// Every creator, loaded the first time the user searches.
  Future<List<AppUser>>? _everyone;

  String get _userId => authRepository.userId;

  String get _query => _searchController.text.trim();

  @override
  void initState() {
    super.initState();
    _data = _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<_Home> _load() async {
    final (creators, me, billing, pending) = await (
      userRepository.getCreatorsFollowedBy(_userId),
      userRepository.getUser(_userId),
      balanceRepository.getBillingDetails(_userId),
      donationRepository.getPending(_userId),
    ).wait;
    final pendingCreator = pending == null
        ? null
        : await userRepository.getUser(pending.creatorId);
    return _Home(
      creators: creators,
      me: me,
      billing: billing,
      pending: pending,
      pendingCreator: pendingCreator,
    );
  }

  Future<void> _forgetPending() async {
    try {
      await donationRepository.clearPending(_userId);
      await _refresh();
    } catch (_) {
      if (mounted) showSnack(context, 'Something went wrong, try again');
    }
  }

  void _reload() {
    if (!mounted) return;
    setState(() => _data = _load());
  }

  /// Loads the page again while keeping what is on screen.
  Future<void> _refresh() async {
    try {
      final data = await _load();
      if (mounted) setState(() => _data = SynchronousFuture(data));
    } catch (_) {
      if (mounted) showSnack(context, 'Could not refresh, try again');
    }
  }

  /// Opens [location] and refreshes the page when the user comes back, since
  /// they may have become a fan of someone or changed their own page.
  Future<void> _open(String location) async {
    await context.push(location);
    _everyone = null;
    await _refresh();
  }

  void _search(String _) {
    setState(() => _everyone ??= userRepository.getCreators());
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => _open(Routes.settings),
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_rounded),
          ),
          StreamBuilder(
            stream: authRepository.userChanges,
            builder: (context, snapshot) {
              final user = snapshot.data ?? authRepository.currentUser;
              return Tooltip(
                message: 'My page',
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => _open(Routes.creator(_userId)),
                  child: UserAvatar(name: user?.displayName ?? ''),
                ),
              );
            },
          ),
          SizedBox(width: context.pagePadding - 8),
        ],
      ),
      body: AsyncBody(
        future: _data,
        onRetry: _reload,
        builder: (context, data) {
          return PageBody(
            maxWidth: ContentWidth.wide,
            onRefresh: _refresh,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PageTitle('Home'),
                const SizedBox(height: 24),
                InputText(
                  controller: _searchController,
                  hint: 'Find a creator by name or username',
                  icon: Icons.search_rounded,
                  suffixIcon: _query.isEmpty ? null : Icons.close_rounded,
                  suffixTooltip: 'Clear',
                  suffixOnTap: _clearSearch,
                  textInputAction: TextInputAction.search,
                  onChanged: _search,
                ),
                const SizedBox(height: 24),
                if (_query.isNotEmpty)
                  _buildResults()
                else ...[
                  if ((data.pending, data.pendingCreator) case (
                    final pending?,
                    final creator?,
                  )) ...[
                    _PendingCard(
                      pending: pending,
                      creator: creator,
                      onFinish: () => _open(Routes.donate(creator.id)),
                      onForget: _forgetPending,
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (data.me case final me?
                      when !_SetUpCard.isDone(me, data.billing)) ...[
                    _SetUpCard(me: me, billing: data.billing, onOpen: _open),
                    const SizedBox(height: 24),
                  ],
                  if (data.creators.isEmpty)
                    const _NoCreators()
                  else ...[
                    const SectionTitle('Creators you are a fan of'),
                    const SizedBox(height: 16),
                    _CreatorGrid(
                      creators: data.creators,
                      onTap: (creator) => _open(Routes.creator(creator.id)),
                    ),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildResults() {
    return FutureBuilder(
      future: _everyone,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Could not search, try again');
        }
        final everyone = snapshot.data;
        if (everyone == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final found = [
          for (final creator in everyone)
            if (creator.id != _userId && creator.matches(_query)) creator,
        ];
        if (found.isEmpty) return const Text('No creator found');
        return _CreatorGrid(
          creators: found,
          onTap: (creator) => _open(Routes.creator(creator.id)),
        );
      },
    );
  }
}

/// The kahwa the user was buying when they went to top up, to finish it in
/// one tap once the money is in.
class _PendingCard extends StatelessWidget {
  const _PendingCard({
    required this.pending,
    required this.creator,
    required this.onFinish,
    required this.onForget,
  });

  final PendingKahwa pending;
  final AppUser creator;
  final VoidCallback onFinish;
  final VoidCallback onForget;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle(
              'Your ${plural(pending.kahwas, 'kahwa')} for ${creator.name}',
            ),
            const SizedBox(height: 4),
            const Text(
              'It is waiting for you. Once your top up is approved, finish it '
              'in one tap.',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: onFinish,
                  child: const Text('Finish'),
                ),
                TextButton(onPressed: onForget, child: const Text('Forget it')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The steps that make a new page ready to share, until they are all done.
class _SetUpCard extends StatelessWidget {
  const _SetUpCard({
    required this.me,
    required this.billing,
    required this.onOpen,
  });

  final AppUser me;
  final BillingDetails billing;
  final ValueChanged<String> onOpen;

  static bool isDone(AppUser me, BillingDetails billing) {
    return me.username != null &&
        (me.about ?? '').isNotEmpty &&
        !billing.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle('Set up your page'),
            const SizedBox(height: 4),
            const Text('A few steps before you share it.'),
            const SizedBox(height: 8),
            _Step(
              done: me.username != null,
              title: 'Pick a username for the address of your page',
              onTap: () => onOpen(Routes.profile),
            ),
            _Step(
              done: (me.about ?? '').isNotEmpty,
              title: 'Say a few words about what you make',
              onTap: () => onOpen(Routes.profile),
            ),
            _Step(
              done: !billing.isEmpty,
              title: 'Add your billing details, to withdraw what you receive',
              onTap: () => onOpen(Routes.billingDetails),
            ),
            if (AppConfig.appUrl.isNotEmpty) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => showPageLink(
                  context,
                  link: AppConfig.creatorLink(id: me.id, username: me.username),
                ),
                icon: const Icon(Icons.qr_code_rounded),
                label: const Text('Share your page'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.done, required this.title, required this.onTap});

  final bool done;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: done ? null : onTap,
      leading: Icon(
        done ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
        color: done ? Theme.of(context).colorScheme.primary : kGreyColor,
      ),
      title: Text(
        title,
        style: done
            ? const TextStyle(
                color: kGreyColor,
                decoration: TextDecoration.lineThrough,
              )
            : null,
      ),
      trailing: done ? null : const Icon(Icons.chevron_right_rounded),
    );
  }
}

class _NoCreators extends StatelessWidget {
  const _NoCreators();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320, maxHeight: 280),
            child: SvgPicture.asset('assets/undraw_not_found.svg'),
          ),
          const SizedBox(height: 24),
          Text(
            'You are not a fan of any creator yet',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Search for one above, or open the link a creator shared.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Creator cards in as many columns as fit the available width.
class _CreatorGrid extends StatelessWidget {
  const _CreatorGrid({required this.creators, required this.onTap});

  final List<AppUser> creators;
  final ValueChanged<AppUser> onTap;

  static const _spacing = 12.0;
  static const _minCardWidth = 320.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = (width / _minCardWidth).floor().clamp(1, 3);
        final cardWidth = (width - _spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: _spacing,
          runSpacing: _spacing,
          children: [
            for (final creator in creators)
              SizedBox(
                width: cardWidth,
                child: CreatorCard(
                  creator: creator,
                  onTap: () => onTap(creator),
                ),
              ),
          ],
        );
      },
    );
  }
}
