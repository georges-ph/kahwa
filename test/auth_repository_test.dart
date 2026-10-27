import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kahwa/data/auth_repository.dart';
import 'package:kahwa/data/collections.dart';

void main() {
  late MockFirebaseAuth auth;
  late Collections collections;
  late AuthRepository repository;

  setUp(() {
    auth = MockFirebaseAuth();
    collections = Collections(FakeFirebaseFirestore());
    repository = AuthRepository(auth, collections);
  });

  test('a new account has its documents before the sign in ends', () async {
    final states = <bool>[];
    repository.isSigningIn.addListener(
      () => states.add(repository.isSigningIn.value),
    );

    await repository.continueWithEmail(
      email: 'new@example.com',
      password: 'secret-password',
    );

    final id = repository.userId;
    expect((await collections.users.doc(id).get()).exists, isTrue);
    expect((await collections.balances.doc(id).get()).exists, isTrue);
    expect((await collections.kahwaPrices.doc(id).get()).exists, isTrue);
    expect(states, [true, false]);
    expect(repository.email, 'new@example.com');
  });

  test('signing out leaves nobody signed in', () async {
    await repository.continueWithEmail(
      email: 'new@example.com',
      password: 'secret-password',
    );
    await repository.signOut();

    expect(repository.currentUser, isNull);
    expect(repository.email, isNull);
  });
}
