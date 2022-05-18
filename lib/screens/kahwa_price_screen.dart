import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kahwa/enums/currency.dart';
import 'package:kahwa/models/kahwa_prices.dart';
import 'package:kahwa/utils/colors.dart';
import 'package:kahwa/utils/sizes.dart';
import 'package:kahwa/widgets/input_text.dart';

class KahwaPriceScreen extends StatefulWidget {
  const KahwaPriceScreen({Key? key}) : super(key: key);

  @override
  State<KahwaPriceScreen> createState() => _KahwaPriceScreenState();
}

class _KahwaPriceScreenState extends State<KahwaPriceScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  late User _user;
  late DocumentReference _appDocument;
  late DocumentReference<Map<String, dynamic>> _kahwPricesDocument;

  late Future<void> _runFuture;

  final TextEditingController _lbpController = TextEditingController();
  final TextEditingController _usdController = TextEditingController();
  final TextEditingController _thankYouController = TextEditingController();

  late KahwaPrices _kahwaPrices;

  String _lbpError = "";
  String _usdError = "";
  String _thankYouError = "";
  bool _isLbpErrorVisible = false;
  bool _isUsdErrorVisible = false;
  bool _isThankYouErrorVisible = false;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _user = _firebaseAuth.currentUser!;
    _appDocument = _firebaseFirestore.collection("kahwa").doc("AppCollections");
    _kahwPricesDocument = _appDocument.collection("kahwaPrices").doc(_user.uid);
    _runFuture = _getUserData();
  }

  @override
  void dispose() {
    _lbpController.dispose();
    _usdController.dispose();
    _thankYouController.dispose();
    super.dispose();
  }

  Future<void> _getUserData() async {
    DocumentSnapshot<Map<String, dynamic>> document =
        await _kahwPricesDocument.get();

    _kahwaPrices = KahwaPrices.fromMap(document.data() as Map<String, dynamic>);

    _lbpController.text = _kahwaPrices.lbp.toString();
    _usdController.text = _kahwaPrices.usd.toString();
    _thankYouController.text = _kahwaPrices.thanks_message ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(),
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
                      "kahwa Price".toUpperCase(),
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    verticalSpace(height: 40),
                    InputText(
                      controller: _lbpController,
                      title: "Price per kahwa",
                      hint: 1000.toString(),
                      prefixText: Currency.lbp.name.toUpperCase(),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                    ),
                    Visibility(
                      visible: _isLbpErrorVisible,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                        child: Text(
                          _lbpError,
                          style:
                              Theme.of(context).textTheme.labelMedium!.copyWith(
                                    color: kBrownColor,
                                  ),
                        ),
                      ),
                    ),
                    verticalSpace(height: 16),
                    InputText(
                      controller: _usdController,
                      hint: 1.toString(),
                      prefixText: Currency.usd.name.toUpperCase(),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                    ),
                    Visibility(
                      visible: _isUsdErrorVisible,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                        child: Text(
                          _usdError,
                          style:
                              Theme.of(context).textTheme.labelMedium!.copyWith(
                                    color: kBrownColor,
                                  ),
                        ),
                      ),
                    ),
                    verticalSpace(),
                    InputText(
                      controller: _thankYouController,
                      title: "Thank you message",
                      subtitle: "A message to be shown when someone donates.",
                      hint: "Thank you for the support! 🎉",
                      maxLines: 5,
                      textInputAction: TextInputAction.done,
                    ),
                    Visibility(
                      visible: _isThankYouErrorVisible,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                        child: Text(
                          _thankYouError,
                          style:
                              Theme.of(context).textTheme.labelMedium!.copyWith(
                                    color: kBrownColor,
                                  ),
                        ),
                      ),
                    ),
                    verticalSpace(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                setState(() {
                                  _lbpError = "";
                                  _usdError = "";
                                  _thankYouError = "";
                                  _isLbpErrorVisible = false;
                                  _isUsdErrorVisible = false;
                                  _isThankYouErrorVisible = false;
                                });

                                if (_lbpController.text.isEmpty ||
                                    _usdController.text.isEmpty ||
                                    _thankYouController.text.isEmpty) {
                                  if (_lbpController.text.isEmpty) {
                                    setState(() {
                                      _lbpError = "Price cannot be empty";
                                      _isLbpErrorVisible = true;
                                    });
                                  }

                                  if (_usdController.text.isEmpty) {
                                    setState(() {
                                      _usdError = "Price cannot be empty";
                                      _isUsdErrorVisible = true;
                                    });
                                  }

                                  if (_thankYouController.text.isEmpty) {
                                    setState(() {
                                      _thankYouError =
                                          "Message cannot be empty";
                                      _isThankYouErrorVisible = true;
                                    });
                                  }
                                  return;
                                }

                                setState(() {
                                  _isLoading = true;
                                });

                                // _userModel.kahwa_prices!.lbp =
                                //     int.parse(_lbpController.text);
                                // _userModel.kahwa_prices!.usd =
                                //     int.parse(_usdController.text);
                                // _userModel.kahwa_prices!.thanks_message =
                                //     _thankYouController.text;

                                await _kahwPricesDocument
                                    .update(_kahwaPrices.toMap());

                                SnackBar snackBar = const SnackBar(
                                    content: Text("Updated successfully"));

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);

                                setState(() {
                                  _isLoading = false;
                                });

                                // User user = User(
                                //   kahwa_prices: KahwaPrices(
                                //     lbp: 1000,
                                //     thanks_message: "dfg",
                                //     usd: 5,
                                //   ),
                                // );

                                // await FirebaseFirestore.instance
                                //     .collection("col")
                                //     .doc("h")
                                //     .withConverter(
                                //       fromFirestore: User.fromFirestore,
                                //       toFirestore: (User user, options) =>
                                //           user.toFirestore(),
                                //     )
                                //     .set(user);
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
