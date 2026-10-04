import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kahwa/core/feedback.dart';
import 'package:kahwa/core/router.dart';
import 'package:kahwa/data/repositories.dart';
import 'package:kahwa/widgets/auth_layout.dart';
import 'package:kahwa/widgets/input_text.dart';
import 'package:kahwa/widgets/loading_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  bool _isPasswordHidden = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _nameError = name.isEmpty ? 'Name cannot be empty' : null;
      _emailError = email.isEmpty ? 'Email Address cannot be empty' : null;
      _passwordError = password.isEmpty ? 'Password cannot be empty' : null;
    });
    if (_nameError != null || _emailError != null || _passwordError != null) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      // The router leaves this screen as soon as the account exists.
      await authRepository.signUp(name: name, email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        switch (e.code) {
          case 'invalid-email' || 'email-already-in-use':
            _emailError = e.message;
          case 'weak-password':
            _passwordError = e.message;
          default:
            showSnack(context, e.message ?? 'Could not sign up');
        }
      });
    } catch (_) {
      if (mounted) showSnack(context, 'Could not sign up, try again');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Create an account',
      illustration: 'assets/undraw_authentication.svg',
      children: [
        InputText(
          controller: _nameController,
          icon: Icons.person_rounded,
          hint: 'Name',
          errorText: _nameError,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          autofillHints: const [AutofillHints.name],
        ),
        const SizedBox(height: 16),
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
          autofillHints: const [AutofillHints.newPassword],
          suffixIcon: _isPasswordHidden
              ? Icons.visibility_rounded
              : Icons.visibility_off_rounded,
          suffixTooltip: _isPasswordHidden ? 'Show password' : 'Hide password',
          suffixOnTap: () {
            setState(() => _isPasswordHidden = !_isPasswordHidden);
          },
          onSubmitted: (_) => _signUp(),
        ),
        const SizedBox(height: 24),
        LoadingButton(
          label: 'Sign Up',
          isLoading: _isLoading,
          onPressed: _signUp,
        ),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Already have an account?',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            TextButton(
              onPressed: () => context.go(authRoute(context, Routes.logIn)),
              child: const Text('Log In'),
            ),
          ],
        ),
      ],
    );
  }
}
