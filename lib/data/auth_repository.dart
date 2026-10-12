import 'package:firebase_auth/firebase_auth.dart';
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
  }) async {
    User user;
    var isNew = false;

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = credential.user!;
      isNew = true;
    } on FirebaseAuthException catch (e) {
      if (e.code != 'email-already-in-use') rethrow;

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = credential.user!;
    }

    await _ensureUserDocuments(user);
    if (isNew) await user.sendEmailVerification();
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

  Future<void> signOut() => _auth.signOut();
}
