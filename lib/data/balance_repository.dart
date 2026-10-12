import 'package:kahwa/core/refresh.dart';
import 'package:kahwa/data/collections.dart';
import 'package:kahwa/models/balance.dart';
import 'package:kahwa/models/billing_details.dart';
import 'package:kahwa/models/top_up_destination.dart';
import 'package:kahwa/models/top_up_request.dart';
import 'package:kahwa/models/withdraw.dart';

class BalanceRepository {
  BalanceRepository(this._collections);

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

  /// Where users send money to when topping up, set by an admin in the
  /// `Config/top_up` document.
  Future<TopUpDestination> getTopUpDestination() async {
    final document = await _collections.config.doc('top_up').get();
    return TopUpDestination.fromMap(document.data() ?? {});
  }

  /// The top up request of [userId], if they have one.
  Future<TopUpRequest?> getTopUpRequest(String userId) async {
    final document = await _collections.topUpRequests.doc(userId).get();
    final data = document.data();
    return data == null ? null : TopUpRequest.fromMap(data);
  }

  /// Saves [request] for an admin to check. Replaces an earlier request that
  /// was approved or rejected.
  Future<void> requestTopUp(TopUpRequest request) async {
    await _collections.topUpRequests.doc(request.userId).set(request.toMap());
    notifyDataChanged();
  }

  Future<void> cancelTopUp(String userId) async {
    await _collections.topUpRequests.doc(userId).delete();
    notifyDataChanged();
  }
}
