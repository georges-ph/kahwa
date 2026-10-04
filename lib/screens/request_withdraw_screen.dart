import 'package:flutter/material.dart';
import 'package:kahwa/core/feedback.dart';
import 'package:kahwa/core/formatters.dart';
import 'package:kahwa/core/router.dart';
import 'package:kahwa/data/repositories.dart';
import 'package:kahwa/models/balance.dart';
import 'package:kahwa/models/currency.dart';
import 'package:kahwa/models/withdraw.dart';
import 'package:kahwa/widgets/async_body.dart';
import 'package:kahwa/widgets/balance_card.dart';
import 'package:kahwa/widgets/input_text.dart';
import 'package:kahwa/widgets/loading_button.dart';
import 'package:kahwa/widgets/page_body.dart';
import 'package:kahwa/widgets/sub_page.dart';

class RequestWithdrawScreen extends StatefulWidget {
  const RequestWithdrawScreen({super.key});

  @override
  State<RequestWithdrawScreen> createState() => _RequestWithdrawScreenState();
}

class _RequestWithdrawScreenState extends State<RequestWithdrawScreen> {
  late Future<Balance> _balance;

  final _lbpController = TextEditingController();
  final _usdController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _balance = _load();
  }

  @override
  void dispose() {
    _lbpController.dispose();
    _usdController.dispose();
    super.dispose();
  }

  Future<Balance> _load() {
    return balanceRepository.getBalance(authRepository.userId);
  }

  void _reload() => setState(() => _balance = _load());

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
        Withdraw(userId: authRepository.userId, lbp: lbp, usd: usd),
      );
      if (!mounted) return;
      _lbpController.clear();
      _usdController.clear();
      showSnack(context, 'Request sent');
    } catch (_) {
      if (mounted) showSnack(context, 'Could not send the request, try again');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SubPage(
      fallback: Routes.balance,
      body: AsyncBody(
        future: _balance,
        onRetry: _reload,
        builder: (context, balance) {
          return PageBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const PageTitle('Request Withdraw'),
                const SizedBox(height: 40),
                const Text(
                  'Make sure you have setup your billing details. Otherwise, '
                  'no withdraws will be made.',
                ),
                const SizedBox(height: 24),
                BalanceCard(
                  title: 'Current Balance',
                  lbp: balance.currentLbp,
                  usd: balance.currentUsd,
                ),
                const SizedBox(height: 24),
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
              ],
            ),
          );
        },
      ),
    );
  }
}
