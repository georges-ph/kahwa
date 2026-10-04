import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kahwa/core/colors.dart';
import 'package:kahwa/models/currency.dart';
import 'package:kahwa/widgets/page_body.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.title,
    required this.lbp,
    required this.usd,
  });

  final String title;
  final int lbp;
  final int usd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kFillColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title),
          const SizedBox(height: 8),
          _AmountRow(currency: Currency.lbp, amount: lbp),
          const SizedBox(height: 8),
          _AmountRow(currency: Currency.usd, amount: usd),
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({required this.currency, required this.amount});

  final Currency currency;
  final int amount;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleSmall;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(currency.code, style: style),
        Text(
          NumberFormat.decimalPattern('en').format(amount),
          style: style?.copyWith(color: kGreyColor),
        ),
      ],
    );
  }
}
