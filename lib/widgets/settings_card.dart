import 'package:flutter/material.dart';
import 'package:kahwa/core/colors.dart';

class SettingsCard extends StatelessWidget {
  const SettingsCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kFillColor,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        leading: Icon(icon),
        iconColor: Theme.of(context).colorScheme.primary,
        title: Text(title),
      ),
    );
  }
}
