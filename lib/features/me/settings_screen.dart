import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kahwa/core/config.dart';
import 'package:kahwa/features/me/security_screen.dart';
import 'package:kahwa/router.dart';
import 'package:kahwa/state/providers.dart';
import 'package:kahwa/state/settings.dart';
import 'package:kahwa/theme/app_theme.dart';
import 'package:kahwa/ui/context.dart';
import 'package:kahwa/ui/widgets.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final ok = await confirm(
      context,
      title: l10n.signOutTitle,
      message: l10n.signOutBody,
      confirm: l10n.signOut,
      danger: true,
    );
    if (!ok || !context.mounted) return;
    // Read first: this screen is gone once the user is out.
    final router = GoRouter.of(context);
    await signOutHere(ref);
    // The redirect alone would open the sign in screen, set to come back
    // here, as this screen sits over the Me tab.
    router.go(Routes.signIn);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final auth = ref.watch(authRepositoryProvider);
    final email = auth.email;
    Widget check(bool on) => on
        ? Icon(Icons.check_rounded, color: context.colors.primary)
        : const SizedBox.shrink();

    return TitledPage(
      title: l10n.settings,
      children: [
        SectionTitle(l10n.account),
        TileGroup(
          children: [
            // One row for the email: tapping it changes it, or adds one to
            // an account that has none. The password, or the Google
            // account, is checked first.
            NavTile(
              icon: Icons.mail_outline_rounded,
              title: l10n.email,
              subtitle: email == null
                  ? l10n.noEmailYet
                  : '$email\n${l10n.tapToChangeEmail}',
              onTap: () => showChangeEmailDialog(context),
            ),
            NavTile(
              icon: Icons.shield_outlined,
              title: l10n.security,
              subtitle: l10n.securityHint,
              onTap: () => context.push(Routes.security),
            ),
            NavTile(
              icon: Icons.devices_rounded,
              title: l10n.devices,
              subtitle: l10n.devicesHint,
              onTap: () => context.push(Routes.devices),
            ),
            NavTile(
              icon: Icons.logout_rounded,
              title: l10n.signOut,
              onTap: () => _signOut(context, ref),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SectionTitle(l10n.appearance),
        // A list rather than three buttons side by side, which a phone is
        // too narrow for.
        TileGroup(
          children: [
            for (final (mode, icon, label) in [
              (
                ThemeMode.system,
                Icons.brightness_auto_rounded,
                l10n.themeSystem,
              ),
              (ThemeMode.light, Icons.light_mode_rounded, l10n.themeLight),
              (ThemeMode.dark, Icons.dark_mode_rounded, l10n.themeDark),
            ])
              NavTile(
                icon: icon,
                title: label,
                onTap: () => notifier.setThemeMode(mode),
                trailing: check(settings.themeMode == mode),
              ),
          ],
        ),
        const SizedBox(height: 24),
        SectionTitle(l10n.language),
        TileGroup(
          children: [
            for (final (locale, label) in [
              (null, l10n.languageDevice),
              for (final MapEntry(key: code, value: name)
                  in AppSettings.languageNames.entries)
                (Locale(code), name),
            ])
              NavTile(
                icon: Icons.translate_rounded,
                title: label,
                onTap: () => notifier.setLocale(locale),
                trailing: check(
                  settings.locale?.languageCode == locale?.languageCode,
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        SectionTitle(l10n.aboutKahwa),
        TileGroup(
          children: [
            NavTile(
              icon: Icons.code_rounded,
              title: l10n.openSource,
              onTap: () => openLink(context, Uri.parse(AppConfig.sourceUrl)),
              trailing: const Icon(Icons.open_in_new_rounded, size: 18),
            ),
            NavTile(
              icon: Icons.chat_bubble_outline_rounded,
              title: l10n.feedback,
              onTap: () => openLink(context, Uri.parse(AppConfig.feedbackUrl)),
              trailing: const Icon(Icons.open_in_new_rounded, size: 18),
            ),
          ],
        ),
      ],
    );
  }
}

/// Asks for the new address and the current password. Firebase then emails
/// a link to the new address, and the change happens when it is opened.
/// Opens the dialog that changes the email of the account, or adds one.
Future<void> showChangeEmailDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const _ChangeEmailDialog(),
  );
}

class _ChangeEmailDialog extends ConsumerStatefulWidget {
  const _ChangeEmailDialog();

  @override
  ConsumerState<_ChangeEmailDialog> createState() => _ChangeEmailDialogState();
}

class _ChangeEmailDialogState extends ConsumerState<_ChangeEmailDialog> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _emailError;
  String? _passwordError;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final auth = ref.read(authRepositoryProvider);
    final email = _email.text.trim();
    final password = _password.text;
    final needsPassword = auth.hasPassword;
    setState(() {
      _emailError = email.isEmpty
          ? l10n.emailMissing
          : !email.contains('@')
          ? l10n.emailInvalid
          : email.toLowerCase() == auth.email?.toLowerCase()
          ? l10n.emailSame
          : null;
      _passwordError = needsPassword && password.isEmpty
          ? l10n.passwordMissing
          : null;
    });
    if (_emailError != null || _passwordError != null) return;

    setState(() => _busy = true);
    try {
      // Without a password, the Google account is asked instead.
      final confirmed = await confirmIdentity(
        context,
        ref,
        password: needsPassword ? password : null,
      );
      if (!confirmed) return;
      await auth.requestEmailChange(email);
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.emailChangeSent(email))),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        switch (e.code) {
          case 'wrong-password' || 'invalid-credential':
            _passwordError = l10n.passwordWrong;
          case 'invalid-email':
            _emailError = l10n.emailInvalid;
          case 'email-already-in-use':
            _emailError = l10n.emailInUse;
          case 'too-many-requests':
            _passwordError = l10n.tooManyAttempts;
          default:
            _passwordError = l10n.somethingWrong;
        }
      });
    } catch (_) {
      if (mounted) setState(() => _passwordError = l10n.somethingWrong);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final auth = ref.watch(authRepositoryProvider);
    final title = auth.email == null ? l10n.addEmail : l10n.changeEmail;
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _email,
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: InputDecoration(
              labelText: l10n.newEmail,
              errorText: _emailError,
            ),
          ),
          if (auth.hasPassword) ...[
            const SizedBox(height: 12),
            PasswordField(
              controller: _password,
              onSubmitted: (_) => _submit(),
              labelText: l10n.currentPassword,
              errorText: _passwordError,
            ),
          ] else if (_passwordError != null) ...[
            const SizedBox(height: 12),
            Text(
              _passwordError!,
              style: TextStyle(color: context.kahwa.danger),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _busy ? null : _submit, child: Text(title)),
      ],
    );
  }
}
