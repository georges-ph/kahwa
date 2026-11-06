import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kahwa/core/money.dart';
import 'package:kahwa/models/donation.dart';
import 'package:kahwa/models/money_requests.dart';
import 'package:kahwa/state/providers.dart';
import 'package:kahwa/theme/app_theme.dart';
import 'package:kahwa/ui/avatar.dart';
import 'package:kahwa/ui/context.dart';
import 'package:kahwa/ui/widgets.dart';

enum HistoryKind { bought, received, topUp, withdrawal, adjustment }

/// One line of the history: money that moved in or out of the balance.
class HistoryEntry {
  const HistoryEntry({
    required this.kind,
    required this.amount,
    required this.currency,
    required this.time,
    this.otherId,
    this.kahwas = 0,
    this.ok = true,
    this.membership = false,
    this.direct = false,
    this.note,
  });

  final HistoryKind kind;
  final int amount;
  final Currency currency;
  final DateTime? time;

  /// The creator or supporter on the other side of a kahwa.
  final String? otherId;
  final int kahwas;
  final bool ok;
  final bool membership;

  /// Kahwas paid straight to the creator by WHISH: they never went through
  /// the balance.
  final bool direct;

  /// Why an admin corrected the balance.
  final String? note;

  /// Whether the balance went up.
  bool get isIn =>
      kind == HistoryKind.received ||
      kind == HistoryKind.topUp ||
      (kind == HistoryKind.adjustment && amount > 0);

  /// Everything that moved [userId]'s balance, newest first. A top up that
  /// was not found, or a refused withdrawal, is listed but moved nothing.
  static List<HistoryEntry> merge({
    required String userId,
    required List<Donation> bought,
    required List<Donation> received,
    required List<TopUpRecord> topUps,
    required List<WithdrawRequest> withdrawals,
    List<Adjustment> adjustments = const [],
  }) {
    final entries = [
      for (final d in bought)
        HistoryEntry(
          kind: HistoryKind.bought,
          amount: d.total,
          currency: d.currency,
          time: d.timestamp,
          otherId: d.creatorId,
          kahwas: d.kahwas,
          membership: d.kind == DonationKind.membership,
          direct: d.kind == DonationKind.direct,
        ),
      for (final d in received)
        HistoryEntry(
          kind: HistoryKind.received,
          amount: d.total,
          currency: d.currency,
          time: d.timestamp,
          otherId: d.supporterId,
          kahwas: d.kahwas,
          membership: d.kind == DonationKind.membership,
          direct: d.kind == DonationKind.direct,
        ),
      for (final t in topUps)
        HistoryEntry(
          kind: HistoryKind.topUp,
          amount: t.amount,
          currency: t.currency,
          time: t.resolvedAt,
          ok: t.status.isOk,
        ),
      for (final w in withdrawals.where((w) => !w.isPending))
        for (final currency in Currency.values)
          if (w.amounts.of(currency) > 0)
            HistoryEntry(
              kind: HistoryKind.withdrawal,
              amount: w.amounts.of(currency),
              currency: currency,
              time: w.resolvedAt ?? w.timestamp,
              ok: w.status.isOk,
            ),
      for (final a in adjustments)
        HistoryEntry(
          kind: HistoryKind.adjustment,
          amount: a.amount,
          currency: a.currency,
          time: a.createdAt,
          note: a.reason,
        ),
    ];
    final far = DateTime(9999);
    return entries..sort((a, b) => (b.time ?? far).compareTo(a.time ?? far));
  }
}

/// Everything that moved [id]'s balance: the signed in user's own, or any
/// user's for an admin.
final historyOfProvider = FutureProvider.autoDispose
    .family<List<HistoryEntry>, String>((ref, id) async {
      final support = ref.watch(supportRepositoryProvider);
      final wallet = ref.watch(walletRepositoryProvider);
      final (bought, received, topUps, withdrawals, adjustments) = await (
        support.donationsBy(id),
        support.donationsTo(id, viewerId: id),
        wallet.topUpHistory(id),
        wallet.withdrawals(id),
        wallet.adjustments(id),
      ).wait;
      return HistoryEntry.merge(
        userId: id,
        bought: bought,
        received: received,
        topUps: topUps,
        withdrawals: withdrawals,
        adjustments: adjustments,
      );
    });

final _historyProvider = FutureProvider.autoDispose<List<HistoryEntry>>((ref) {
  final id = ref.watch(userIdProvider);
  if (id == null) return Future.value(const []);
  return ref.watch(historyOfProvider(id).future);
});

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  HistoryKind? _filter;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final history = ref.watch(_historyProvider);
    final filters = [
      (null, l10n.all),
      (HistoryKind.bought, l10n.filterBought),
      (HistoryKind.received, l10n.filterReceived),
      (HistoryKind.topUp, l10n.filterTopUps),
      (HistoryKind.withdrawal, l10n.filterWithdrawals),
    ];
    return TitledPage(
      title: l10n.history,
      onRefresh: () async => ref.invalidate(_historyProvider),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final (kind, label) in filters)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: ChoiceChip(
                    selected: _filter == kind,
                    onSelected: (_) => setState(() => _filter = kind),
                    label: Text(label),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AsyncView(
          value: history,
          onRetry: () => ref.invalidate(_historyProvider),
          builder: (all) {
            final list = all
                .where((e) => _filter == null || e.kind == _filter)
                .toList();
            if (list.isEmpty) {
              return EmptyState(
                icon: Icons.receipt_long_rounded,
                title: l10n.historyEmptyTitle,
                message: l10n.historyEmptyBody,
              );
            }
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
                  HistoryEntryTile(
                    entry: e,
                    name: people[e.otherId]?.name,
                    avatar: people[e.otherId] == null
                        ? null
                        : ProfileAvatar(profile: people[e.otherId], size: 40),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class HistoryEntryTile extends StatelessWidget {
  const HistoryEntryTile({
    super.key,
    required this.entry,
    this.name,
    this.avatar,
  });

  final HistoryEntry entry;
  final String? name;
  final Widget? avatar;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final who = name ?? l10n.someone;
    final title = switch (entry.kind) {
      HistoryKind.bought =>
        entry.membership
            ? l10n.historyMembershipTo(who)
            : l10n.historyBought(entry.kahwas, who),
      HistoryKind.received =>
        entry.membership
            ? l10n.historyMembershipFrom(who)
            : l10n.historyReceived(entry.kahwas, who),
      HistoryKind.topUp =>
        entry.ok ? l10n.historyTopUp : l10n.historyTopUpFailed,
      HistoryKind.withdrawal =>
        entry.ok ? l10n.historyWithdrawal : l10n.historyWithdrawalRefused,
      HistoryKind.adjustment => l10n.historyAdjustment,
    };
    final subtitle = [
      dateTime(context, entry.time),
      if (entry.direct) l10n.paidByWhish,
      ?entry.note,
    ].join(' · ');
    final moved = entry.ok;
    final color = !moved
        ? context.kahwa.muted
        : entry.isIn
        ? context.kahwa.success
        : null;
    final icon = switch (entry.kind) {
      HistoryKind.bought => Icons.coffee_rounded,
      HistoryKind.received => Icons.volunteer_activism_rounded,
      HistoryKind.topUp => Icons.add_card_rounded,
      HistoryKind.withdrawal => Icons.payments_rounded,
      HistoryKind.adjustment => Icons.tune_rounded,
    };
    // A direct payment never touched the balance: no sign before it.
    final sign = !moved || entry.direct ? '' : (entry.isIn ? '+' : '−');
    return ListTile(
      leading:
          avatar ??
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.kahwa.subtle,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: context.colors.primary),
          ),
      title: Text(title, style: context.text.bodyMedium),
      subtitle: Text(
        subtitle,
        style: context.text.bodySmall?.copyWith(color: context.kahwa.muted),
      ),
      trailing: Text(
        '$sign${context.money(entry.amount.abs(), entry.currency)}',
        style: context.text.titleSmall?.copyWith(
          color: color,
          decoration: moved ? null : TextDecoration.lineThrough,
        ),
      ),
    );
  }
}
