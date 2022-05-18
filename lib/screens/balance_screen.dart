import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kahwa/models/balance.dart';
import 'package:kahwa/utils/sizes.dart';
import 'package:kahwa/widgets/balance_card.dart';

class BalanceScreen extends StatelessWidget {
  const BalanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection("kahwa")
            .doc("AppCollections")
            .collection("Balances")
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
            Balance balance =
                Balance.fromMap(snapshot.data!.data() as Map<String, dynamic>);

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Balance".toUpperCase(),
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  verticalSpace(height: 40),
                  BalanceCard(
                    title: "Current Balance",
                    lbp: balance.current_lbp!,
                    usd: balance.current_usd!,
                  ),
                  verticalSpace(),
                  BalanceCard(
                    title: "Spent",
                    lbp: balance.spent_lbp!,
                    usd: balance.spent_usd!,
                  ),
                  verticalSpace(),
                  BalanceCard(
                    title: "Received",
                    lbp: balance.received_lbp!,
                    usd: balance.received_usd!,
                  ),
                  verticalSpace(),
                  BalanceCard(
                    title: "Withdrawn",
                    lbp: balance.withdrawn_lbp!,
                    usd: balance.withdrawn_usd!,
                  ),
                  // TODO: add button to request a withdraw / payout
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
