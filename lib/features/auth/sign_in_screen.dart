import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kahwa/features/auth/auth_frame.dart';
import 'package:kahwa/features/me/security_screen.dart';
import 'package:kahwa/router.dart';
import 'package:kahwa/state/providers.dart';
import 'package:kahwa/theme/app_theme.dart';
import 'package:kahwa/ui/context.dart';
import 'package:kahwa/ui/widgets.dart';

/// One screen to sign in and to create an account: a new email creates it.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _emailError;
  String? _passwordError;
  bool _hidden = true;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final l10n = context.l10n;
    final email = _email.text.trim();
    final password = _password.text;
    setState(() {
      _emailError = email.isEmpty ? l10n.emailMissing : null;
      _passwordError = switch (password.length) {
        0 => l10n.passwordMissing,
        < 6 => l10n.passwordShort,
        _ => null,
      };
    });
    if (_emailError != null || _passwordError != null) return;

    setState(() => _busy = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .continueWithEmail(email: email, password: password);
      _leave();
    } on FirebaseAuthMultiFactorException catch (e) {
      await _secondStep(e);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        switch (e.code) {
          case 'invalid-email':
            _emailError = l10n.emailInvalid;
          case 'wrong-password' || 'invalid-credential' || 'user-not-found':
            _passwordError = l10n.passwordWrong;
          case 'weak-password':
            _passwordError = l10n.passwordShort;
          case 'too-many-requests':
            showSnack(context, l10n.tooManyAttempts);
          case 'network-request-failed':
            showSnack(context, l10n.noInternet);
          default:
            showSnack(context, l10n.signInFailed);
        }
      });
    } catch (_) {
      if (mounted) showSnack(context, l10n.signInFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Opens the page the user was going to, or Home.
  ///
  /// The router's redirect only does it when this screen is the address
  /// itself: when it was pushed over a page, as "Buy a kahwa" does, the
  /// redirect only sees that page and would leave the user here. Already
  /// gone when the redirect did it.
  void _leave() {
    if (!mounted) return;
    final from = GoRouterState.of(context).uri.queryParameters['from'];
    context.go(from ?? Routes.home);
  }

  /// The account has two-step verification: asks for the code of the
  /// authenticator app, and finishes signing in with it.
  Future<void> _secondStep(FirebaseAuthMultiFactorException e) async {
    final l10n = context.l10n;
    while (true) {
      if (!mounted) return;
      final code = await askForCode(context);
      if (code == null || !context.mounted) return;
      try {
        await ref.read(authRepositoryProvider).finishTwoStepSignIn(e, code);
        _leave();
        return;
      } on FirebaseAuthException catch (error) {
        if (!mounted) return;
        if (error.code != 'invalid-verification-code') {
          showSnack(context, identityError(context, error));
          return;
        }
        showSnack(context, l10n.codeWrong);
      }
    }
  }

  Future<void> _google() async {
    final l10n = context.l10n;
    setState(() => _busy = true);
    // On the web, Firebase can take several seconds to notice that the
    // Google popup was closed without choosing an account. Coming back to
    // the page frees the form sooner; a sign in that does go through still
    // finishes and leaves this screen.
    Timer? unlock;
    final focus = AppLifecycleListener(
      onResume: () {
        unlock?.cancel();
        unlock = Timer(const Duration(milliseconds: 1500), () {
          if (mounted && _busy) setState(() => _busy = false);
        });
      },
    );
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
      _leave();
    } on FirebaseAuthMultiFactorException catch (e) {
      await _secondStep(e);
    } on GoogleSignInException catch (e) {
      if (e.code != GoogleSignInExceptionCode.canceled && mounted) {
        showSnack(context, l10n.googleFailed);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      switch (e.code) {
        case 'popup-closed-by-user' || 'cancelled-popup-request':
          break;
        case 'account-exists-with-different-credential':
          showSnack(context, l10n.googleUsesPassword);
        default:
          showSnack(context, l10n.googleFailed);
      }
    } catch (_) {
      if (mounted) showSnack(context, l10n.googleFailed);
    } finally {
      focus.dispose();
      unlock?.cancel();
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AuthFrame(
      title: l10n.signInTitle,
      subtitle: l10n.signInSubtitle,
      children: [
        AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FieldLabel(
                l10n.email,
                child: TextField(
                  controller: _email,
                  enabled: !_busy,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  decoration: InputDecoration(
                    hintText: 'name@example.com',
                    errorText: _emailError,
                    prefixIcon: const Icon(Icons.mail_outline_rounded),
                  ),
                ),
              ),
              FieldLabel(
                l10n.password,
                child: TextField(
                  controller: _password,
                  enabled: !_busy,
                  obscureText: _hidden,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _continue(),
                  // The same screen signs in and creates accounts, so the
                  // password manager may offer a saved password or suggest
                  // a new one.
                  autofillHints: const [
                    AutofillHints.password,
                    AutofillHints.newPassword,
                  ],
                  decoration: InputDecoration(
                    hintText: l10n.passwordFieldHint,
                    errorText: _passwordError,
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      tooltip: _hidden ? l10n.showPassword : l10n.hidePassword,
                      onPressed: () => setState(() => _hidden = !_hidden),
                      icon: Icon(
                        _hidden
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton(
            onPressed: _busy ? null : () => context.push(Routes.forgotPassword),
            child: Text(l10n.forgotPassword),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _busy ? null : _continue,
          child: _busy
              ? const SizedBox.square(
                  dimension: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                )
              : Text(l10n.continueAction),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                l10n.or,
                style: TextStyle(color: context.kahwa.muted),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: _busy ? null : _google,
          icon: Image.asset('assets/google_logo.png', width: 20, height: 20),
          label: Text(l10n.continueWithGoogle),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.newAccountHint,
          textAlign: TextAlign.center,
          style: context.text.bodySmall?.copyWith(color: context.kahwa.muted),
        ),
      ],
    );
  }
}
