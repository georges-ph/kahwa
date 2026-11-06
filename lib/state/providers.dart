import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kahwa/data/activity_repository.dart';
import 'package:kahwa/data/admin_repository.dart';
import 'package:kahwa/data/auth_repository.dart';
import 'package:kahwa/data/db.dart';
import 'package:kahwa/data/device_repository.dart';
import 'package:kahwa/data/post_repository.dart';
import 'package:kahwa/data/profile_repository.dart';
import 'package:kahwa/data/support_repository.dart';
import 'package:kahwa/data/wallet_repository.dart';
import 'package:kahwa/models/activity.dart';
import 'package:kahwa/models/donation.dart';
import 'package:kahwa/models/goal.dart';
import 'package:kahwa/models/membership.dart';
import 'package:kahwa/models/money_requests.dart';
import 'package:kahwa/models/post.dart';
import 'package:kahwa/models/profile.dart';
import 'package:kahwa/models/wallet.dart';
import 'package:kahwa/state/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Firebase and repositories. Tests override the first two.

final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);
final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);
final dbProvider = Provider((ref) => Db(ref.watch(firestoreProvider)));

final authRepositoryProvider = Provider((ref) {
  SharedPreferences? prefs;
  try {
    prefs = ref.watch(sharedPreferencesProvider);
  } catch (_) {
    // Not set up in some tests; the Google email is then only kept in memory.
  }
  return AuthRepository(
    ref.watch(firebaseAuthProvider),
    ref.watch(dbProvider),
    prefs: prefs,
  );
});
final profileRepositoryProvider = Provider(
  (ref) => ProfileRepository(ref.watch(dbProvider)),
);
final supportRepositoryProvider = Provider(
  (ref) => SupportRepository(ref.watch(dbProvider)),
);
final postRepositoryProvider = Provider(
  (ref) => PostRepository(ref.watch(dbProvider)),
);
final activityRepositoryProvider = Provider(
  (ref) => ActivityRepository(ref.watch(dbProvider)),
);
final walletRepositoryProvider = Provider(
  (ref) => WalletRepository(ref.watch(dbProvider)),
);
final adminRepositoryProvider = Provider(
  (ref) => AdminRepository(ref.watch(dbProvider)),
);
final deviceRepositoryProvider = Provider(
  (ref) => DeviceRepository(
    ref.watch(dbProvider),
    ref.watch(sharedPreferencesProvider),
  ),
);

// The signed in user

/// The signed in user. Starts from the current one, and also checks again
/// whenever this app signs in or out: on the web, Firebase does not always
/// pass its changes on to a listener that came late.
final authStateProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final repository = ref.watch(authRepositoryProvider);
  final controller = StreamController<User?>();
  void check() => controller.add(auth.currentUser);
  final subscription = repository.authStateChanges().listen(controller.add);
  repository.signedInOrOut.addListener(check);
  ref.onDispose(() {
    subscription.cancel();
    repository.signedInOrOut.removeListener(check);
    controller.close();
  });
  check();
  return controller.stream.distinct((a, b) => a?.uid == b?.uid);
});

/// Id of the signed in user, null for a visitor.
final userIdProvider = Provider<String?>(
  (ref) => ref.watch(authStateProvider).valueOrNull?.uid,
);

// Data is read once rather than listened to, which would cost a read for
// every change. [refreshMyData] reads it again: on every page change, when
// the app comes back to the front, on pull to refresh and after the user
// changes something.

/// The signed in user's own profile.
final myProfileProvider = FutureProvider<Profile?>((ref) {
  final id = ref.watch(userIdProvider);
  if (id == null) return Future.value();
  return ref.watch(profileRepositoryProvider).get(id);
});

final myWalletProvider = FutureProvider<Wallet>((ref) {
  final id = ref.watch(userIdProvider);
  if (id == null) return Future.value(const Wallet());
  return ref.watch(walletRepositoryProvider).fetch(id);
});

final isAdminProvider = FutureProvider<bool>((ref) async {
  final id = ref.watch(userIdProvider);
  if (id == null) return false;
  return ref.watch(adminRepositoryProvider).isAdmin(id);
});

final activityProvider = FutureProvider<List<Activity>>((ref) {
  final id = ref.watch(userIdProvider);
  if (id == null) return Future.value(const []);
  return ref.watch(activityRepositoryProvider).fetch(id);
});

final unreadCountProvider = Provider<int>((ref) {
  final entries = ref.watch(activityProvider).valueOrNull ?? const [];
  return entries.where((a) => !a.read).length;
});

final myTopUpProvider = FutureProvider<TopUpRequest?>((ref) {
  final id = ref.watch(userIdProvider);
  if (id == null) return Future.value();
  return ref.watch(walletRepositoryProvider).lastTopUp(id);
});

final myMembershipsProvider = FutureProvider<List<Membership>>((ref) {
  final id = ref.watch(userIdProvider);
  if (id == null) return Future.value(const []);
  return ref.watch(supportRepositoryProvider).membershipsOf(id);
});

final pendingKahwaProvider = FutureProvider<PendingKahwa?>((ref) {
  final id = ref.watch(userIdProvider);
  if (id == null) return Future.value();
  return ref.watch(supportRepositoryProvider).pending(id);
});

/// Memberships of the user that could not renew for lack of balance, found
/// when the app opened.
final unpaidMembershipsProvider = StateProvider<List<Membership>>(
  (ref) => const [],
);

// Pages

final profileProvider = FutureProvider.autoDispose.family<Profile?, String>(
  (ref, id) => ref.watch(profileRepositoryProvider).get(id),
);

final profilesProvider = FutureProvider.autoDispose
    .family<Map<String, Profile>, ProfileIds>((ref, ids) async {
      final profiles = await ref
          .watch(profileRepositoryProvider)
          .getMany(ids.ids);
      return {for (final p in profiles) p.id: p};
    });

/// A set of profile ids usable as a provider key.
class ProfileIds {
  ProfileIds(Iterable<String> ids) : ids = (ids.toSet().toList()..sort());

  final List<String> ids;

  @override
  bool operator ==(Object other) =>
      other is ProfileIds && other.ids.join(',') == ids.join(',');

  @override
  int get hashCode => ids.join(',').hashCode;
}

final usernameProvider = FutureProvider.autoDispose.family<String?, String>(
  (ref, username) =>
      ref.watch(profileRepositoryProvider).idOfUsername(username),
);

final goalProvider = FutureProvider.autoDispose.family<Goal?, String>(
  (ref, id) => ref.watch(supportRepositoryProvider).getGoal(id),
);

final donationsToProvider = FutureProvider.autoDispose
    .family<List<Donation>, String>((ref, creatorId) {
      return ref
          .watch(supportRepositoryProvider)
          .donationsTo(creatorId, viewerId: ref.watch(userIdProvider));
    });

final postsOfProvider = FutureProvider.autoDispose.family<List<Post>, String>((
  ref,
  creatorId,
) {
  return ref
      .watch(postRepositoryProvider)
      .postsOf(creatorId, viewerId: ref.watch(userIdProvider));
});

final creatorsProvider = FutureProvider.autoDispose<List<Profile>>(
  (ref) => ref.watch(profileRepositoryProvider).creators(),
);

/// The creators the signed in user is a fan of.
final myCreatorsProvider = FutureProvider.autoDispose<List<Profile>>((ref) {
  final id = ref.watch(userIdProvider);
  if (id == null) return Future.value(const []);
  return ref.watch(profileRepositoryProvider).fannedBy(id);
});

// Account security

/// Whether the signed in user verified their email, read again from
/// Firebase: they open the link outside the app, so it is read again each
/// time the app comes back to the front, until it is true.
final emailVerifiedProvider = FutureProvider<bool>((ref) async {
  ref.watch(userIdProvider);
  final verified = await ref.watch(authRepositoryProvider).refreshVerified();
  if (!verified) {
    final listener = AppLifecycleListener(onResume: ref.invalidateSelf);
    ref.onDispose(listener.dispose);
  }
  return verified;
});

/// Keeps this device in the signed in user's list of devices, and signs out
/// here when it is signed out from another one. Watched by the app.
final deviceSessionProvider = Provider<void>((ref) {
  final id = ref.watch(userIdProvider);
  if (id == null) return;
  final devices = ref.watch(deviceRepositoryProvider);
  final auth = ref.watch(authRepositoryProvider);
  Future<void> check() async {
    final user = auth.currentUser;
    if (user == null || user.uid != id) return;
    final session =
        user.metadata.lastSignInTime?.millisecondsSinceEpoch.toString() ?? '';
    try {
      if (!await devices.checkIn(id, session: session)) await auth.signOut();
    } catch (_) {
      // Offline or the like: checked again next time.
    }
  }

  check();
  // No listener on the device list, to keep reads low: checked again each
  // time the app comes back to the front.
  final listener = AppLifecycleListener(onResume: check);
  ref.onDispose(listener.dispose);
});

final myDevicesProvider = FutureProvider.autoDispose<List<SignedInDevice>>((
  ref,
) {
  final id = ref.watch(userIdProvider);
  if (id == null) return Future.value(const []);
  return ref.watch(deviceRepositoryProvider).fetch(id);
});

final secondFactorsProvider = FutureProvider.autoDispose<List<MultiFactorInfo>>(
  (ref) {
    ref.watch(userIdProvider);
    return ref.watch(authRepositoryProvider).secondFactors();
  },
);

/// Whether [creatorId] takes payments to their own WHISH account.
final directPayProvider = FutureProvider.autoDispose.family<DirectPay, String>(
  (ref, creatorId) => ref.watch(supportRepositoryProvider).directPay(creatorId),
);

/// Payments sent straight to the signed in creator's WHISH account.
final myDirectPaymentsProvider =
    FutureProvider.autoDispose<List<DirectPayment>>((ref) {
      final id = ref.watch(userIdProvider);
      if (id == null) return Future.value(const []);
      return ref.watch(supportRepositoryProvider).directPaymentsTo(id);
    });

/// Reads the user's data again: their profile, wallet, inbox, top up and
/// payments, and the pages and goals on screen. Shown values stay while the
/// new ones load.
void refreshMyData(void Function(ProviderOrFamily) invalidate) {
  invalidate(myProfileProvider);
  invalidate(myWalletProvider);
  invalidate(activityProvider);
  invalidate(myTopUpProvider);
  invalidate(myDirectPaymentsProvider);
  invalidate(myDevicesProvider);
  invalidate(profileProvider);
  invalidate(goalProvider);
}
