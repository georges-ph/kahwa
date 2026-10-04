import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kahwa/core/responsive.dart';
import 'package:kahwa/core/router.dart';
import 'package:kahwa/data/repositories.dart';
import 'package:kahwa/models/balance.dart';
import 'package:kahwa/widgets/async_body.dart';
import 'package:kahwa/widgets/balance_card.dart';
import 'package:kahwa/widgets/loading_button.dart';
import 'package:kahwa/widgets/page_body.dart';
import 'package:kahwa/widgets/sub_page.dart';

class BalanceScreen extends StatefulWidget {
  const BalanceScreen({super.key});

  @override
  State<BalanceScreen> createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {
  late Future<Balance> _balance;

  @override
  void initState() {
    super.initState();
    _balance = _load();
  }

  Future<Balance> _load() {
    return balanceRepository.getBalance(authRepository.userId);
  }

  void _reload() => setState(() => _balance = _load());

  @override
  Widget build(BuildContext context) {
    return SubPage(
      fallback: Routes.settings,
      body: AsyncBody(
        future: _balance,
        onRetry: _reload,
        builder: (context, balance) {
          final cards = [
            BalanceCard(
              title: 'Current Balance',
              lbp: balance.currentLbp,
              usd: balance.currentUsd,
            ),
            BalanceCard(
              title: 'Spent',
              lbp: balance.spentLbp,
              usd: balance.spentUsd,
            ),
            BalanceCard(
              title: 'Received',
              lbp: balance.receivedLbp,
              usd: balance.receivedUsd,
            ),
            BalanceCard(
              title: 'Withdrawn',
              lbp: balance.withdrawnLbp,
              usd: balance.withdrawnUsd,
            ),
          ];

          return PageBody(
            maxWidth: ContentWidth.list,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PageTitle('Balance'),
                const SizedBox(height: 40),
                _BalanceGrid(cards: cards),
                const SizedBox(height: 24),
                LoadingButton(
                  label: 'Request Withdraw',
                  onPressed: () => context.push(Routes.requestWithdraw),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// One column of cards on phones, two when there is room.
class _BalanceGrid extends StatelessWidget {
  const _BalanceGrid({required this.cards});

  final List<Widget> cards;

  static const _spacing = 24.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 520 ? 2 : 1;
        final cardWidth =
            (constraints.maxWidth - _spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: _spacing,
          runSpacing: _spacing,
          children: [
            for (final card in cards) SizedBox(width: cardWidth, child: card),
          ],
        );
      },
    );
  }
}
