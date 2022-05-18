import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kahwa/models/billing_details.dart';
import 'package:kahwa/utils/sizes.dart';
import 'package:kahwa/widgets/input_text.dart';

class BillingDetailsScreen extends StatefulWidget {
  const BillingDetailsScreen({Key? key}) : super(key: key);

  @override
  State<BillingDetailsScreen> createState() => _BillingDetailsScreenState();
}

class _BillingDetailsScreenState extends State<BillingDetailsScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  late User _user;
  late DocumentReference _appDocument;
  late DocumentReference<Map<String, dynamic>> _billingDetailsDocument;

  late Future<void> _runFuture;

  final TextEditingController _whishPhoneController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  late BillingDetails _billingDetails;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _user = _firebaseAuth.currentUser!;
    _appDocument = _firebaseFirestore.collection("kahwa").doc("AppCollections");
    _billingDetailsDocument =
        _appDocument.collection("BillingDetails").doc(_user.uid);
    _runFuture = _getUserData();
  }

  @override
  void dispose() {
    _whishPhoneController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _getUserData() async {
    DocumentSnapshot<Map<String, dynamic>> document =
        await _billingDetailsDocument.get();

    if (!document.exists) {
      _billingDetails = BillingDetails();
      return;
    }
    _billingDetails = BillingDetails.fromMap(document.data()!);

    _whishPhoneController.text = _billingDetails.whish_phone!;
    _firstNameController.text = _billingDetails.first_name!;
    _lastNameController.text = _billingDetails.last_name!;
    _phoneController.text = _billingDetails.phone!;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          
        ),
        body: FutureBuilder(
          future: _runFuture,
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

            if (snapshot.connectionState == ConnectionState.done) {
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(24),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Billing Details".toUpperCase(),
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    verticalSpace(height: 40),
                    const Text("Payments are made through WHISH MONEY."),
                    verticalSpace(),
                    InputText(
                      controller: _whishPhoneController,
                      title: "Phone Number",
                      hint: "70 123 456",
                      icon: Icons.phone_rounded,
                      subtitle:
                          "Enter a phone number used with the WHISH app if available.",
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                    ),
                    verticalSpace(),
                    InputText(
                      controller: _firstNameController,
                      title: "Billing Information",
                      subtitle:
                          "If you don't have the WHISH app, you can enter the information below and collect the money at any WHISH agent.",
                      hint: "First Name",
                      icon: Icons.person_rounded,
                      textInputAction: TextInputAction.next,
                    ),
                    verticalSpace(height: 16),
                    InputText(
                      controller: _lastNameController,
                      icon: Icons.person_rounded,
                      hint: "Last Name",
                    ),
                    verticalSpace(height: 16),
                    InputText(
                      controller: _phoneController,
                      icon: Icons.phone_rounded,
                      hint: "Phone number",
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                    ),
                    verticalSpace(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                if (_whishPhoneController.text.isEmpty &&
                                    _firstNameController.text.isEmpty &&
                                    _lastNameController.text.isEmpty &&
                                    _phoneController.text.isEmpty) {
                                  return;
                                }

                                setState(() {
                                  _isLoading = true;
                                });

                                _billingDetails.whish_phone =
                                    _whishPhoneController.text;
                                _billingDetails.first_name =
                                    _firstNameController.text;
                                _billingDetails.last_name =
                                    _lastNameController.text;
                                _billingDetails.phone = _phoneController.text;

                                await _billingDetailsDocument.set(
                                    _billingDetails.toMap(),
                                    SetOptions(merge: true));

                                SnackBar snackBar = const SnackBar(
                                    content: Text("Updated successfully"));

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);

                                setState(() {
                                  _isLoading = false;
                                });
                              },
                        child: _isLoading
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                ),
                              )
                            : const Text("Save"),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
