import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kahwa/data/auth_repository.dart';
import 'package:kahwa/data/db.dart';
import 'package:kahwa/models/profile.dart';

void main() {
  late Db db;
  late AuthRepository auth;

  setUp(() {
    db = Db(FakeFirebaseFirestore());
    auth = AuthRepository(MockFirebaseAuth(), db);
  });

  test('a new account gets a profile named after its email', () async {
    await auth.ensureUserDocuments(
      MockUser(uid: 'u1', email: 'nour.h@example.com'),
    );
    final profile = Profile.fromMap(
      (await db.profiles.doc('u1').get()).data()!,
      id: 'u1',
    );
    expect(profile.name, 'nour.h');
    expect(profile.onboarded, isFalse);
    final wallet = (await db.wallets.doc('u1').get()).data()!;
    expect(wallet['current_lbp'], 0);
  });

  test('a Google account keeps its display name', () async {
    await auth.ensureUserDocuments(
      MockUser(uid: 'u2', email: 'x@example.com', displayName: 'Sami Khoury'),
    );
    expect((await db.profiles.doc('u2').get()).data()!['name'], 'Sami Khoury');
  });

  test('existing documents are left as they are', () async {
    await db.profiles.doc('u3').set({'name': 'Maya', 'onboarded': true});
    await db.wallets.doc('u3').set({'current_lbp': 5000});
    await auth.ensureUserDocuments(
      MockUser(uid: 'u3', email: 'maya@example.com'),
    );
    expect((await db.profiles.doc('u3').get()).data()!['name'], 'Maya');
    expect((await db.wallets.doc('u3').get()).data()!['current_lbp'], 5000);
  });
}
