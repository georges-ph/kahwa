import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kahwa/features/auth/auth_frame.dart';
import 'package:kahwa/state/email_cooldown.dart';
import 'package:kahwa/state/providers.dart';
import 'package:kahwa/ui/context.dart';
import 'package:kahwa/ui/widgets.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _email = TextEditingController();
  String? _error;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = context.l10n;
    final email = _email.text.trim();
    if (email.isEmpty) {
      setState(() => _error = l10n.emailMissing);
      return;
    }
    setState(() => _error = null);
    // One email every few minutes to the same address, so a tap too many
    // does not flood the inbox.
    final cooldown = ref.read(emailCooldownProvider);
    final left = cooldown.remaining(EmailKind.passwordReset, email);
    if (left > Duration.zero) {
      showSnack(context, l10n.emailWait(left.inSeconds + 1));
      return;
    }
    try {
      await ref.read(authRepositoryProvider).sendPasswordResetEmail(email);
      cooldown.markSent(EmailKind.passwordReset, email);
      if (mounted) setState(() => _sent = true);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      if (e.code == 'invalid-email') {
        setState(() => _error = l10n.emailInvalid);
      } else if (e.code == 'too-many-requests') {
        showSnack(context, l10n.tooManyAttempts);
      } else {
        showSnack(context, l10n.somethingWrong);
      }
    } catch (_) {
      if (mounted) showSnack(context, l10n.somethingWrong);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AuthFrame(
      title: l10n.resetTitle,
      subtitle: l10n.resetSubtitle,
      children: [
        if (_sent)
          Notice(
            tone: Tone.success,
            title: l10n.resetSentTitle,
            message: l10n.resetSent(_email.text.trim()),
          )
        else ...[
          FieldLabel(
            l10n.email,
            child: TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              onSubmitted: (_) => _send(),
              decoration: InputDecoration(
                hintText: 'name@example.com',
                errorText: _error,
                prefixIcon: const Icon(Icons.mail_outline_rounded),
              ),
            ),
          ),
          const SizedBox(height: 8),
          BusyButton(label: l10n.sendResetLink, onPressed: _send),
        ],
      ],
    );
  }
}
