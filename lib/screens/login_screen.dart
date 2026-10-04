import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kahwa/core/feedback.dart';
import 'package:kahwa/core/router.dart';
import 'package:kahwa/data/repositories.dart';
import 'package:kahwa/widgets/auth_layout.dart';
import 'package:kahwa/widgets/input_text.dart';
import 'package:kahwa/widgets/loading_button.dart';

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

  Future<void> _logIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _emailError = email.isEmpty ? 'Email Address cannot be empty' : null;
      _passwordError = password.isEmpty ? 'Password cannot be empty' : null;
    });
    if (_emailError != null || _passwordError != null) return;

    setState(() => _isLoading = true);
    try {
      // The router leaves this screen as soon as the user is signed in.
      await authRepository.signIn(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        switch (e.code) {
          case 'invalid-email':
            _emailError = e.message;
          case 'user-not-found':
            _emailError = 'Email address does not exist';
          case 'wrong-password':
            _passwordError = 'Incorrect password';
          case 'invalid-credential':
            _passwordError = 'Incorrect email or password';
          default:
            showSnack(context, e.message ?? 'Could not log in');
        }
      });
    } catch (_) {
      if (mounted) showSnack(context, 'Could not log in, try again');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Log In',
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
          autofillHints: const [AutofillHints.password],
          suffixIcon: _isPasswordHidden
              ? Icons.visibility_rounded
              : Icons.visibility_off_rounded,
          suffixTooltip: _isPasswordHidden ? 'Show password' : 'Hide password',
          suffixOnTap: () {
            setState(() => _isPasswordHidden = !_isPasswordHidden);
          },
          onSubmitted: (_) => _logIn(),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => context.push(Routes.forgotPassword),
            child: const Text('Forgot Password'),
          ),
        ),
        LoadingButton(
          label: 'Log In',
          isLoading: _isLoading,
          onPressed: _logIn,
        ),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              "Don't have an account?",
              style: Theme.of(context).textTheme.labelLarge,
            ),
            TextButton(
              onPressed: () => context.go(authRoute(context, Routes.signUp)),
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ],
    );
  }
}
