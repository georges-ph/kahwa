import 'package:firebase_database/firebase_database.dart';
import 'package:kahwa/data/collections.dart';
import 'package:kahwa/models/balance.dart';
import 'package:kahwa/models/billing_details.dart';
import 'package:kahwa/models/withdraw.dart';

class BalanceRepository {
  BalanceRepository(this._database, this._collections);

  final FirebaseDatabase _database;
  final Collections _collections;

  Future<Balance> getBalance(String userId) async {
    final document = await _collections.balances.doc(userId).get();
    return Balance.fromMap(document.data() ?? {});
  }

  Future<BillingDetails> getBillingDetails(String userId) async {
    final document = await _collections.billingDetails.doc(userId).get();
    return BillingDetails.fromMap(document.data() ?? {});
  }

  Future<void> saveBillingDetails(String userId, BillingDetails details) {
    return _collections.billingDetails.doc(userId).set(details.toMap());
  }

  Future<void> requestWithdraw(Withdraw withdraw) {
    return _collections.withdrawRequests.add(withdraw.toMap());
  }

  /// Page where users top up their balance, configured in Realtime Database.
  Future<Uri?> getReloadBalanceUrl() async {
    final snapshot = await _database.ref('reload_balance_url').get();
    final value = snapshot.value;
    return value is String ? Uri.tryParse(value) : null;
  }
}
