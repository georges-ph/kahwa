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

  /// Also emits when the name or picture of the user changes.
  Stream<User?> get userChanges => _auth.userChanges();

  Future<void> signIn({required String email, required String password}) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Creates the account and the documents every user starts with.
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user!;
    await user.updateDisplayName(name);

    final batch = _collections.firestore.batch();
    batch.set(
      _collections.users.doc(user.uid),
      AppUser(id: user.uid, name: name, email: email).toMap(),
    );
    batch.set(
      _collections.kahwaPrices.doc(user.uid),
      const KahwaPrices().toMap(),
    );
    batch.set(_collections.balances.doc(user.uid), const Balance().toMap());
    await batch.commit();

    await user.sendEmailVerification();
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() => _auth.signOut();
}
