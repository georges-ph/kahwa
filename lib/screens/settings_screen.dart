import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kahwa/core/config.dart';
import 'package:kahwa/core/feedback.dart';
import 'package:kahwa/core/router.dart';
import 'package:kahwa/data/repositories.dart';
import 'package:kahwa/widgets/page_body.dart';
import 'package:kahwa/widgets/settings_card.dart';
import 'package:kahwa/widgets/sub_page.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final Future<bool> _isAdmin = adminRepository.isAdmin(
    authRepository.userId,
  );

  static const _pages = [
    (Routes.profile, Icons.person_rounded, 'Profile'),
    (Routes.kahwaPrice, Icons.money_rounded, 'kahwa Price'),
    (Routes.balance, Icons.account_balance_rounded, 'Balance'),
    (Routes.billingDetails, Icons.contact_mail_rounded, 'Billing Details'),
  ];

  @override
  Widget build(BuildContext context) {
    return SubPage(
      fallback: Routes.home,
      actions: [
        IconButton(
          onPressed: () => openLink(context, Uri.parse(AppConfig.feedbackUrl)),
          tooltip: 'Feedback',
          icon: const Icon(Icons.feedback_rounded),
        ),
        IconButton(
          // The router sends signed out users to the log in screen.
          onPressed: authRepository.signOut,
          tooltip: 'Log Out',
          icon: const Icon(Icons.logout_rounded),
        ),
        const SizedBox(width: 8),
      ],
      body: PageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageTitle('Settings'),
            const SizedBox(height: 24),
            for (final (route, icon, title) in _pages) ...[
              const SizedBox(height: 16),
              SettingsCard(
                icon: icon,
                title: title,
                onTap: () => context.push(route),
              ),
            ],
            FutureBuilder(
              future: _isAdmin,
              builder: (context, snapshot) {
                if (snapshot.data != true) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: SettingsCard(
                    icon: Icons.admin_panel_settings_rounded,
                    title: 'Admin',
                    onTap: () => context.push(Routes.admin),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
