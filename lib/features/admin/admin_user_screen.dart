import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kahwa/core/money.dart';
import 'package:kahwa/data/admin_repository.dart';
import 'package:kahwa/features/admin/admin_screen.dart';
import 'package:kahwa/features/wallet/history_screen.dart';
import 'package:kahwa/models/membership.dart';
import 'package:kahwa/models/profile.dart';
import 'package:kahwa/router.dart';
import 'package:kahwa/state/providers.dart';
import 'package:kahwa/theme/app_theme.dart';
import 'package:kahwa/ui/avatar.dart';
import 'package:kahwa/ui/context.dart';
import 'package:kahwa/ui/widgets.dart';
import 'package:kahwa/ui/money_stats.dart';

final _fileProvider = FutureProvider.autoDispose.family<UserFile, String>(
  (ref, id) => ref.watch(adminRepositoryProvider).userFile(id),
);

/// Everything about one user's money, for an admin looking into a problem,
/// and the one way to correct it: a logged adjustment with a reason.
class AdminUserScreen extends ConsumerWidget {
  const AdminUserScreen({super.key, required this.userId});

  final String userId;

  void _reload(WidgetRef ref) {
    ref
      ..invalidate(_fileProvider(userId))
      ..invalidate(historyOfProvider(userId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    if (ref.watch(isAdminProvider).valueOrNull != true) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(icon: Icons.lock_rounded, title: l10n.adminOnly),
      );
    }
    final profile = ref.watch(profileProvider(userId)).valueOrNull;
    final file = ref.watch(_fileProvider(userId));
    final history = ref.watch(historyOfProvider(userId));

    return TitledPage(
      title: profile?.name ?? '',
      subtitle: profile?.username == null ? null : '@${profile!.username}',
      maxWidth: TitledPage.wideMaxWidth,
      onRefresh: () async => _reload(ref),
      actions: [
        if (profile != null && profile.isCreator)
          IconButton(
            tooltip: l10n.viewPage,
            onPressed: () => context.push(Routes.page(profile)),
            icon: const Icon(Icons.open_in_new_rounded),
          ),
      ],
      // The history beside the account on a wide screen, under it on a phone.
      side: [
        if (!TitledPage.isWide(context)) const SizedBox(height: 20),
        SectionTitle(l10n.history),
        AsyncView(
          value: history,
          onRetry: () => ref.invalidate(historyOfProvider(userId)),
          builder: (list) {
            if (list.isEmpty) return Text(l10n.nothingYet);
            final people =
                ref
                    .watch(
                      profilesProvider(
                        ProfileIds(list.map((e) => e.otherId).nonNulls),
                      ),
                    )
                    .valueOrNull ??
                const {};
            return TileGroup(
              children: [
                for (final e in list)
                  HistoryEntryTile(entry: e, name: people[e.otherId]?.name),
              ],
            );
          },
        ),
      ],
      children: [
        AsyncView(
          value: file,
          onRetry: () => ref.invalidate(_fileProvider(userId)),
          builder: (f) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        ProfileAvatar(profile: profile, size: 48),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final currency in Currency.values)
                                Text(
                                  context.money(
                                    f.wallet.current.of(currency),
                                    currency,
                                  ),
                                  style: context.text.titleLarge,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    MoneyStats(
                      framed: false,
                      stats: [
                        (l10n.received, f.wallet.received),
                        (l10n.spent, f.wallet.spent),
                        (l10n.withdrawn, f.wallet.withdrawn),
                      ],
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: () async {
                        final done = await showDialog<bool>(
                          context: context,
                          builder: (_) => _AdjustDialog(
                            userId: userId,
                            name: profile?.name ?? '',
                          ),
                        );
                        if (done == true) _reload(ref);
                      },
                      icon: const Icon(Icons.tune_rounded),
                      label: Text(l10n.correctBalance),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SectionTitle(l10n.billingDetails),
              Panel(
                child: Column(
                  children: [
                    DetailRow(l10n.fullName, f.billing.fullName),
                    DetailRow(
                      l10n.whishNumber,
                      f.billing.whishPhone,
                      copy: true,
                    ),
                  ],
                ),
              ),
              if (f.topUp case final t?) ...[
                const SizedBox(height: 20),
                SectionTitle(l10n.lastTopUp),
                Panel(
                  child: Column(
                    children: [
                      DetailRow(
                        l10n.amount,
                        context.money(t.amount, t.currency),
                      ),
                      DetailRow(l10n.senderPhoneOf, t.senderPhone, copy: true),
                      DetailRow(l10n.sentAt, dateTime(context, t.timestamp)),
                      DetailRow(
                        l10n.status,
                        requestStatusLabel(context, t.status.name),
                      ),
                      DetailRow(l10n.reference, t.reference, copy: true),
                    ],
                  ),
                ),
              ],
              if (f.memberships.isNotEmpty || f.members.isNotEmpty) ...[
                const SizedBox(height: 20),
                SectionTitle(l10n.myMemberships),
                _Memberships(file: f, userId: userId),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// A request status in words.
String requestStatusLabel(BuildContext context, String status) {
  final l10n = context.l10n;
  return switch (status) {
    'approved' => l10n.statusApproved,
    'rejected' => l10n.statusRejected,
    'paid' => l10n.paid,
    'refused' => l10n.statusRefused,
    _ => l10n.statusPending,
  };
}

class _Memberships extends ConsumerWidget {
  const _Memberships({required this.file, required this.userId});

  final UserFile file;
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final all = [...file.memberships, ...file.members];
    final people =
        ref
            .watch(
              profilesProvider(
                ProfileIds(all.expand((m) => [m.creatorId, m.supporterId])),
              ),
            )
            .valueOrNull ??
        const <String, Profile>{};
    String line(Membership m) {
      final status = m.isActive
          ? l10n.renewsOn(context.date(m.nextCharge))
          : l10n.cancelledUntil(context.date(m.nextCharge));
      return '${m.tierName} · ${context.money(m.total, m.currency)} · $status';
    }

    return TileGroup(
      children: [
        for (final m in file.memberships)
          ListTile(
            leading: const Icon(Icons.north_east_rounded),
            title: Text(l10n.paysTo(people[m.creatorId]?.name ?? '')),
            subtitle: Text(line(m)),
          ),
        for (final m in file.members)
          ListTile(
            leading: const Icon(Icons.south_west_rounded),
            title: Text(l10n.paidBy(people[m.supporterId]?.name ?? '')),
            subtitle: Text(line(m)),
          ),
      ],
    );
  }
}

/// Adds money to a user's balance or takes some out, with the reason.
class _AdjustDialog extends ConsumerStatefulWidget {
  const _AdjustDialog({required this.userId, required this.name});

  final String userId;
  final String name;

  @override
  ConsumerState<_AdjustDialog> createState() => _AdjustDialogState();
}

class _AdjustDialogState extends ConsumerState<_AdjustDialog> {
  final _amount = TextEditingController();
  final _reason = TextEditingController();
  var _currency = Currency.lbp;
  var _add = true;
  String? _amountError;
  String? _reasonError;
  bool _busy = false;

  @override
  void dispose() {
    _amount.dispose();
    _reason.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final amount = parseAmount(_amount.text);
    final reason = _reason.text.trim();
    setState(() {
      _amountError = amount == null || amount < 1 ? l10n.amountInvalid : null;
      _reasonError = reason.length < 5 ? l10n.reasonMissing : null;
    });
    if (_amountError != null || _reasonError != null) return;
    final signed = _add ? amount! : -amount!;
    final money = context.money(amount, _currency);
    final ok = await confirm(
      context,
      title: _add
          ? l10n.adjustAddTitle(money, widget.name)
          : l10n.adjustRemoveTitle(money, widget.name),
      message: l10n.adjustBody,
      confirm: l10n.correctBalance,
      danger: !_add,
    );
    if (!ok || !mounted) return;
    final adminId = ref.read(userIdProvider);
    if (adminId == null) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(adminRepositoryProvider)
          .adjust(
            userId: widget.userId,
            adminId: adminId,
            currency: _currency,
            amount: signed,
            reason: reason,
          );
      refreshMyData(ref.invalidate);
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      // The rules refuse taking out more than the balance holds.
      if (mounted) showSnack(context, l10n.adjustFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.correctBalance),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: true, label: Text(l10n.addMoney)),
                ButtonSegment(value: false, label: Text(l10n.takeMoneyOut)),
              ],
              selected: {_add},
              onSelectionChanged: (s) => setState(() => _add = s.first),
            ),
            const SizedBox(height: 14),
            CurrencyToggle(
              value: _currency,
              onChanged: (c) => setState(() => _currency = c),
            ),
            const SizedBox(height: 14),
            AmountField(
              controller: _amount,
              currency: _currency,
              errorText: _amountError,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _reason,
              maxLength: 300,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: l10n.reason,
                hintText: l10n.reasonHint,
                errorText: _reasonError,
              ),
            ),
            Text(
              l10n.adjustNote,
              style: context.text.bodySmall?.copyWith(
                color: context.kahwa.muted,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _busy ? null : _save, child: Text(l10n.save)),
      ],
    );
  }
}
