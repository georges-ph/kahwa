import 'package:flutter/material.dart';
import 'package:kahwa/screens/donate/donate_screens.dart';
import 'package:kahwa/screens/forgot_password/forgot_password_screen.dart';
import 'package:kahwa/screens/login/login_screen.dart';
import 'package:kahwa/screens/profile/profile_screen.dart';
import 'package:kahwa/screens/sign_up/sign_up_screen.dart';
import 'package:kahwa/screens/splash/splash_screen.dart';

const routeSplash = "/";
const routeSignUp = "/sign-up";
const routeLogIn = "/log-in";
const routeForgotPassword = "/forgot-password";
const routeProfile = "/profile";
const routeDonate = "/donate";

Map<String, WidgetBuilder> routes = {
  routeSplash: (context) => const SplashScreen(),
  routeSignUp: (context) => const SignUpScreen(),
  routeLogIn: (context) => const LogInScreen(),
  routeProfile: (context) => const ProfileScreen(),
  routeForgotPassword: (context) => const ForgotPasswordScreen(),
  // routeDonate: (context) => const DonateScreen(), // Cannot keep this because it conflicts with onGenerateRoute
};

Route<dynamic>? onGenerateRoute(settings) {
  if (settings.name == routeDonate) {
    return MaterialPageRoute(
      builder: (context) => DonateScreen(
        creatorId: settings.arguments as String,
      ),
    );
  }
  return null;
}
