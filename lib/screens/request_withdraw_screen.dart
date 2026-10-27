import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kahwa/core/colors.dart';
import 'package:kahwa/core/feedback.dart';
import 'package:kahwa/core/formatters.dart';
import 'package:kahwa/core/router.dart';
import 'package:kahwa/data/repositories.dart';
import 'package:kahwa/models/balance.dart';
import 'package:kahwa/models/billing_details.dart';
import 'package:kahwa/models/currency.dart';
import 'package:kahwa/models/withdraw.dart';
import 'package:kahwa/widgets/async_body.dart';
import 'package:kahwa/widgets/balance_card.dart';
import 'package:kahwa/widgets/input_text.dart';
import 'package:kahwa/widgets/loading_button.dart';
import 'package:kahwa/widgets/notice.dart';
import 'package:kahwa/widgets/page_body.dart';
import 'package:kahwa/widgets/sub_page.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Asking to be paid part of the balance, and following those requests.
///
/// One request can wait at a time, like top ups, so the same money is never
/// asked for twice. An admin sends the money through WHISH and marks the
/// request as paid, or refuses it.
class RequestWithdrawScreen extends StatefulWidget {
  const RequestWithdrawScreen({super.key});

  @override
  State<RequestWithdrawScreen> createState() => _RequestWithdrawScreenState();
}

class _RequestWithdrawScreenState extends State<RequestWithdrawScreen> {
  late Future<(Balance, List<Withdraw>, BillingDetails)> _data;

  final _lbpController = TextEditingController();
  final _usdController = TextEditingController();

  bool _isLoading = false;

  /// The request being cancelled, if any.
  String? _cancelling;

  String get _userId => authRepository.userId;

  @override
  void initState() {
    super.initState();
    _data = _load();
  }

  @override
  void dispose() {
    _lbpController.dispose();
    _usdController.dispose();
    super.dispose();
  }

  Future<(Balance, List<Withdraw>, BillingDetails)> _load() {
    return (
      balanceRepository.getBalance(_userId),
      balanceRepository.getWithdrawals(_userId),
      balanceRepository.getBillingDetails(_userId),
    ).wait;
  }

  void _reload() => setState(() => _data = _load());

  Future<void> _requestWithdraw(Balance balance) async {
    final lbp = parseAmount(_lbpController.text) ?? 0;
    final usd = parseAmount(_usdController.text) ?? 0;

    if (lbp == 0 && usd == 0) {
      showSnack(context, 'Enter an amount to withdraw');
      return;
    }
    if (lbp > balance.currentLbp || usd > balance.currentUsd) {
      showSnack(context, 'You cannot withdraw more than your current balance');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await balanceRepository.requestWithdraw(
        Withdraw(userId: _userId, lbp: lbp, usd: usd),
      );
      if (!mounted) return;
      _lbpController.clear();
      _usdController.clear();
      showSnack(context, 'Request sent');
      _reload();
    } catch (_) {
      if (mounted) showSnack(context, 'Could not send the request, try again');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _cancel(Withdraw withdraw) async {
    setState(() => _cancelling = withdraw.id);
    try {
      await balanceRepository.cancelWithdraw(withdraw.id!);
      if (mounted) _reload();
    } catch (_) {
      // It may have been answered in the meantime.
      if (mounted) showSnack(context, 'Could not cancel it, try again');
    } finally {
      if (mounted) setState(() => _cancelling = null);
    }
  }

  Future<void> _openBillingDetails() async {
    await context.push(Routes.billingDetails);
    if (mounted) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return SubPage(
      fallback: Routes.balance,
      body: AsyncBody(
        future: _data,
        onRetry: _reload,
        builder: (context, data) {
          final (balance, withdrawals, billing) = data;
          final waiting = withdrawals.where((w) => w.isPending).firstOrNull;

          return PageBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const PageTitle('Request Withdraw'),
                const SizedBox(height: 40),
                BalanceCard(
                  title: 'Current Balance',
                  lbp: balance.currentLbp,
                  usd: balance.currentUsd,
                ),
                const SizedBox(height: 24),
                if (billing.isEmpty) ...[
                  const Notice(
                    'Add your billing details first, so we know where to '
                    'send your money.',
                  ),
                  LoadingButton(
                    label: 'Billing Details',
                    onPressed: _openBillingDetails,
                  ),
                ] else if (waiting != null)
                  Notice(
                    title: 'Your request is waiting',
                    'You asked for ${waiting.amountText}, which you will get '
                    'through WHISH MONEY once it is sent. To ask for another '
                    'amount, cancel this request first.',
                  )
                else
                  ..._buildForm(balance),
                if (withdrawals.isNotEmpty) ...[
                  const SizedBox(height: 40),
                  const SectionTitle('Your requests'),
                  const SizedBox(height: 8),
                  for (final withdraw in withdrawals) _buildRequest(withdraw),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildForm(Balance balance) {
    return [
      InputText(
        controller: _lbpController,
        title: 'Withdraw amount',
        hint: '0',
        prefixText: Currency.lbp.code,
        digitsOnly: true,
        textInputAction: TextInputAction.next,
      ),
      const SizedBox(height: 16),
      InputText(
        controller: _usdController,
        hint: '0',
        prefixText: Currency.usd.code,
        digitsOnly: true,
        textInputAction: TextInputAction.done,
      ),
      const SizedBox(height: 24),
      LoadingButton(
        label: 'Request',
        isLoading: _isLoading,
        onPressed: () => _requestWithdraw(balance),
      ),
    ];
  }

  Widget _buildRequest(Withdraw withdraw) {
    final timestamp = withdraw.timestamp;
    final (status, color) = switch (withdraw.status) {
      Withdraw.paid => ('Paid', Theme.of(context).colorScheme.primary),
      Withdraw.refused => ('Refused', kBlackColor),
      _ => ('Waiting', kGreyColor),
    };

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(withdraw.amountText),
      subtitle: Text(
        [status, if (timestamp != null) timeago.format(timestamp)].join(' · '),
        style: TextStyle(color: color),
      ),
      trailing: withdraw.isPending
          ? TextButton(
              onPressed: _cancelling == null ? () => _cancel(withdraw) : null,
              child: Text(
                _cancelling == withdraw.id ? 'Cancelling...' : 'Cancel',
              ),
            )
          : null,
    );
  }
}
