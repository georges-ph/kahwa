import 'package:flutter/material.dart';
import 'package:kahwa/utils/routes.dart';
import 'package:kahwa/utils/sizes.dart';
import 'package:kahwa/widgets/settings_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
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
