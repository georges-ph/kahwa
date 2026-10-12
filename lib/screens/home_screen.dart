import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kahwa/core/feedback.dart';
import 'package:kahwa/core/responsive.dart';
import 'package:kahwa/core/router.dart';
import 'package:kahwa/data/repositories.dart';
import 'package:kahwa/models/app_user.dart';
import 'package:kahwa/widgets/async_body.dart';
import 'package:kahwa/widgets/creator_card.dart';
import 'package:kahwa/widgets/page_body.dart';
import 'package:kahwa/widgets/user_avatar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<AppUser>> _creators;

  @override
  void initState() {
    super.initState();
    _creators = _load();
  }

  Future<List<AppUser>> _load() {
    return userRepository.getCreatorsFollowedBy(authRepository.userId);
  }

  void _reload() {
    if (!mounted) return;
    setState(() => _creators = _load());
  }

  /// Loads the list again while keeping what is on screen.
  Future<void> _refresh() async {
    try {
      final creators = await _load();
      if (mounted) setState(() => _creators = SynchronousFuture(creators));
    } catch (_) {
      if (mounted) showSnack(context, 'Could not refresh, try again');
    }
  }

  /// Opens [location] and refreshes the list when the user comes back, since
  /// they may have become a fan of someone or stopped being one.
  Future<void> _open(String location) async {
    await context.push(location);
    await _refresh();
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
                  onTap: () => _open(Routes.creator(authRepository.userId)),
                  child: UserAvatar(name: user?.displayName ?? ''),
                ),
              );
            },
          ),
          SizedBox(width: context.pagePadding - 8),
        ],
      ),
      body: AsyncBody(
        future: _creators,
        onRetry: _reload,
        builder: (context, creators) {
          return PageBody(
            maxWidth: ContentWidth.wide,
            onRefresh: _refresh,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PageTitle('Home'),
                const SizedBox(height: 24),
                if (creators.isEmpty)
                  const _NoCreators()
                else ...[
                  const SectionTitle('Creators you are a fan of'),
                  const SizedBox(height: 16),
                  _CreatorGrid(
                    creators: creators,
                    onTap: (creator) => _open(Routes.creator(creator.id)),
                  ),
                ],
              ],
            ),
          );
        },
      ),
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
