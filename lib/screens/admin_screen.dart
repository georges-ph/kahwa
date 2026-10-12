import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kahwa/core/feedback.dart';
import 'package:kahwa/core/responsive.dart';
import 'package:kahwa/core/router.dart';
import 'package:kahwa/data/admin_repository.dart';
import 'package:kahwa/data/repositories.dart';
import 'package:kahwa/models/currency.dart';
import 'package:kahwa/models/top_up_request.dart';
import 'package:kahwa/models/withdraw.dart';
import 'package:kahwa/widgets/async_body.dart';
import 'package:kahwa/widgets/balance_card.dart';
import 'package:kahwa/widgets/page_body.dart';
import 'package:kahwa/widgets/sub_page.dart';
import 'package:timeago/timeago.dart' as timeago;

/// For admins only: how much money belongs to users, and the top up and
/// withdraw requests waiting for a decision. Other users get "Access denied"
/// from the security rules.
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  late Future<AdminOverview> _overview;

  /// Reference or id of the request being saved, to disable its buttons.
  String? _busy;

  @override
  void initState() {
    super.initState();
    _overview = adminRepository.getOverview();
  }

  void _reload() {
    setState(() => _overview = adminRepository.getOverview());
  }

  Future<void> _refresh() async {
    try {
      final overview = await adminRepository.getOverview();
      if (mounted) setState(() => _overview = SynchronousFuture(overview));
    } catch (_) {
      if (mounted) showSnack(context, 'Could not refresh, try again');
    }
  }

  /// Asks to confirm, runs [action], then loads the numbers again.
  Future<void> _decide({
    required String key,
    required String question,
    required String confirm,
    required Future<void> Function() action,
    required String done,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(question),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = key);
    try {
      await action();
      if (mounted) showSnack(context, done);
    } catch (_) {
      if (mounted) showSnack(context, 'Could not save, try again');
    } finally {
      if (mounted) setState(() => _busy = null);
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SubPage(
      fallback: Routes.settings,
      body: AsyncBody(
        future: _overview,
        onRetry: _reload,
        builder: (context, overview) {
          return PageBody(
            maxWidth: ContentWidth.list,
            onRefresh: _refresh,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const PageTitle('Admin'),
                const SizedBox(height: 40),
                BalanceCard(
                  title: 'Held for users',
                  lbp: overview.heldLbp,
                  usd: overview.heldUsd,
                ),
                const SizedBox(height: 8),
                const Text(
                  'The total of all balances. This money belongs to users: '
                  'your WHISH balance should never go below it.',
                ),
                const SizedBox(height: 32),
                SectionTitle('Top up requests (${overview.topUps.length})'),
                const SizedBox(height: 12),
                if (overview.topUps.isEmpty) const Text('Nothing waiting.'),
                for (final request in overview.topUps)
                  _buildTopUp(overview, request),
                const SizedBox(height: 32),
                SectionTitle(
                  'Withdraw requests (${overview.withdrawals.length})',
                ),
                const SizedBox(height: 12),
                if (overview.withdrawals.isEmpty)
                  const Text('Nothing waiting.'),
                for (final withdraw in overview.withdrawals)
                  _buildWithdraw(overview, withdraw),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopUp(AdminOverview overview, TopUpRequest request) {
    final name = overview.users[request.userId]?.name ?? 'Unknown user';
    final amount = request.currency.format(request.amount);
    final isBusy = _busy == request.reference;

    return _RequestCard(
      title: '$name · $amount',
      lines: [
        'Sent from WHISH number: ${request.senderPhone}',
        if (request.timestamp != null) timeago.format(request.timestamp!),
      ],
      actions: [
        TextButton(
          onPressed: _busy != null
              ? null
              : () => _decide(
                  key: request.reference,
                  question:
                      'Reject the top up of $amount from $name? Nothing is '
                      'added to their balance.',
                  confirm: 'Reject',
                  action: () => adminRepository.rejectTopUp(request),
                  done: 'Rejected',
                ),
          child: const Text('Not received'),
        ),
        ElevatedButton(
          onPressed: _busy != null
              ? null
              : () => _decide(
                  key: request.reference,
                  question:
                      'Did you receive $amount from $name? It will be added '
                      'to their balance.',
                  confirm: 'Add $amount',
                  action: () => adminRepository.approveTopUp(request),
                  done: 'Added to the balance of $name',
                ),
          child: Text(isBusy ? 'Saving...' : 'Received'),
        ),
      ],
    );
  }

  Widget _buildWithdraw(AdminOverview overview, Withdraw withdraw) {
    final name = overview.users[withdraw.userId]?.name ?? 'Unknown user';
    final billing = overview.billingDetails[withdraw.userId];
    final amount = [
      if (withdraw.lbp > 0) Currency.lbp.format(withdraw.lbp),
      if (withdraw.usd > 0) Currency.usd.format(withdraw.usd),
    ].join(' and ');
    final fullName = '${billing?.firstName ?? ''} ${billing?.lastName ?? ''}'
        .trim();

    return _RequestCard(
      title: '$name · $amount',
      lines: [
        if (billing == null || billing.isEmpty)
          'No billing details saved'
        else ...[
          if (billing.whishPhone.isNotEmpty) 'WHISH: ${billing.whishPhone}',
          if (fullName.isNotEmpty) 'Name: $fullName',
          if (billing.phone.isNotEmpty) 'Phone: ${billing.phone}',
        ],
        if (withdraw.timestamp != null) timeago.format(withdraw.timestamp!),
      ],
      actions: [
        ElevatedButton(
          onPressed: _busy != null
              ? null
              : () => _decide(
                  key: withdraw.id!,
                  question:
                      'Did you send $amount to $name? It will be taken out '
                      'of their balance.',
                  confirm: 'Mark as paid',
                  action: () => adminRepository.markWithdrawPaid(withdraw),
                  done: 'Marked as paid',
                ),
          child: Text(_busy == withdraw.id ? 'Saving...' : 'Paid'),
        ),
      ],
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.title,
    required this.lines,
    required this.actions,
  });

  final String title;
  final List<String> lines;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(title),
              const SizedBox(height: 8),
              for (final line in lines) Text(line),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(spacing: 8, runSpacing: 8, children: actions),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
