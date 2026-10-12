import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:kahwa/data/repositories.dart';
import 'package:kahwa/screens/admin_screen.dart';
import 'package:kahwa/screens/balance_screen.dart';
import 'package:kahwa/screens/billing_details_screen.dart';
import 'package:kahwa/screens/creator_screen.dart';
import 'package:kahwa/screens/donate_screen.dart';
import 'package:kahwa/screens/fans_supporters_screen.dart';
import 'package:kahwa/screens/forgot_password_screen.dart';
import 'package:kahwa/screens/goal_screen.dart';
import 'package:kahwa/screens/home_screen.dart';
import 'package:kahwa/screens/top_up_screen.dart';
import 'package:kahwa/screens/username_screen.dart';
import 'package:kahwa/screens/kahwa_price_screen.dart';
import 'package:kahwa/screens/login_screen.dart';
import 'package:kahwa/screens/profile_screen.dart';
import 'package:kahwa/screens/request_withdraw_screen.dart';
import 'package:kahwa/screens/settings_screen.dart';

abstract final class Routes {
  static const home = '/';
  static const logIn = '/log-in';
  static const forgotPassword = '/forgot-password';
  static const goal = '/goal';
  static const settings = '/settings';
  static const profile = '/settings/profile';
  static const kahwaPrice = '/settings/kahwa-price';
  static const balance = '/settings/balance';
  static const requestWithdraw = '/settings/balance/withdraw';
  static const topUp = '/settings/balance/top-up';
  static const admin = '/settings/admin';
  static const billingDetails = '/settings/billing-details';

  static String creator(String id) => '/c/$id';
  static String donate(String id) => '/c/$id/donate';
  static String fans(String id) => '/c/$id/fans';
  static String supporters(String id) => '/c/$id/supporters';

  /// The sign in screen, set to open [location] once the user is in.
  static String signInThen(String location) {
    return Uri(
      path: logIn,
      queryParameters: {_fromParameter: location},
    ).toString();
  }

  /// Screens that are only reachable while signed out.
  static const _auth = {logIn, forgotPassword};

  /// Route patterns anyone can open without an account: creator pages.
  static const _public = {'/c/:id', '/:username'};
}

/// Query parameter holding the page to open once the user has signed in.
const _fromParameter = 'from';

GoRouter createRouter() {
  return GoRouter(
    refreshListenable: _StreamListenable(authRepository.authStateChanges),
    redirect: (context, state) {
      final isSignedIn = authRepository.currentUser != null;
      final isAuthRoute = Routes._auth.contains(state.matchedLocation);

      if (!isSignedIn) {
        if (isAuthRoute || Routes._public.contains(state.fullPath)) return null;
        final from = state.uri.toString();
        return Uri(
          path: Routes.logIn,
          queryParameters: from == Routes.home ? null : {_fromParameter: from},
        ).toString();
      }
      if (isAuthRoute) {
        return state.uri.queryParameters[_fromParameter] ?? Routes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: Routes.logIn,
        builder: (context, state) => const LogInScreen(),
      ),
      GoRoute(
        path: Routes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/c/:id',
        builder: (context, state) =>
            CreatorScreen(creatorId: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'donate',
            builder: (context, state) =>
                DonateScreen(creatorId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'fans',
            builder: (context, state) => FansSupportersScreen(
              creatorId: state.pathParameters['id']!,
              kind: FansSupportersKind.fans,
            ),
          ),
          GoRoute(
            path: 'supporters',
            builder: (context, state) => FansSupportersScreen(
              creatorId: state.pathParameters['id']!,
              kind: FansSupportersKind.supporters,
            ),
          ),
        ],
      ),
      GoRoute(
        path: Routes.goal,
        builder: (context, state) => const GoalScreen(),
      ),
      GoRoute(
        path: Routes.settings,
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: 'kahwa-price',
            builder: (context, state) => const KahwaPriceScreen(),
          ),
          GoRoute(
            path: 'balance',
            builder: (context, state) => const BalanceScreen(),
            routes: [
              GoRoute(
                path: 'withdraw',
                builder: (context, state) => const RequestWithdrawScreen(),
              ),
              GoRoute(
                path: 'top-up',
                builder: (context, state) => const TopUpScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'admin',
            builder: (context, state) => const AdminScreen(),
          ),
          GoRoute(
            path: 'billing-details',
            builder: (context, state) => const BillingDetailsScreen(),
          ),
        ],
      ),
      // Last, so every address above wins over a username.
      GoRoute(
        path: '/:username',
        builder: (context, state) =>
            UsernameScreen(username: state.pathParameters['username']!),
      ),
    ],
  );
}

/// Notifies the router every time [stream] emits, so redirects run again.
class _StreamListenable extends ChangeNotifier {
  _StreamListenable(Stream<Object?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
