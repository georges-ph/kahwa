// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kahwa/enums/currency.dart';
import 'package:kahwa/models/user.dart' as user_model;
import 'package:kahwa/utils/colors.dart';
import 'package:kahwa/utils/sizes.dart';
import 'package:kahwa/utils/typography.dart';

class BalanceScreen extends StatelessWidget {
  const BalanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Balance"),
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
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.all(24),
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

class BalanceCard extends StatelessWidget {
  const BalanceCard({
    Key? key,
    required this.title,
    required this.lbp,
    required this.usd,
  }) : super(key: key);

  final String title;
  final int lbp;
  final int usd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: kGreyColor.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: kSemiBoldFontWeight,
                ),
          ),
          verticalSpace(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Currency.lbp.name.toUpperCase(),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                lbp.toString(),
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: kGreyColor,
                    ),
              ),
            ],
          ),
          verticalSpace(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Currency.usd.name.toUpperCase(),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                usd.toString(),
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: kGreyColor,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
