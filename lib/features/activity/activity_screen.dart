import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kahwa/core/text.dart';
import 'package:kahwa/models/activity.dart';
import 'package:kahwa/models/profile.dart';
import 'package:kahwa/router.dart';
import 'package:kahwa/state/providers.dart';
import 'package:kahwa/theme/app_theme.dart';
import 'package:kahwa/ui/avatar.dart';
import 'package:kahwa/ui/context.dart';
import 'package:kahwa/ui/widgets.dart';

/// The inbox: kahwas received, new fans, replies, answers to money requests.
class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  Future<void> _markAllRead() async {
    final entries = ref.read(activityProvider).valueOrNull ?? const [];
    try {
      await ref.read(activityRepositoryProvider).markRead(entries);
      refreshMyData(ref.invalidate);
    } catch (_) {
      if (mounted) showSnack(context, context.l10n.somethingWrong);
    }
  }

  Future<void> _clearRead() async {
    final entries = ref.read(activityProvider).valueOrNull ?? const [];
    final read = entries.where((a) => a.read);
    if (read.isEmpty) return;
    try {
      await ref.read(activityRepositoryProvider).delete(read);
      refreshMyData(ref.invalidate);
    } catch (_) {
      if (mounted) showSnack(context, context.l10n.somethingWrong);
    }
  }

  void _open(Activity entry) {
    ref.read(activityRepositoryProvider).markRead([entry]).ignore();
    final myPage = ref.read(myProfileProvider).valueOrNull;
    final route = switch (entry.kind) {
      ActivityKind.kahwa ||
      ActivityKind.membership => myPage == null ? null : Routes.page(myPage),
      ActivityKind.fan || ActivityKind.reply =>
        entry.actorId == null ? null : Routes.creator(entry.actorId!),
      ActivityKind.topUp || ActivityKind.withdraw => Routes.wallet,
      ActivityKind.adjustment => Routes.history,
      ActivityKind.directPayment => Routes.directPayments,
      ActivityKind.directAnswer => Routes.history,
    };
    if (route != null) context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final activity = ref.watch(activityProvider);
    final unread = ref.watch(unreadCountProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            PageFrame(
              maxWidth: 720,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.tabActivity,
                          style: context.text.headlineMedium,
                        ),
                      ),
                      if (unread > 0)
                        TextButton.icon(
                          onPressed: _markAllRead,
                          icon: const Icon(Icons.done_all_rounded),
                          label: Text(l10n.markAllRead),
                        ),
                      PopupMenuButton<String>(
                        onSelected: (_) => _clearRead(),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'clear',
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.delete_sweep_rounded),
                              title: Text(l10n.clearRead),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AsyncView(
                    value: activity,
                    onRetry: () => ref.invalidate(activityProvider),
                    builder: (entries) {
                      if (entries.isEmpty) {
                        return EmptyState(
                          icon: Icons.notifications_none_rounded,
                          title: l10n.activityEmptyTitle,
                          message: l10n.activityEmptyBody,
                        );
                      }
                      return _Grouped(entries: entries, onOpen: _open);
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

class _Grouped extends ConsumerWidget {
  const _Grouped({required this.entries, required this.onOpen});

  final List<Activity> entries;
  final ValueChanged<Activity> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    String group(Activity a) {
      final at = a.createdAt ?? now;
      if (!at.isBefore(today)) return l10n.today;
      if (today.difference(at).inDays < 7) return l10n.thisWeek;
      return l10n.earlier;
    }

    final actors = ref.watch(
      profilesProvider(ProfileIds(entries.map((e) => e.actorId).nonNulls)),
    );
    final byId = actors.valueOrNull ?? const {};

    final children = <Widget>[];
    String? current;
    for (final entry in entries) {
      final g = group(entry);
      if (g != current) {
        current = g;
        children.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
            child: Text(
              g,
              style: context.text.labelLarge?.copyWith(
                color: context.kahwa.muted,
              ),
            ),
          ),
        );
      }
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _Entry(
            entry: entry,
            actor: byId[entry.actorId],
            onTap: () => onOpen(entry),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

class _Entry extends StatelessWidget {
  const _Entry({required this.entry, required this.actor, required this.onTap});

  final Activity entry;
  final Profile? actor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final name = entry.actorName ?? l10n.someone;
    final amount = entry.amount != null && entry.currency != null
        ? context.money(entry.amount!, entry.currency!)
        : '';
    final (icon, color, text) = switch (entry.kind) {
      ActivityKind.kahwa => (
        Icons.coffee_rounded,
        context.colors.primary,
        l10n.activityKahwa(name, entry.kahwas ?? 1),
      ),
      ActivityKind.membership => (
        Icons.workspace_premium_rounded,
        context.colors.primary,
        l10n.activityMembership(name, amount),
      ),
      ActivityKind.fan => (
        Icons.favorite_rounded,
        context.colors.primary,
        l10n.activityFan(name),
      ),
      ActivityKind.reply => (
        Icons.reply_rounded,
        context.colors.primary,
        l10n.activityReply(name),
      ),
      ActivityKind.topUp => (
        entry.ok ? Icons.add_card_rounded : Icons.error_outline_rounded,
        entry.ok ? context.kahwa.success : context.kahwa.danger,
        entry.ok
            ? l10n.activityTopUpOk(amount)
            : l10n.activityTopUpFailed(amount),
      ),
      ActivityKind.withdraw => (
        entry.ok ? Icons.payments_rounded : Icons.error_outline_rounded,
        entry.ok ? context.kahwa.success : context.kahwa.danger,
        entry.ok
            ? l10n.activityWithdrawOk(amount)
            : l10n.activityWithdrawRefused(amount),
      ),
      ActivityKind.adjustment => (
        Icons.tune_rounded,
        (entry.amount ?? 0) >= 0 ? context.kahwa.success : context.kahwa.danger,
        l10n.activityAdjustment(amount),
      ),
      ActivityKind.directPayment => (
        Icons.mark_email_unread_rounded,
        context.kahwa.warning,
        l10n.activityDirectPayment(name, amount),
      ),
      ActivityKind.directAnswer => (
        entry.ok ? Icons.check_circle_rounded : Icons.error_outline_rounded,
        entry.ok ? context.kahwa.success : context.kahwa.danger,
        entry.ok
            ? l10n.activityDirectConfirmed(name, amount)
            : l10n.activityDirectRejected(name, amount),
      ),
    };

    return Panel(
      onTap: onTap,
      color: entry.read ? null : context.colors.primaryContainer,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              actor != null
                  ? ProfileAvatar(profile: actor, size: 44)
                  : Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: color),
                    ),
              if (actor != null)
                PositionedDirectional(
                  end: -4,
                  bottom: -4,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: context.colors.surface,
                        width: 2,
                      ),
                    ),
                    child: Icon(icon, size: 12, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: context.text.bodyLarge),
                if (entry.message.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    '“${entry.message}”',
                    textDirection: textDirectionOf(entry.message),
                    style: context.text.bodyMedium?.copyWith(
                      color: context.kahwa.muted,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  context.ago(entry.createdAt),
                  style: context.text.bodySmall?.copyWith(
                    color: context.kahwa.muted,
                  ),
                ),
              ],
            ),
          ),
          if (!entry.read)
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(
                color: context.colors.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
