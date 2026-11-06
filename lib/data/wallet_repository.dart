import 'package:kahwa/core/money.dart';
import 'package:kahwa/data/db.dart';
import 'package:kahwa/models/money_requests.dart';
import 'package:kahwa/models/wallet.dart';

/// Balances, top ups, withdrawals and the details withdrawals are paid to.
class WalletRepository {
  WalletRepository(this._db);

  final Db _db;

  Future<Wallet> fetch(String userId) async {
    final doc = await _db.wallets.doc(userId).get();
    return Wallet.fromMap(doc.data() ?? const {});
  }

  Future<TopUpDestination> topUpDestination() async {
    final doc = await _db.config.doc('top_up').get();
    return TopUpDestination.fromMap(doc.data() ?? const {});
  }

  Future<TopUpRequest?> lastTopUp(String userId) async {
    final data = (await _db.topUpRequests.doc(userId).get()).data();
    return data == null ? null : TopUpRequest.fromMap(data);
  }

  /// Asks an admin to add [amount] sent from [senderPhone]. Replaces the
  /// previous request, which must have been answered.
  Future<void> requestTopUp({
    required String userId,
    required int amount,
    required Currency currency,
    required String senderPhone,
  }) {
    return _db.topUpRequests
        .doc(userId)
        .set(
          TopUpRequest(
            userId: userId,
            amount: amount,
            currency: currency,
            reference: TopUpRequest.newReference(),
            senderPhone: senderPhone.trim(),
          ).toNewMap(),
        );
  }

  Future<void> cancelTopUp(String userId) {
    return _db.topUpRequests.doc(userId).delete();
  }

  Future<List<TopUpRecord>> topUpHistory(String userId) async {
    final snapshot = await _db.topUpHistory
        .where('user_id', isEqualTo: userId)
        .get();
    return [for (final doc in snapshot.docs) TopUpRecord.fromMap(doc.data())];
  }

  Future<List<WithdrawRequest>> withdrawals(String userId) async {
    final snapshot = await _db.withdrawRequests
        .where('user_id', isEqualTo: userId)
        .get();
    final far = DateTime(9999);
    return [
      for (final doc in snapshot.docs)
        WithdrawRequest.fromMap(doc.data(), id: doc.id),
    ]..sort((a, b) => (b.timestamp ?? far).compareTo(a.timestamp ?? far));
  }

  /// Corrections admins made to [userId]'s balance.
  Future<List<Adjustment>> adjustments(String userId) async {
    final snapshot = await _db.adjustments
        .where('user_id', isEqualTo: userId)
        .get();
    return [
      for (final doc in snapshot.docs)
        Adjustment.fromMap(doc.data(), id: doc.id),
    ];
  }

  Future<void> requestWithdraw(String userId, Amounts amounts) {
    return _db.withdrawRequests.add(WithdrawRequest.newMap(userId, amounts));
  }

  Future<void> cancelWithdraw(WithdrawRequest request) {
    return _db.withdrawRequests.doc(request.id).delete();
  }

  Future<BillingDetails> billing(String userId) async {
    final data = (await _db.billing.doc(userId).get()).data();
    return data == null ? const BillingDetails() : BillingDetails.fromMap(data);
  }

  Future<void> saveBilling(String userId, BillingDetails details) {
    return _db.billing.doc(userId).set(details.toMap());
  }
}
