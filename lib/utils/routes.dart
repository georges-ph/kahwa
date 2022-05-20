import 'package:flutter/material.dart';
import 'package:kahwa/models/balance.dart';
import 'package:kahwa/screen_arguments/fans_supporters_args.dart';
import 'package:kahwa/screens/balance_screen.dart';
import 'package:kahwa/screens/billing_details_screen.dart';
import 'package:kahwa/screens/creator_screen.dart';
import 'package:kahwa/screens/donate_screen.dart';
import 'package:kahwa/screens/fans_supporters_screen.dart';
import 'package:kahwa/screens/forgot_password_screen.dart';
import 'package:kahwa/screens/goal_screen.dart';
import 'package:kahwa/screens/home_screen.dart';
import 'package:kahwa/screens/kahwa_price_screen.dart';
import 'package:kahwa/screens/login_screen.dart';
import 'package:kahwa/screens/profile_screen.dart';
import 'package:kahwa/screens/request_withdraw_screen.dart';
import 'package:kahwa/screens/settings_screen.dart';
import 'package:kahwa/screens/sign_up_screen.dart';
import 'package:kahwa/screens/splash_screen.dart';

const routeSplash = "/";
const routeSignUp = "/sign-up";
const routeLogIn = "/log-in";
const routeForgotPassword = "/forgot-password";
const routeHome = "/home";
const routeDonate = "/donate";
const routeSettings = "/settings";
const routeProfile = "/profile";
const routeKahwaPrice = "/kahwa-price";
const routeBalance = "/balance";
const routeRequestWithdraw = "/withdraw";
const routeBillingDetails = "/billing-details";
const routeCreator = "/creator";
const routeFansSupporters = "/fans-supporters";
const routeGoal = "/goal";

Map<String, WidgetBuilder> routes = {
  routeSplash: (context) => const SplashScreen(),
  routeSignUp: (context) => const SignUpScreen(),
  routeLogIn: (context) => const LogInScreen(),
  routeForgotPassword: (context) => const ForgotPasswordScreen(),
  routeHome: (context) => const HomeScreen(),
  // routeDonate: (context) => const DonateScreen(), // Cannot keep this because it conflicts with onGenerateRoute
  routeSettings: (context) => const SettingsScreen(),
  routeProfile: (context) => const ProfileScreen(),
  routeKahwaPrice: (context) => const KahwaPriceScreen(),
  routeBalance: (context) => const BalanceScreen(),
  routeBillingDetails: (context) => const BillingDetailsScreen(),
  routeGoal: (context) => const GoalScreen(),
};

Route<dynamic>? onGenerateRoute(settings) {
  late Widget page;
  if (settings.name == routeDonate) {
    page = DonateScreen(
      creatorId: settings.arguments as String,
    );
  } else if (settings.name == routeCreator) {
    page = CreatorScreen(
      creatorId: settings.arguments as String,
    );
  } else if (settings.name == routeFansSupporters) {
    final args = settings.arguments as FansSupportersArgs;
    page = FansSupportersScreen(
      title: args.title,
      list: args.list,
    );
  } else if (settings.name == routeRequestWithdraw) {
    page = RequestWithdrawScreen(
      balance: settings.arguments as Balance,
    );
  }
  return MaterialPageRoute(
    builder: (context) => page,
  );
}
