import 'package:flutter/material.dart';
import 'package:kahwa/core/formatters.dart';
import 'package:kahwa/models/donation.dart';
import 'package:timeago/timeago.dart' as timeago;

/// A donation on the page of a creator. Private donations show up as made by
/// "Someone" and without their message.
class SupporterCard extends StatelessWidget {
  const SupporterCard({super.key, required this.donationSupporter});

  final DonationSupporter donationSupporter;

  @override
  Widget build(BuildContext context) {
    final donation = donationSupporter.donation;
    final supporter = donationSupporter.supporter;
    final accent = Theme.of(context).colorScheme.primary;

    final name = supporter?.name ?? 'Someone';
    final message = supporter == null ? '' : donation.message;
    final timestamp = donation.timestamp;

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.transparent,
              backgroundImage: const AssetImage('assets/cup.png'),
            ),
            title: Text('$name bought ${plural(donation.kahwas, 'kahwa')}'),
            subtitle: timestamp == null
                ? null
                : Text(timeago.format(timestamp)),
          ),
          if (message.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: accent.withValues(alpha: 0.3)),
              ),
              child: Text(message),
            ),
        ],
      ),
    );
  }
}
