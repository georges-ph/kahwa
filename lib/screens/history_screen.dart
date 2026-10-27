import 'package:flutter/material.dart';
import 'package:kahwa/core/colors.dart';
import 'package:kahwa/core/formatters.dart';
import 'package:kahwa/core/responsive.dart';
import 'package:kahwa/core/router.dart';
import 'package:kahwa/data/repositories.dart';
import 'package:kahwa/models/history_entry.dart';
import 'package:kahwa/widgets/async_body.dart';
import 'package:kahwa/widgets/page_body.dart';
import 'package:kahwa/widgets/sub_page.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Everything that moved the balance of the user, newest first.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<HistoryEntry>> _history = _load();

  Future<List<HistoryEntry>> _load() {
    return historyRepository.getHistory(authRepository.userId);
  }

  void _reload() => setState(() => _history = _load());

  @override
  Widget build(BuildContext context) {
    return SubPage(
      fallback: Routes.balance,
      body: AsyncBody(
        future: _history,
        onRetry: _reload,
        builder: (context, history) {
          return PageBody(
            maxWidth: ContentWidth.list,
            onRefresh: () async => _reload(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const PageTitle('History'),
                const SizedBox(height: 24),
                if (history.isEmpty)
                  const Text(
                    'Nothing yet. Top ups, kahwas and withdrawals '
                    'will show up here.',
                  )
                else
                  for (final entry in history) _HistoryTile(entry: entry),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.entry});

  final HistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final kahwas = plural(entry.kahwas, 'kahwa');
    final (icon, title) = switch (entry.kind) {
      HistoryKind.bought => (
        Icons.local_cafe_rounded,
        '$kahwas for ${entry.who ?? 'a creator'}',
      ),
      HistoryKind.received => (
        Icons.volunteer_activism_rounded,
        '$kahwas from ${entry.who ?? 'someone'}',
      ),
      HistoryKind.topUp => (Icons.add_card_rounded, 'Top up'),
      HistoryKind.withdrawal => (
        Icons.account_balance_wallet_rounded,
        'Withdrawal',
      ),
    };
    final date = entry.date;
    final sign = !entry.moved ? '' : (entry.isIncoming ? '+' : '−');

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(
        [
          ?entry.status,
          date == null ? 'Just now' : timeago.format(date),
        ].join(' · '),
      ),
      trailing: Text(
        '$sign${entry.amount}',
        style: TextStyle(
          color: entry.moved ? kBlackColor : kGreyColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
