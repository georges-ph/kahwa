import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kahwa/data/collections.dart';
import 'package:kahwa/models/app_user.dart';
import 'package:kahwa/models/balance.dart';
import 'package:kahwa/models/kahwa_prices.dart';

class AuthRepository {
  AuthRepository(this._auth, this._collections);

  final FirebaseAuth _auth;
  final Collections _collections;

  User? get currentUser => _auth.currentUser;

  /// Id of the signed in user. Only call on screens behind the auth redirect.
  String get userId => _auth.currentUser!.uid;

  /// Email of the signed in user. Accounts made with Google may only carry
  /// it on their Google provider, depending on the project's settings.
  String? get email {
    final user = _auth.currentUser;
    if (user == null) return null;
    if (user.email case final email? when email.isNotEmpty) return email;
    return user.providerData
        .map((info) => info.email)
        .firstWhere((email) => (email ?? '').isNotEmpty, orElse: () => null);
  }

  /// True from the start of a sign in until kahwa's documents exist. Firebase
  /// reports the user signed in before that, so the router keeps the sign in
  /// screen open meanwhile, and the first screen finds everything in place.
  final isSigningIn = ValueNotifier(false);

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Also emits when the name of the user changes.
  Stream<User?> get userChanges => _auth.userChanges();

  /// Single email and password entry point. Creates the account when the
  /// email is new, or signs in when it already exists. The Firebase project
  /// is shared with other apps, so an existing account may never have opened
  /// kahwa: either way the documents kahwa needs are created if missing.
  Future<void> continueWithEmail({
    required String email,
    required String password,
  }) {
    return _signIn(() async {
      try {
        final credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        // Not awaited: the account works without it.
        credential.user!.sendEmailVerification().ignore();
        return credential.user!;
      } on FirebaseAuthException catch (e) {
        if (e.code != 'email-already-in-use') rethrow;

        final credential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        return credential.user!;
      }
    });
  }

  /// Runs [signIn], then creates kahwa's documents. If they cannot be
  /// created the user is signed out again, so nobody is left in the app
  /// without them, and the error is passed on.
  Future<void> _signIn(Future<User> Function() signIn) async {
    isSigningIn.value = true;
    try {
      final user = await signIn();
      try {
        await _ensureUserDocuments(user);
      } catch (_) {
        await _auth.signOut();
        rethrow;
      }
    } finally {
      isSigningIn.value = false;
    }
  }

  /// Creates the documents every kahwa user starts with, unless they exist.
  Future<void> _ensureUserDocuments(User user) async {
    final userDoc = _collections.users.doc(user.uid);
    if ((await userDoc.get()).exists) return;

    var name = user.displayName ?? '';
    if (name.isEmpty) {
      // There is no name field on the sign in screen. Start with the part of
      // the email before the @, it can be changed in the profile.
      name = (user.email ?? '').split('@').first;
      await user.updateDisplayName(name);
    }

    final batch = _collections.firestore.batch();
    batch.set(userDoc, AppUser(id: user.uid, name: name).toMap());
    batch.set(
      _collections.kahwaPrices.doc(user.uid),
      const KahwaPrices().toMap(),
    );
    batch.set(_collections.balances.doc(user.uid), const Balance().toMap());
    await batch.commit();
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  /// Signs in with a Google account: a popup on the web, the account picker
  /// on Android. As with an email, a Google account new to kahwa gets its
  /// documents, and one made in another app of the project works right away.
  ///
  /// Throws [GoogleSignInException] with [GoogleSignInExceptionCode.canceled]
  /// when the user closes the Android picker.
  Future<void> signInWithGoogle() {
    return _signIn(() async {
      final UserCredential credential;
      if (kIsWeb) {
        credential = await _auth.signInWithPopup(GoogleAuthProvider());
      } else {
        final account = await GoogleSignIn.instance.authenticate();
        credential = await _auth.signInWithCredential(
          GoogleAuthProvider.credential(
            idToken: account.authentication.idToken,
          ),
        );
      }
      return credential.user!;
    });
  }

  Future<void> signOut() async {
    // Firebase first, so the app leaves at once. Signing out of Google takes
    // a moment and only matters for the next sign in, where it makes the
    // account picker show again.
    await _auth.signOut();
    // Wrapped in a Future so an error, even a synchronous one, is ignored too.
    if (!kIsWeb) Future(GoogleSignIn.instance.signOut).ignore();
  }
}
