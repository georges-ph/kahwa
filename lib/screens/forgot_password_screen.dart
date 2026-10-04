import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kahwa/core/feedback.dart';
import 'package:kahwa/core/router.dart';
import 'package:kahwa/data/repositories.dart';
import 'package:kahwa/widgets/auth_layout.dart';
import 'package:kahwa/widgets/input_text.dart';
import 'package:kahwa/widgets/loading_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  String? _emailError;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    setState(() {
      _emailError = email.isEmpty ? 'Email Address cannot be empty' : null;
    });
    if (_emailError != null) return;

    setState(() => _isLoading = true);
    try {
      await authRepository.sendPasswordResetEmail(email);
      if (!mounted) return;
      showSnack(
        context,
        'An email will be sent to you shortly to reset your password',
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        switch (e.code) {
          case 'invalid-email':
            _emailError = e.message;
          case 'user-not-found':
            _emailError = 'Email address does not exist';
          default:
            showSnack(context, e.message ?? 'Could not send the email');
        }
      });
    } catch (_) {
      if (mounted) showSnack(context, 'Could not send the email, try again');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Forgot Password',
      illustration: 'assets/undraw_forgot_password.svg',
      children: [
        InputText(
          controller: _emailController,
          icon: Icons.mail_rounded,
          hint: 'Email Address',
          errorText: _emailError,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.email],
          onSubmitted: (_) => _resetPassword(),
        ),
        const SizedBox(height: 24),
        LoadingButton(
          label: 'Reset Password',
          isLoading: _isLoading,
          onPressed: _resetPassword,
        ),
        TextButton(
          onPressed: () {
            context.canPop() ? context.pop() : context.go(Routes.logIn);
          },
          child: const Text('Back to Log In'),
        ),
      ],
    );
  }
}
