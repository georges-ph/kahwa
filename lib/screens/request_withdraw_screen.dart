import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kahwa/enums/currency.dart';
import 'package:kahwa/models/balance.dart';
import 'package:kahwa/models/withdraw.dart';
import 'package:kahwa/utils/sizes.dart';
import 'package:kahwa/widgets/balance_card.dart';
import 'package:kahwa/widgets/input_text.dart';

class RequestWithdrawScreen extends StatefulWidget {
  const RequestWithdrawScreen({
    Key? key,
    required this.balance,
  }) : super(key: key);

  final Balance balance;

  @override
  State<RequestWithdrawScreen> createState() => _RequestWithdrawScreenState();
}

class _RequestWithdrawScreenState extends State<RequestWithdrawScreen> {
  final TextEditingController _lbpController =
      TextEditingController(text: 0.toString());
  final TextEditingController _usdController =
      TextEditingController(text: 0.toString());

  bool _isLoading = false;

  @override
  void dispose() {
    _lbpController.dispose();
    _usdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Request Withdraw".toUpperCase(),
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            verticalSpace(height: 40),
            const Text(
                "Make sure you have setup your billing details. Otherwise, no withdraws will be made."),
            verticalSpace(),
            BalanceCard(
              title: "Current Balance",
              lbp: widget.balance.current_lbp!,
              usd: widget.balance.current_usd!,
            ),
            verticalSpace(height: 24),
            InputText(
              controller: _lbpController,
              title: "Withdraw amount",
              hint: widget.balance.current_lbp!.toString(),
              prefixText: Currency.lbp.name.toUpperCase(),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
            ),
            verticalSpace(height: 16),
            InputText(
              controller: _usdController,
              hint: widget.balance.current_usd!.toString(),
              prefixText: Currency.usd.name.toUpperCase(),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
            ),
            verticalSpace(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _requestWithdraw,
                child: _isLoading
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                        ),
                      )
                    : const Text("Request"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _requestWithdraw() async {
    if (_lbpController.text.isEmpty) {
      _lbpController.text = "0";
    }

    if (_usdController.text.isEmpty) {
      _usdController.text = "0";
    }

    int lbp = int.parse(_lbpController.text);
    int usd = int.parse(_usdController.text);

    if (widget.balance.current_lbp == 0 && widget.balance.current_usd == 0) {
      return;
    }

    if (lbp == 0 && usd == 0) {
      return;
    }

    if (lbp > widget.balance.current_lbp! ||
        usd > widget.balance.current_usd!) {
      SnackBar snackBar = const SnackBar(
          content: Text("You cannot withdraw more than your current balance"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Withdraw withdraw = Withdraw(
      lbp: lbp,
      usd: usd,
      user_id: FirebaseAuth.instance.currentUser!.uid,
    );

    await FirebaseFirestore.instance
        .collection("kahwa")
        .doc("AppCollections")
        .collection("WithdrawRequests")
        .add(withdraw.toMap());

    SnackBar snackBar = const SnackBar(content: Text("Request sent"));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    setState(() {
      _isLoading = false;
    });
  }
}
