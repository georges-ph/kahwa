import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kahwa/data/db.dart';
import 'package:kahwa/models/profile.dart';
import 'package:kahwa/models/wallet.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  AuthRepository(this._auth, this._db, {SharedPreferences? prefs})
    : _prefs = prefs;

  final FirebaseAuth _auth;
  final Db _db;
  final SharedPreferences? _prefs;

  /// The Google account's email by user id, as Google gave it at sign in.
  /// Old Google accounts may have no email in Firebase at all, not even on
  /// their Google provider; this is then the one shown.
  final _googleEmails = <String, String>{};

  String? _googleEmailOf(String uid) =>
      _googleEmails[uid] ?? _prefs?.getString('google_email_$uid');

  /// The email claim of a Google ID token, read without checking it: it only
  /// decides which address is shown.
  static String? _emailInIdToken(String? token) {
    final parts = token?.split('.') ?? const [];
    if (parts.length < 2) return null;
    try {
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      return (jsonDecode(payload) as Map<String, dynamic>)['email'] as String?;
    } catch (_) {
      return null;
    }
  }

  void _keepGoogleEmail(User user, String? email) {
    if (email == null || email.isEmpty) return;
    _googleEmails[user.uid] = email;
    _prefs?.setString('google_email_${user.uid}', email).ignore();
  }

  User? get currentUser => _auth.currentUser;

  /// Email of the signed in user. Accounts made with Google may only carry
  /// it on their Google provider, or only in what Google gave at sign in.
  String? get email {
    final user = _auth.currentUser;
    if (user == null) return null;
    if (user.email case final email? when email.isNotEmpty) return email;
    return user.providerData
            .map((info) => info.email)
            .firstWhere(
              (email) => (email ?? '').isNotEmpty,
              orElse: () => null,
            ) ??
        _googleEmailOf(user.uid);
  }

  /// Whether the user opened the link sent to their email, or signs in with
  /// Google, which already checked the account (old Google accounts may have
  /// no email of their own). Money can only move once it is true; the
  /// security rules check the same.
  bool get emailVerified => _isVerified(_auth.currentUser);

  static bool _isVerified(User? user) {
    if (user == null) return false;
    if (user.emailVerified) return true;
    // Kahwa never links a password to a Google account, so a Google account
    // always signs in with Google, as the rules require.
    final providers = user.providerData.map((info) => info.providerId);
    return providers.contains('google.com') && !providers.contains('password');
  }

  /// Sends the link that verifies the email of the signed in user.
  ///
  /// Some old Google accounts carry their email only on their Google
  /// provider, so Firebase has no address to send to. For those, the link
  /// sets it as the account's email, verified, once opened. Throws
  /// [FirebaseAuthException] `missing-email` when the account has none at all.
  Future<void> sendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user == null) return;
    if ((user.email ?? '').isNotEmpty) return user.sendEmailVerification();
    final email = this.email;
    if (email == null) {
      throw FirebaseAuthException(code: 'missing-email');
    }
    await user.verifyBeforeUpdateEmail(email);
  }

  /// Reads the account again, after the user opened the verification link
  /// elsewhere. The token is refreshed too, as the security rules read
  /// whether the email is verified from it. Returns [emailVerified].
  Future<bool> refreshVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    final fresh = _auth.currentUser;
    if (fresh?.emailVerified ?? false) await fresh!.getIdToken(true);
    return _isVerified(fresh);
  }

  // Two-step verification with an authenticator app (TOTP)

  /// The authenticator apps set up on the account. Empty when two-step
  /// verification is off.
  Future<List<MultiFactorInfo>> secondFactors() async {
    final user = _auth.currentUser;
    if (user == null) return const [];
    return user.multiFactor.getEnrolledFactors();
  }

  /// Starts setting up an authenticator app. The user adds the secret to
  /// their app, by its QR code or by typing it, then confirms with a code
  /// from it in [finishTotp]. Firebase wants a recent sign in for this.
  Future<TotpSecret> startTotp() async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Not signed in');
    final session = await user.multiFactor.getSession();
    return TotpMultiFactorGenerator.generateSecret(session);
  }

  Future<void> finishTotp(TotpSecret secret, String code) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Not signed in');
    final assertion = await TotpMultiFactorGenerator.getAssertionForEnrollment(
      secret,
      code.trim(),
    );
    await user.multiFactor.enroll(assertion, displayName: 'Authenticator');
  }

  Future<void> removeSecondFactor(MultiFactorInfo factor) async {
    await _auth.currentUser?.multiFactor.unenroll(multiFactorInfo: factor);
  }

  /// Finishes a sign in that asked for a code from the authenticator app.
  Future<void> finishTwoStepSignIn(
    FirebaseAuthMultiFactorException e,
    String code,
  ) {
    return _signIn(() async {
      final hint = e.resolver.hints.firstWhere(
        (h) => h is TotpMultiFactorInfo,
        orElse: () => e.resolver.hints.first,
      );
      final assertion = await TotpMultiFactorGenerator.getAssertionForSignIn(
        hint.uid,
        code.trim(),
      );
      final credential = await e.resolver.resolveSignIn(assertion);
      return credential.user!;
    });
  }

  /// Checks it is really the user before a change to their account: their
  /// password, or their Google account. Throws
  /// [FirebaseAuthMultiFactorException] when the account also asks for a
  /// code; [finishTwoStepCheck] completes it.
  Future<void> confirmIdentity({String? password}) async {
    final user = _auth.currentUser;
    final email = this.email;
    if (user == null) throw StateError('Not signed in');
    if (hasPassword) {
      if (email == null || password == null) throw StateError('No password');
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: email, password: password),
      );
    } else if (kIsWeb) {
      await user.reauthenticateWithPopup(GoogleAuthProvider());
    } else {
      final account = await GoogleSignIn.instance.authenticate();
      await user.reauthenticateWithCredential(
        GoogleAuthProvider.credential(idToken: account.authentication.idToken),
      );
    }
  }

  Future<void> finishTwoStepCheck(
    FirebaseAuthMultiFactorException e,
    String code,
  ) async {
    final hint = e.resolver.hints.first;
    final assertion = await TotpMultiFactorGenerator.getAssertionForSignIn(
      hint.uid,
      code.trim(),
    );
    await e.resolver.resolveSignIn(assertion);
  }

  /// Whether the account signs in with a password, so it can change it.
  bool get hasPassword {
    return _auth.currentUser?.providerData.any(
          (info) => info.providerId == 'password',
        ) ??
        false;
  }

  /// True from the start of a sign in until kahwa's documents exist. Firebase
  /// reports the user signed in before that, so the router keeps the sign in
  /// screen open meanwhile, and the first screen finds everything in place.
  final isSigningIn = ValueNotifier(false);

  /// Ticks after this app signs in or out. On the web, Firebase's own
  /// stream does not always reach late listeners, so screens also follow
  /// this.
  final signedInOrOut = ValueNotifier(0);

  Stream<User?> authStateChanges() => _auth.authStateChanges();

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
        _keepGoogleEmail(
          credential.user!,
          credential.additionalUserInfo?.profile?['email'] as String? ??
              _emailInIdToken(
                (credential.credential as OAuthCredential?)?.idToken,
              ),
        );
      } else {
        final account = await GoogleSignIn.instance.authenticate();
        credential = await _auth.signInWithCredential(
          GoogleAuthProvider.credential(
            idToken: account.authentication.idToken,
          ),
        );
        _keepGoogleEmail(credential.user!, account.email);
      }
      return credential.user!;
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
        await ensureUserDocuments(user);
      } catch (_) {
        await _auth.signOut();
        rethrow;
      }
    } finally {
      isSigningIn.value = false;
      signedInOrOut.value++;
    }
  }

  /// Creates the profile and wallet every kahwa user starts with, unless
  /// they exist.
  @visibleForTesting
  Future<void> ensureUserDocuments(User user) async {
    final profileRef = _db.profiles.doc(user.uid);
    final walletRef = _db.wallets.doc(user.uid);
    final (profileDoc, walletDoc) = await (
      profileRef.get(),
      walletRef.get(),
    ).wait;

    final batch = _db.firestore.batch();
    if (!profileDoc.exists) {
      var name = (user.displayName ?? '').trim();
      // There is no name field on the sign in screen. Start with the part of
      // the email before the @; the first setup asks for a real one.
      if (name.isEmpty) name = (user.email ?? '').split('@').first;
      if (name.isEmpty) name = 'kahwa user';
      batch.set(profileRef, Profile(id: user.uid, name: name).toNewMap());
    }
    if (!walletDoc.exists) batch.set(walletRef, Wallet.emptyMap());
    await batch.commit();
  }

  /// Asks to move the account to [newEmail]. Firebase emails a link there,
  /// and the address only changes once it is opened. Firebase wants a recent
  /// sign in: call [confirmIdentity] first.
  Future<void> requestEmailChange(String newEmail) async {
    await _auth.currentUser?.verifyBeforeUpdateEmail(newEmail);
  }

  /// Sets a new password. Firebase wants a recent sign in: call
  /// [confirmIdentity] first.
  Future<void> updatePassword(String newPassword) async {
    await _auth.currentUser?.updatePassword(newPassword);
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    // Firebase first, so the app leaves at once. Signing out of Google takes
    // a moment and only matters for the next sign in, where it makes the
    // account picker show again.
    await _auth.signOut();
    signedInOrOut.value++;
    // Wrapped in a Future so an error, even a synchronous one, is ignored too.
    if (!kIsWeb) Future(GoogleSignIn.instance.signOut).ignore();
  }
}
