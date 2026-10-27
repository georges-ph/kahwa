import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kahwa/core/feedback.dart';
import 'package:kahwa/core/router.dart';
import 'package:kahwa/data/repositories.dart';
import 'package:kahwa/widgets/auth_layout.dart';
import 'package:kahwa/widgets/input_text.dart';
import 'package:kahwa/widgets/loading_button.dart';

/// The only way in: the same form logs in or creates the account, depending
/// on whether the email is already known.
class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  bool _isPasswordHidden = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _continueWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      // The router leaves this screen as soon as the user is signed in.
      await authRepository.signInWithGoogle();
    } on GoogleSignInException catch (e) {
      if (e.code != GoogleSignInExceptionCode.canceled && mounted) {
        showSnack(context, 'Google sign in error, please try again');
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      switch (e.code) {
        case 'popup-closed-by-user' || 'cancelled-popup-request':
          break;
        case 'account-exists-with-different-credential':
          showSnack(context, 'This email signs in with a password');
        default:
          showSnack(context, 'Google sign in error, please try again');
      }
    } catch (_) {
      if (mounted) showSnack(context, 'Google sign in error, please try again');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _continue() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _emailError = email.isEmpty ? 'Enter your email' : null;
      _passwordError = switch (password.length) {
        0 => 'Enter your password',
        < 6 => 'Password must be at least 6 characters',
        _ => null,
      };
    });
    if (_emailError != null || _passwordError != null) return;

    setState(() => _isLoading = true);
    try {
      // The router leaves this screen as soon as the user is signed in.
      await authRepository.continueWithEmail(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        switch (e.code) {
          case 'invalid-email':
            _emailError = 'Invalid email address';
          case 'wrong-password' || 'invalid-credential' || 'user-not-found':
            _passwordError = 'Wrong email or password';
          case 'weak-password':
            _passwordError = 'Password must be at least 6 characters';
          case 'too-many-requests':
            showSnack(context, 'Too many attempts, try again later');
          case 'network-request-failed':
            showSnack(context, 'Check your internet connection');
          default:
            showSnack(context, 'Sign in error, please try again');
        }
      });
    } catch (_) {
      if (mounted) showSnack(context, 'Sign in error, please try again');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Sign in',
      illustration: 'assets/undraw_login.svg',
      children: [
        InputText(
          controller: _emailController,
          icon: Icons.mail_rounded,
          hint: 'Email Address',
          errorText: _emailError,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
        ),
        const SizedBox(height: 16),
        InputText(
          controller: _passwordController,
          icon: Icons.lock_rounded,
          hint: 'Password',
          errorText: _passwordError,
          obscureText: _isPasswordHidden,
          textInputAction: TextInputAction.done,
          // The same screen signs in and creates accounts, so the password
          // manager may offer a saved password or suggest a new strong one.
          autofillHints: const [
            AutofillHints.password,
            AutofillHints.newPassword,
          ],
          suffixIcon: _isPasswordHidden
              ? Icons.visibility_rounded
              : Icons.visibility_off_rounded,
          suffixTooltip: _isPasswordHidden ? 'Show password' : 'Hide password',
          suffixOnTap: () {
            setState(() => _isPasswordHidden = !_isPasswordHidden);
          },
          onSubmitted: (_) => _continue(),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => context.push(Routes.forgotPassword),
            child: const Text('Forgot Password'),
          ),
        ),
        LoadingButton(
          label: 'Continue',
          isLoading: _isLoading,
          onPressed: _continue,
        ),
        const _Or(),
        OutlinedButton.icon(
          onPressed: _isLoading ? null : _continueWithGoogle,
          icon: Image.asset('assets/google_logo.png', width: 20, height: 20),
          label: const Text('Continue with Google'),
        ),
      ],
    );
  }
}

/// A thin line with "or" in the middle, between the two ways to sign in.
class _Or extends StatelessWidget {
  const _Or();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('or'),
        ),
        Expanded(child: Divider()),
      ],
    );
  }
}
