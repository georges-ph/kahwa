import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kahwa/core/money.dart';
import 'package:kahwa/data/admin_repository.dart';
import 'package:kahwa/models/money_requests.dart';
import 'package:kahwa/models/profile.dart';
import 'package:kahwa/router.dart';
import 'package:kahwa/state/providers.dart';
import 'package:kahwa/theme/app_theme.dart';
import 'package:kahwa/ui/avatar.dart';
import 'package:kahwa/ui/context.dart';
import 'package:kahwa/ui/widgets.dart';

final _overviewProvider = FutureProvider.autoDispose<AdminOverview>(
  (ref) => ref.watch(adminRepositoryProvider).overview(),
);
final _topUpsProvider = FutureProvider.autoDispose<List<TopUpRequest>>(
  (ref) => ref.watch(adminRepositoryProvider).pendingTopUps(),
);
final _withdrawalsProvider = FutureProvider.autoDispose<List<WithdrawRequest>>(
  (ref) => ref.watch(adminRepositoryProvider).pendingWithdrawals(),
);
final _billingProvider = FutureProvider.autoDispose
    .family<BillingDetails, String>(
      (ref, id) => ref.watch(adminRepositoryProvider).billingOf(id),
    );
final _usersProvider = FutureProvider.autoDispose<List<Profile>>(
  (ref) => ref.watch(adminRepositoryProvider).users(),
);
final _logProvider = FutureProvider.autoDispose<AdminLog>(
  (ref) => ref.watch(adminRepositoryProvider).log(),
);

/// For admins: the requests to answer, every user's money, and a log of
/// what admins did.
class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isAdmin = ref.watch(isAdminProvider).valueOrNull;
    if (isAdmin != true) {
      return Scaffold(
        appBar: AppBar(),
        body: isAdmin == null
            ? const Center(child: CircularProgressIndicator())
            : EmptyState(icon: Icons.lock_rounded, title: l10n.adminOnly),
      );
    }
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.admin),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.adminRequests),
              Tab(text: l10n.users),
              Tab(text: l10n.adminLog),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_RequestsTab(), _UsersTab(), _LogTab()],
        ),
      ),
    );
  }
}

/// A tab's scrolling column, at a readable width.
class _TabList extends StatelessWidget {
  const _TabList({required this.children, required this.onRefresh});

  final List<Widget> children;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        children: [
          PageFrame(
            maxWidth: TitledPage.wideMaxWidth,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestsTab extends ConsumerWidget {
  const _RequestsTab();

  void _reload(WidgetRef ref) {
    ref
      ..invalidate(_overviewProvider)
      ..invalidate(_topUpsProvider)
      ..invalidate(_withdrawalsProvider)
      ..invalidate(_logProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final overview = ref.watch(_overviewProvider);
    final topUps = ref.watch(_topUpsProvider);
    final withdrawals = ref.watch(_withdrawalsProvider);

    return _TabList(
      onRefresh: () async => _reload(ref),
      children: [
        AsyncView(
          value: overview,
          onRetry: () => ref.invalidate(_overviewProvider),
          builder: (o) => Panel(
            color: context.colors.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.heldForUsers,
                  style: context.text.titleSmall?.copyWith(
                    color: context.colors.onPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                for (final currency in Currency.values)
                  Text(
                    context.money(o.held.of(currency), currency),
                    style: context.text.headlineSmall?.copyWith(
                      color: context.colors.onPrimary,
                    ),
                  ),
                const SizedBox(height: 6),
                Text(
                  l10n.heldForUsersHint,
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onPrimary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        WideColumns(
          startFlex: 1,
          endFlex: 1,
          start: [
            SectionTitle(l10n.topUpRequests),
            AsyncView(
              value: topUps,
              onRetry: () => ref.invalidate(_topUpsProvider),
              builder: (list) => list.isEmpty
                  ? Text(l10n.nothingWaiting)
                  : Column(
                      children: [
                        for (final r in list) ...[
                          _TopUpCard(request: r, onDone: () => _reload(ref)),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ),
            ),
          ],
          end: [
            if (!TitledPage.isWide(context)) const SizedBox(height: 28),
            SectionTitle(l10n.withdrawRequests),
            AsyncView(
              value: withdrawals,
              onRetry: () => ref.invalidate(_withdrawalsProvider),
              builder: (list) => list.isEmpty
                  ? Text(l10n.nothingWaiting)
                  : Column(
                      children: [
                        for (final r in list) ...[
                          _WithdrawCard(request: r, onDone: () => _reload(ref)),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A label and its value, as one line of a request's details.
class DetailRow extends StatelessWidget {
  const DetailRow(this.label, this.value, {super.key, this.copy = false});

  final String label;
  final String value;

  /// Adds a button to copy [value], such as a phone number to look up.
  final bool copy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: context.text.bodyMedium?.copyWith(
                color: context.kahwa.muted,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(value, style: context.text.titleSmall),
          ),
          if (copy && value.isNotEmpty)
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: context.l10n.copy,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                showSnack(context, context.l10n.copied);
              },
              icon: const Icon(Icons.copy_rounded, size: 18),
            ),
        ],
      ),
    );
  }
}

/// Asks to confirm an answer, showing everything needed to check the
/// transfer first.
Future<bool> _confirmWithDetails(
  BuildContext context, {
  required String title,
  required String message,
  required List<Widget> details,
  required String confirmLabel,
  bool danger = false,
}) async {
  final l10n = context.l10n;
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...details,
            const SizedBox(height: 12),
            Text(message, style: context.text.bodyMedium),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: danger
              ? FilledButton.styleFrom(
                  backgroundColor: context.kahwa.dangerFill,
                  foregroundColor: Colors.white,
                )
              : null,
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

class _TopUpCard extends ConsumerWidget {
  const _TopUpCard({required this.request, required this.onDone});

  final TopUpRequest request;
  final VoidCallback onDone;

  List<Widget> _details(BuildContext context, Profile? user) {
    final l10n = context.l10n;
    return [
      DetailRow(l10n.user, user?.name ?? ''),
      DetailRow(l10n.amount, context.money(request.amount, request.currency)),
      DetailRow(l10n.senderPhoneOf, request.senderPhone, copy: true),
      DetailRow(l10n.sentAt, dateTime(context, request.timestamp)),
      DetailRow(l10n.reference, request.reference, copy: true),
    ];
  }

  Future<void> _answer(
    BuildContext context,
    WidgetRef ref, {
    required bool received,
    required Profile? user,
  }) async {
    final l10n = context.l10n;
    final ok = await _confirmWithDetails(
      context,
      title: received ? l10n.markReceived : l10n.markNotReceived,
      message: received
          ? l10n.markReceivedBody(
              context.money(request.amount, request.currency),
            )
          : l10n.markNotReceivedBody,
      details: _details(context, user),
      confirmLabel: received ? l10n.received : l10n.notReceived,
      danger: !received,
    );
    if (!ok) return;
    final adminId = ref.read(userIdProvider);
    if (adminId == null) return;
    try {
      await ref
          .read(adminRepositoryProvider)
          .answerTopUp(request, received: received, adminId: adminId);
      refreshMyData(ref.invalidate);
      onDone();
    } catch (_) {
      if (context.mounted) showSnack(context, l10n.somethingWrong);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = ref.watch(profileProvider(request.userId)).valueOrNull;
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(Radii.tile),
            onTap: () => context.push(Routes.adminUser(request.userId)),
            child: Row(
              children: [
                ProfileAvatar(profile: user, size: 42),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    user?.name ?? '',
                    style: context.text.titleMedium,
                  ),
                ),
                Text(
                  context.money(request.amount, request.currency),
                  style: context.text.titleLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          DetailRow(l10n.senderPhoneOf, request.senderPhone, copy: true),
          DetailRow(l10n.sentAt, dateTime(context, request.timestamp)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      _answer(context, ref, received: false, user: user),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                  ),
                  child: Text(l10n.notReceived, textAlign: TextAlign.center),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: () =>
                      _answer(context, ref, received: true, user: user),
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
                  child: Text(l10n.received, textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WithdrawCard extends ConsumerWidget {
  const _WithdrawCard({required this.request, required this.onDone});

  final WithdrawRequest request;
  final VoidCallback onDone;

  String _amounts(BuildContext context) {
    final a = request.amounts;
    return [
      if (a.lbp > 0) context.money(a.lbp, Currency.lbp),
      if (a.usd > 0) context.money(a.usd, Currency.usd),
    ].join(' + ');
  }

  Future<void> _answer(
    BuildContext context,
    WidgetRef ref, {
    required bool paid,
    required Profile? user,
    required BillingDetails? billing,
  }) async {
    final l10n = context.l10n;
    final ok = await _confirmWithDetails(
      context,
      title: paid ? l10n.markPaid : l10n.refuse,
      message: paid ? l10n.markPaidBody : l10n.refuseBody,
      details: [
        DetailRow(l10n.user, user?.name ?? ''),
        DetailRow(l10n.amount, _amounts(context)),
        DetailRow(l10n.fullName, billing?.fullName ?? ''),
        DetailRow(l10n.whishNumber, billing?.whishPhone ?? '', copy: true),
        DetailRow(l10n.requestedAt, dateTime(context, request.timestamp)),
      ],
      confirmLabel: paid ? l10n.paid : l10n.refuse,
      danger: !paid,
    );
    if (!ok) return;
    final adminId = ref.read(userIdProvider);
    if (adminId == null) return;
    try {
      await ref
          .read(adminRepositoryProvider)
          .answerWithdraw(request, paid: paid, adminId: adminId);
      refreshMyData(ref.invalidate);
      onDone();
    } catch (_) {
      if (context.mounted) showSnack(context, l10n.somethingWrong);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = ref.watch(profileProvider(request.userId)).valueOrNull;
    final billing = ref.watch(_billingProvider(request.userId)).valueOrNull;
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(Radii.tile),
            onTap: () => context.push(Routes.adminUser(request.userId)),
            child: Row(
              children: [
                ProfileAvatar(profile: user, size: 42),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    user?.name ?? '',
                    style: context.text.titleMedium,
                  ),
                ),
                Text(_amounts(context), style: context.text.titleMedium),
              ],
            ),
          ),
          const SizedBox(height: 10),
          DetailRow(l10n.fullName, billing?.fullName ?? ''),
          DetailRow(l10n.whishNumber, billing?.whishPhone ?? '', copy: true),
          DetailRow(l10n.requestedAt, dateTime(context, request.timestamp)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _answer(
                    context,
                    ref,
                    paid: false,
                    user: user,
                    billing: billing,
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                  ),
                  child: Text(l10n.refuse, textAlign: TextAlign.center),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: () => _answer(
                    context,
                    ref,
                    paid: true,
                    user: user,
                    billing: billing,
                  ),
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
                  child: Text(l10n.paid, textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Looking any user up by name or username.
class _UsersTab extends ConsumerStatefulWidget {
  const _UsersTab();

  @override
  ConsumerState<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends ConsumerState<_UsersTab> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final users = ref.watch(_usersProvider);
    final overview = ref.watch(_overviewProvider).valueOrNull;
    return _TabList(
      onRefresh: () async => ref.invalidate(_usersProvider),
      children: [
        TextField(
          controller: _search,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: l10n.searchUsers,
            prefixIcon: const Icon(Icons.search_rounded),
          ),
        ),
        if (overview != null) ...[
          const SizedBox(height: 10),
          Text(
            l10n.usersCount(overview.users, overview.creators),
            style: context.text.bodySmall?.copyWith(color: context.kahwa.muted),
          ),
        ],
        const SizedBox(height: 12),
        AsyncView(
          value: users,
          onRetry: () => ref.invalidate(_usersProvider),
          builder: (all) {
            final query = _search.text;
            final list = all.where((p) => p.matches(query)).take(100).toList();
            if (list.isEmpty) return Text(l10n.noResults);
            return CardGrid(
              children: [
                for (final p in list)
                  ListTile(
                    onTap: () => context.push(Routes.adminUser(p.id)),
                    leading: ProfileAvatar(profile: p, size: 40),
                    title: Text(p.name, style: context.text.titleSmall),
                    subtitle: Text(
                      [
                        if (p.username != null) '@${p.username}',
                        if (p.isCreator) l10n.creator,
                        context.date(p.createdAt),
                      ].join(' · '),
                      style: context.text.bodySmall?.copyWith(
                        color: context.kahwa.muted,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// What admins did lately: answered requests and balance corrections.
class _LogTab extends ConsumerWidget {
  const _LogTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final log = ref.watch(_logProvider);
    return _TabList(
      onRefresh: () async => ref.invalidate(_logProvider),
      children: [
        AsyncView(
          value: log,
          onRetry: () => ref.invalidate(_logProvider),
          builder: (log) {
            final ids = ProfileIds([
              ...log.topUps.map((t) => t.userId),
              ...log.withdrawals.map((w) => w.userId),
              ...log.adjustments.map((a) => a.userId),
              ...log.adjustments.map((a) => a.adminId),
            ]);
            final people =
                ref.watch(profilesProvider(ids)).valueOrNull ?? const {};
            final entries = <(DateTime?, Widget)>[
              for (final t in log.topUps)
                (
                  t.record.resolvedAt,
                  _LogTile(
                    icon: Icons.add_card_rounded,
                    ok: t.record.status.isOk,
                    title: t.record.status.isOk
                        ? l10n.logTopUpApproved(people[t.userId]?.name ?? '')
                        : l10n.logTopUpRejected(people[t.userId]?.name ?? ''),
                    amount: context.money(t.record.amount, t.record.currency),
                    time: t.record.resolvedAt,
                    onTap: () => context.push(Routes.adminUser(t.userId)),
                  ),
                ),
              for (final w in log.withdrawals)
                (
                  w.resolvedAt,
                  _LogTile(
                    icon: Icons.payments_rounded,
                    ok: w.status.isOk,
                    title: w.status.isOk
                        ? l10n.logWithdrawPaid(people[w.userId]?.name ?? '')
                        : l10n.logWithdrawRefused(people[w.userId]?.name ?? ''),
                    amount: [
                      if (w.amounts.lbp > 0)
                        context.money(w.amounts.lbp, Currency.lbp),
                      if (w.amounts.usd > 0)
                        context.money(w.amounts.usd, Currency.usd),
                    ].join(' + '),
                    time: w.resolvedAt,
                    onTap: () => context.push(Routes.adminUser(w.userId)),
                  ),
                ),
              for (final a in log.adjustments)
                (
                  a.createdAt,
                  _LogTile(
                    icon: Icons.tune_rounded,
                    ok: a.amount >= 0,
                    title: l10n.logAdjustment(
                      people[a.adminId]?.name ?? '',
                      people[a.userId]?.name ?? '',
                    ),
                    note: a.reason,
                    amount:
                        '${a.amount >= 0 ? '+' : '−'}${context.money(a.amount.abs(), a.currency)}',
                    time: a.createdAt,
                    onTap: () => context.push(Routes.adminUser(a.userId)),
                  ),
                ),
            ];
            if (entries.isEmpty) return Text(l10n.nothingYet);
            final far = DateTime(0);
            entries.sort((a, b) => (b.$1 ?? far).compareTo(a.$1 ?? far));
            return CardGrid(children: [for (final e in entries) e.$2]);
          },
        ),
      ],
    );
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile({
    required this.icon,
    required this.ok,
    required this.title,
    required this.amount,
    required this.time,
    this.note,
    this.onTap,
  });

  final IconData icon;
  final bool ok;
  final String title;
  final String amount;
  final DateTime? time;
  final String? note;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: ok ? context.kahwa.success : context.kahwa.danger,
      ),
      title: Text(title, style: context.text.bodyMedium),
      subtitle: Text(
        [dateTime(context, time), ?note].join('\n'),
        style: context.text.bodySmall?.copyWith(color: context.kahwa.muted),
      ),
      trailing: Text(amount, style: context.text.titleSmall),
    );
  }
}
