import 'package:flutter/material.dart';
import 'package:kahwa/utils/colors.dart';

class SettingsCard extends StatelessWidget {
  const SettingsCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.route,
  }) : super(key: key);

  final IconData icon;
  final String title;
  final String route;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.pushNamed(context, route),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 24,
      ),
      minLeadingWidth: 0,
      leading: Icon(icon),
      iconColor: kBrownColor,
      title: Text(title),
      tileColor: kGreyColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
