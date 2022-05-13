import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kahwa/models/user.dart' as user_model;
import 'package:kahwa/utils/sizes.dart';
import 'package:kahwa/widgets/balance_card.dart';

class BalanceScreen extends StatelessWidget {
  const BalanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Balance"),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection("kahwa")
            .doc("AppCollections")
            .collection("Users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error getting data",
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
            );
          }

          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            user_model.User creator = user_model.User.fromMap(
                snapshot.data!.data() as Map<String, dynamic>);
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  BalanceCard(
                    title: "Current Balance",
                    lbp: creator.balance!.current_lbp!,
                    usd: creator.balance!.current_usd!,
                  ),
                  verticalSpace(),
                  BalanceCard(
                    title: "Spent",
                    lbp: creator.balance!.spent_lbp!,
                    usd: creator.balance!.spent_usd!,
                  ),
                  verticalSpace(),
                  BalanceCard(
                    title: "Received",
                    lbp: creator.balance!.received_lbp!,
                    usd: creator.balance!.received_usd!,
                  ),
                  verticalSpace(),
                  BalanceCard(
                    title: "Available to Withdraw",
                    lbp: creator.balance!.available_withdraw_usd!,
                    usd: creator.balance!.available_withdraw_usd!,
                  ),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
