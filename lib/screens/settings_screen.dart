import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kahwa/utils/routes.dart';
import 'package:kahwa/utils/sizes.dart';
import 'package:kahwa/widgets/settings_card.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Tooltip(
            message: "Feedback",
            child: IconButton(
              onPressed: () async {
                if (!await launchUrl(
                    Uri.parse("https://kahwa.jundbits.ga/feedback"))) {
                  SnackBar snackBar =
                      const SnackBar(content: Text("Cannot open link"));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
              icon: const Icon(Icons.feedback_rounded),
            ),
          ),
          Tooltip(
            message: "Log Out",
            child: IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.logout_rounded),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Settings".toUpperCase(),
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            verticalSpace(height: 40),
            const SettingsCard(
              route: routeProfile,
              icon: Icons.person_rounded,
              title: "Profile",
            ),
            verticalSpace(height: 16),
            const SettingsCard(
              route: routeKahwaPrice,
              icon: Icons.money_rounded,
              title: "kahwa Price",
            ),
            verticalSpace(height: 16),
            const SettingsCard(
              route: routeBalance,
              icon: Icons.account_balance_rounded,
              title: "Balance",
            ),
            verticalSpace(height: 16),
            const SettingsCard(
              route: routeBillingDetails,
              icon: Icons.contact_mail_rounded,
              title: "Billing Details",
            ),
          ],
        ),
      ),
    );
  }
}
