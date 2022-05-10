// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:kahwa/utils/colors.dart';
import 'package:kahwa/utils/routes.dart';
import 'package:kahwa/utils/sizes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
        ),
        child: Column(
          children: [
            verticalSpace(height: 40),
            SettingsCard(
              onTap: () => Navigator.pushNamed(context, routeProfile),
              icon: Icons.person_rounded,
              title: "Profile",
            ),
            verticalSpace(height: 16),
            SettingsCard(
              onTap: () {},
              icon: Icons.money_rounded,
              title: "kahwa Price",
            ),
            verticalSpace(height: 16),
            SettingsCard(
              onTap: () {},
              icon: Icons.account_balance_rounded,
              title: "Balance",
            ),
            verticalSpace(height: 16),
            SettingsCard(
              onTap: () {},
              icon: Icons.contact_mail_rounded,
              title: "Billing Details",
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsCard extends StatelessWidget {
  const SettingsCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  final IconData icon;
  final String title;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 24,
      ),
      minLeadingWidth: 0,
      leading: Icon(icon),
      iconColor: kRedColor,
      title: Text(title),
      tileColor: kGreyColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
