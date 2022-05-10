import 'package:flutter/material.dart';
import 'package:kahwa/screens/donate_screens.dart';
import 'package:kahwa/screens/forgot_password_screen.dart';
import 'package:kahwa/screens/home_screen.dart';
import 'package:kahwa/screens/login_screen.dart';
import 'package:kahwa/screens/profile_screen.dart';
import 'package:kahwa/screens/settings_screen.dart';
import 'package:kahwa/screens/sign_up_screen.dart';
import 'package:kahwa/screens/splash_screen.dart';

const routeSplash = "/";
const routeSignUp = "/sign-up";
const routeLogIn = "/log-in";
const routeForgotPassword = "/forgot-password";
const routeHome = "/home";
const routeProfile = "/profile";
const routeDonate = "/donate";
const routeSettings = "/settings";

Map<String, WidgetBuilder> routes = {
  routeSplash: (context) => const SplashScreen(),
  routeSignUp: (context) => const SignUpScreen(),
  routeLogIn: (context) => const LogInScreen(),
  routeForgotPassword: (context) => const ForgotPasswordScreen(),
  routeHome: (context) => const HomeScreen(),
  routeProfile: (context) => const ProfileScreen(),
  // routeDonate: (context) => const DonateScreen(), // Cannot keep this because it conflicts with onGenerateRoute
  routeSettings: (context) => const SettingsScreen(),
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
