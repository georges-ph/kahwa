import 'package:cloud_firestore/cloud_firestore.dart';

typedef JsonCollection = CollectionReference<Map<String, dynamic>>;

/// Firestore collections of the app, all nested under `kahwa/AppCollections`.
class Collections {
  Collections(this.firestore);

  final FirebaseFirestore firestore;

  DocumentReference<Map<String, dynamic>> get _app =>
      firestore.collection('kahwa').doc('AppCollections');

  JsonCollection get users => _app.collection('Users');
  JsonCollection get kahwaPrices => _app.collection('kahwaPrices');
  JsonCollection get balances => _app.collection('Balances');
  JsonCollection get goals => _app.collection('Goals');
  JsonCollection get donations => _app.collection('Donations');
  JsonCollection get billingDetails => _app.collection('BillingDetails');
  JsonCollection get withdrawRequests => _app.collection('WithdrawRequests');
  JsonCollection get topUpRequests => _app.collection('TopUpRequests');
  JsonCollection get admins => _app.collection('Admins');
  JsonCollection get config => _app.collection('Config');

  JsonCollection archivedGoals(String userId) =>
      users.doc(userId).collection('ArchivedGoals');
}
