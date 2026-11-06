import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kahwa/core/money.dart';
import 'package:kahwa/features/activity/activity_screen.dart';
import 'package:kahwa/features/admin/admin_screen.dart';
import 'package:kahwa/features/admin/admin_user_screen.dart';
import 'package:kahwa/features/auth/forgot_password_screen.dart';
import 'package:kahwa/features/auth/sign_in_screen.dart';
import 'package:kahwa/features/auth/welcome_screen.dart';
import 'package:kahwa/features/creator/creator_screen.dart';
import 'package:kahwa/features/explore/explore_screen.dart';
import 'package:kahwa/features/home/home_screen.dart';
import 'package:kahwa/features/me/me_screen.dart';
import 'package:kahwa/features/me/memberships_screen.dart';
import 'package:kahwa/features/me/security_screen.dart';
import 'package:kahwa/features/me/settings_screen.dart';
import 'package:kahwa/features/onboarding/onboarding_screen.dart';
import 'package:kahwa/features/shell/app_shell.dart';
import 'package:kahwa/features/studio/direct_pay_screen.dart';
import 'package:kahwa/features/studio/edit_page_screen.dart';
import 'package:kahwa/features/studio/goal_screen.dart';
import 'package:kahwa/features/studio/post_editor_screen.dart';
import 'package:kahwa/features/studio/prices_screen.dart';
import 'package:kahwa/features/studio/stats_screen.dart';
import 'package:kahwa/features/studio/supporters_screen.dart';
import 'package:kahwa/features/support/support_screen.dart';
import 'package:kahwa/features/wallet/billing_screen.dart';
import 'package:kahwa/features/wallet/history_screen.dart';
import 'package:kahwa/features/wallet/top_up_screen.dart';
import 'package:kahwa/features/wallet/wallet_screen.dart';
import 'package:kahwa/features/wallet/withdraw_screen.dart';
import 'package:kahwa/models/profile.dart';
import 'package:kahwa/state/providers.dart';
import 'package:kahwa/state/settings.dart';

abstract final class Routes {
  static const home = '/';
  static const welcome = '/welcome';
  static const signIn = '/sign-in';
  static const forgotPassword = '/forgot-password';
  static const onboarding = '/onboarding';
  static const explore = '/explore';
  static const activity = '/activity';
  static const me = '/me';
  static const editPage = '/me/page';
  static const prices = '/me/prices';
  static const goal = '/me/goal';
  static const post = '/me/post';
  static const stats = '/me/stats';
  static const supporters = '/me/supporters';
  static const memberships = '/me/memberships';
  static const settings = '/me/settings';
  static const billing = '/me/billing';
  static const wallet = '/wallet';
  static const withdraw = '/wallet/withdraw';
  static const history = '/wallet/history';
  static const admin = '/admin';
  static const security = '/me/settings/security';
  static const devices = '/me/settings/devices';
  static const directPayments = '/me/direct-payments';
  static const directPaySettings = '/me/direct-pay';

  static String adminUser(String id) => '/admin/user/$id';

  static String creator(String id) => '/c/$id';

  /// The page of [profile] at its nicest address.
  static String page(Profile profile) {
    final username = profile.username;
    return username == null ? creator(profile.id) : '/$username';
  }

  /// Buying [creatorId] kahwas, or joining [tier] of their memberships.
  /// Under the creator's [username] when known, like their page.
  static String support(
    String creatorId, {
    String? username,
    String? tier,
    int? kahwas,
    Currency? currency,
  }) {
    return _address(
      username == null ? '/c/$creatorId/support' : '/$username/support',
      {
        'tier': ?tier,
        if (kahwas != null) 'kahwas': '$kahwas',
        'currency': ?currency?.name,
      },
    );
  }

  static String topUp({int? amount, Currency? currency}) {
    return _address('/wallet/top-up', {
      if (amount != null) 'amount': '$amount',
      'currency': ?currency?.name,
    });
  }

  static String editPost(String postId) => '$post?id=$postId';

  /// [path] with [query], without a lone `?` when there is none.
  static String _address(String path, Map<String, String> query) {
    return Uri(
      path: path,
      queryParameters: query.isEmpty ? null : query,
    ).toString();
  }

  /// The sign in screen, set to open [location] once the user is in.
  static String signInThen(String location) {
    return Uri(path: signIn, queryParameters: {_from: location}).toString();
  }

  /// Screens only for visitors: a signed in user is sent on.
  static const _visitorOnly = {welcome, signIn, forgotPassword};

  /// Route patterns anyone can open without an account.
  static const _public = {
    welcome,
    signIn,
    forgotPassword,
    explore,
    '/c/:id',
    '/:username',
  };

  /// The tabs that send a user who never finished the first setup to it.
  static const _needsSetup = {home, activity, me};
}

/// Query parameter holding the page to open once the user has signed in.
const _from = 'from';

final _rootKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh(ref);
  final auth = ref.watch(authRepositoryProvider);
  final router = GoRouter(
    navigatorKey: _rootKey,
    refreshListenable: Listenable.merge([refresh, auth.isSigningIn]),
    redirect: (context, state) {
      final signedIn = auth.currentUser != null;
      final path = state.fullPath ?? state.matchedLocation;

      if (!signedIn) {
        // The intro only shows on the first start of the app.
        final introSeen =
            ref.read(sharedPreferencesProvider).getBool(introSeenKey) ?? false;
        if (path == Routes.welcome && introSeen) return Routes.signIn;
        if (Routes._public.contains(path)) return null;
        if (state.matchedLocation == Routes.home) {
          return introSeen ? Routes.signIn : Routes.welcome;
        }
        return Routes.signInThen(state.uri.toString());
      }
      if (Routes._visitorOnly.contains(path)) {
        // Stay until the new user's documents exist.
        if (auth.isSigningIn.value) return null;
        return state.uri.queryParameters[_from] ?? Routes.home;
      }
      final profile = ref.read(myProfileProvider).valueOrNull;
      if (profile != null &&
          !profile.onboarded &&
          Routes._needsSetup.contains(path)) {
        return Routes.onboarding;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: Routes.signIn,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: Routes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.explore,
                builder: (context, state) => ExploreScreen(
                  category: state.uri.queryParameters['category'],
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.activity,
                builder: (context, state) => const ActivityScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.me,
                builder: (context, state) => const MeScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: Routes.editPage,
        builder: (context, state) => const EditPageScreen(),
      ),
      GoRoute(
        path: Routes.prices,
        builder: (context, state) => const PricesScreen(),
      ),
      GoRoute(
        path: Routes.goal,
        builder: (context, state) => const GoalScreen(),
      ),
      GoRoute(
        path: Routes.post,
        builder: (context, state) =>
            PostEditorScreen(postId: state.uri.queryParameters['id']),
      ),
      GoRoute(
        path: Routes.stats,
        builder: (context, state) => const StatsScreen(),
      ),
      GoRoute(
        path: Routes.supporters,
        builder: (context, state) => const SupportersScreen(),
      ),
      GoRoute(
        path: Routes.memberships,
        builder: (context, state) => const MembershipsScreen(),
      ),
      GoRoute(
        path: Routes.settings,
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'security',
            builder: (context, state) => const SecurityScreen(),
          ),
          GoRoute(
            path: 'devices',
            builder: (context, state) => const DevicesScreen(),
          ),
        ],
      ),
      GoRoute(
        path: Routes.directPayments,
        builder: (context, state) => const DirectPaymentsScreen(),
      ),
      GoRoute(
        path: Routes.directPaySettings,
        builder: (context, state) => const DirectPaySettingsScreen(),
      ),
      GoRoute(
        path: Routes.billing,
        builder: (context, state) => const BillingScreen(),
      ),
      GoRoute(
        path: Routes.wallet,
        builder: (context, state) => const WalletScreen(),
        routes: [
          GoRoute(
            path: 'top-up',
            builder: (context, state) {
              final query = state.uri.queryParameters;
              return TopUpScreen(
                amount: int.tryParse(query['amount'] ?? ''),
                currency: _currency(query['currency']),
                fromSupport: state.extra == TopUpOpenedFrom.support,
              );
            },
          ),
          GoRoute(
            path: 'withdraw',
            builder: (context, state) => const WithdrawScreen(),
          ),
          GoRoute(
            path: 'history',
            builder: (context, state) => const HistoryScreen(),
          ),
        ],
      ),
      GoRoute(
        path: Routes.admin,
        builder: (context, state) => const AdminScreen(),
        routes: [
          GoRoute(
            path: 'user/:id',
            builder: (context, state) =>
                AdminUserScreen(userId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: '/c/:id',
        builder: (context, state) =>
            CreatorScreen(creatorId: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'support',
            builder: (context, state) =>
                _support(state, state.pathParameters['id']!),
          ),
        ],
      ),
      // Last, so every address above wins over a username.
      GoRoute(
        path: '/:username',
        builder: (context, state) =>
            UsernameScreen(username: state.pathParameters['username']!),
        routes: [
          GoRoute(
            path: 'support',
            builder: (context, state) => UsernameScreen(
              username: state.pathParameters['username']!,
              builder: (id) => _support(state, id),
            ),
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  // The app reads data once rather than listening to it (see
  // refreshMyData): each page opened, and each return to the app, reads the
  // user's data again.
  var lastLocation = '';
  void onRoute() {
    final location = router.routerDelegate.currentConfiguration.uri.toString();
    if (location == lastLocation) return;
    lastLocation = location;
    if (auth.currentUser == null) return;
    // Not during the navigation's own build.
    Future.microtask(() => refreshMyData(ref.invalidate));
  }

  router.routerDelegate.addListener(onRoute);
  final lifecycle = AppLifecycleListener(
    onResume: () {
      if (auth.currentUser != null) refreshMyData(ref.invalidate);
    },
  );
  ref.onDispose(() {
    router.routerDelegate.removeListener(onRoute);
    lifecycle.dispose();
  });
  return router;
});

Widget _support(GoRouterState state, String creatorId) {
  final query = state.uri.queryParameters;
  return SupportScreen(
    creatorId: creatorId,
    fromPage: state.extra == SupportOpenedFrom.page,
    tierId: query['tier'],
    kahwas: int.tryParse(query['kahwas'] ?? ''),
    currency: _currency(query['currency']),
  );
}

Currency? _currency(String? name) {
  return Currency.values.where((c) => c.name == name).firstOrNull;
}

/// Runs the redirects again when the user signs in or out, and when their
/// profile first loads or finishes the first setup.
class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(Ref ref) {
    ref.listen(authStateProvider, (_, _) => notifyListeners());
    ref.listen(
      myProfileProvider.select((p) => (p.hasValue, p.valueOrNull?.onboarded)),
      (_, _) => notifyListeners(),
    );
  }
}
