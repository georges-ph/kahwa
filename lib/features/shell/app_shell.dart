import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kahwa/models/profile.dart';
import 'package:kahwa/state/providers.dart';
import 'package:kahwa/theme/app_theme.dart';
import 'package:kahwa/ui/avatar.dart';
import 'package:kahwa/ui/context.dart';
import 'package:kahwa/ui/widgets.dart';

/// The frame around the four tabs: a bottom bar on phones, a rail on wider
/// screens. Visitors only see Explore, without either.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  /// The user whose memberships were renewed in this session.
  String? _renewedFor;

  @override
  void initState() {
    super.initState();
    ref.listenManual(myProfileProvider, (_, next) {
      final me = next.valueOrNull;
      if (me != null && me.onboarded && _renewedFor != me.id) {
        _renewedFor = me.id;
        _catchUp(me);
      }
    }, fireImmediately: true);
  }

  @override
  Widget build(BuildContext context) {
    // Back on another tab goes to Home first; back on Home leaves the app.
    // Pages opened inside a tab close before this is reached.
    return PopScope(
      canPop: widget.shell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) widget.shell.goBranch(0);
      },
      child: _shell(context),
    );
  }

  Widget _shell(BuildContext context) {
    final me = ref.watch(myProfileProvider).valueOrNull;
    final signedIn = ref.watch(userIdProvider) != null;
    if (!signedIn) return widget.shell;

    final unread = ref.watch(unreadCountProvider);
    final destinations = [
      (Icons.home_outlined, Icons.home_rounded, context.l10n.tabHome),
      (Icons.explore_outlined, Icons.explore_rounded, context.l10n.tabExplore),
      (
        Icons.notifications_none_rounded,
        Icons.notifications_rounded,
        context.l10n.tabActivity,
      ),
      (Icons.person_outline_rounded, Icons.person_rounded, context.l10n.tabMe),
    ];
    Widget icon(int index, IconData data) {
      final child = index == 3 && me != null
          ? ProfileAvatar(profile: me, size: 26)
          : Icon(data);
      if (index != 2 || unread == 0) return child;
      return Badge.count(count: unread, child: child);
    }

    if (context.isWide) {
      final extended = context.width >= Breakpoints.desktop;
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              extended: extended,
              minExtendedWidth: 220,
              selectedIndex: widget.shell.currentIndex,
              onDestinationSelected: _go,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: _Logo(extended: extended),
              ),
              destinations: [
                for (final (i, (outline, filled, label))
                    in destinations.indexed)
                  NavigationRailDestination(
                    icon: icon(i, outline),
                    selectedIcon: icon(i, filled),
                    label: Text(label),
                  ),
              ],
            ),
            VerticalDivider(width: 1, color: context.kahwa.border),
            // A container of its own: each page of the shell sits behind a
            // modal barrier that hides from screen readers everything drawn
            // before it in the same container, here the rail.
            Expanded(child: Semantics(container: true, child: widget.shell)),
          ],
        ),
      );
    }
    return Scaffold(
      body: widget.shell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: context.kahwa.border)),
        ),
        child: NavigationBar(
          selectedIndex: widget.shell.currentIndex,
          onDestinationSelected: _go,
          destinations: [
            for (final (i, (outline, filled, label)) in destinations.indexed)
              NavigationDestination(
                icon: icon(i, outline),
                selectedIcon: icon(i, filled),
                label: label,
              ),
          ],
        ),
      ),
    );
  }

  void _go(int index) {
    widget.shell.goBranch(
      index,
      initialLocation: index == widget.shell.currentIndex,
    );
  }

  /// What kahwa would do on a server: charge memberships whose month is
  /// over, and clean old read entries out of the inbox.
  Future<void> _catchUp(Profile me) async {
    try {
      final (:renewed, :unpaid) = await ref
          .read(supportRepositoryProvider)
          .renewDue(me);
      refreshMyData(ref.invalidate);
      if (!mounted) return;
      ref.read(unpaidMembershipsProvider.notifier).state = unpaid;
      ref.invalidate(myMembershipsProvider);
      // Posts read before the renewal were still locked.
      if (renewed > 0) {
        ref
          ..invalidate(postsOfProvider)
          ..invalidate(myCreatorsProvider);
      }
    } catch (_) {
      // Tried again the next time the app opens.
    }
    try {
      final activity = ref.read(activityRepositoryProvider);
      final entries = await ref.read(activityProvider.future);
      final stale = activity.stale(entries, DateTime.now());
      if (stale.isNotEmpty) await activity.delete(stale);
    } catch (_) {}
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.extended});

  final bool extended;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const KahwaCup(size: 34),
        if (extended) ...[
          const SizedBox(width: 10),
          Text('kahwa', style: context.text.headlineSmall),
        ],
      ],
    );
  }
}
