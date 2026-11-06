import 'package:cloud_firestore/cloud_firestore.dart';

typedef Json = Map<String, dynamic>;
typedef JsonCollection = CollectionReference<Json>;
typedef JsonDocument = DocumentReference<Json>;

/// Firestore collections of kahwa 3, all under `kahwa/AppData`. kahwa 2 kept
/// its data under `kahwa/AppCollections`; the two never mix.
class Db {
  Db(this.firestore);

  final FirebaseFirestore firestore;

  JsonDocument get _root => firestore.collection('kahwa').doc('AppData');

  JsonCollection get profiles => _root.collection('Profiles');
  JsonCollection get usernames => _root.collection('Usernames');
  JsonCollection get goals => _root.collection('Goals');
  JsonCollection get wallets => _root.collection('Wallets');
  JsonCollection get donations => _root.collection('Donations');
  JsonCollection get donationDetails => _root.collection('DonationDetails');
  JsonCollection get memberships => _root.collection('Memberships');
  JsonCollection get posts => _root.collection('Posts');
  JsonCollection get postBodies => _root.collection('PostBodies');
  JsonCollection get activity => _root.collection('Activity');
  JsonCollection get billing => _root.collection('BillingDetails');
  JsonCollection get topUpRequests => _root.collection('TopUpRequests');
  JsonCollection get topUpHistory => _root.collection('TopUpHistory');
  JsonCollection get withdrawRequests => _root.collection('WithdrawRequests');
  JsonCollection get pendingKahwas => _root.collection('PendingKahwas');
  JsonCollection get admins => _root.collection('Admins');
  JsonCollection get config => _root.collection('Config');
  JsonCollection get adjustments => _root.collection('Adjustments');
  JsonCollection get directPay => _root.collection('DirectPay');
  JsonCollection get directPayments => _root.collection('DirectPayments');
  JsonCollection get accounts => _root.collection('Accounts');

  /// The devices [userId] is signed in on.
  JsonCollection devices(String userId) {
    return accounts.doc(userId).collection('Devices');
  }

  JsonCollection pastGoals(String userId) {
    return profiles.doc(userId).collection('PastGoals');
  }

  /// Documents of [collection] with the given [ids], read 30 at a time,
  /// which is as many as one Firestore query takes.
  Future<List<QueryDocumentSnapshot<Json>>> getByIds(
    JsonCollection collection,
    Iterable<String> ids,
  ) async {
    final unique = ids.toSet().toList();
    final chunks = [
      for (var i = 0; i < unique.length; i += 30)
        unique.sublist(i, i + 30 > unique.length ? unique.length : i + 30),
    ];
    final snapshots = await Future.wait([
      for (final chunk in chunks)
        collection.where(FieldPath.documentId, whereIn: chunk).get(),
    ]);
    return [for (final snapshot in snapshots) ...snapshot.docs];
  }
}
