import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kahwa/enums/currency.dart';
import 'package:kahwa/models/donation.dart';
import 'package:kahwa/models/fan_supporter.dart';
import 'package:kahwa/models/user.dart';
import 'package:kahwa/utils/colors.dart';
import 'package:kahwa/utils/sizes.dart';
import 'package:kahwa/utils/typography.dart';
import 'package:kahwa/widgets/input_text.dart';
import 'package:kahwa/widgets/kahwa_counter.dart';
import 'package:kahwa/widgets/price_input_text.dart';

class DonateScreen extends StatefulWidget {
  const DonateScreen({
    Key? key,
    this.creatorId,
  }) : super(key: key);

  final String? creatorId;

  @override
  State<DonateScreen> createState() => _DonateScreenState();
}

class _DonateScreenState extends State<DonateScreen> {
  late Size _screenSize;

  final fire_auth.FirebaseAuth _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  late fire_auth.User _user;
  late DocumentReference _appDocument;
  late Future<DocumentSnapshot> _getUserDoc;

  final TextEditingController _kahwasController =
      TextEditingController(text: 1.toString());
  final TextEditingController _messageController = TextEditingController();

  Currency _selectedCurrency = Currency.lbp;
  bool _payFee = false;
  bool _keepPrivate = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _user = _firebaseAuth.currentUser!;
    _appDocument = _firebaseFirestore.collection("kahwa").doc("AppCollections");
    _getUserDoc = _appDocument.collection("Users").doc(widget.creatorId).get();
  }

  @override
  void dispose() {
    _kahwasController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(),
        body: FutureBuilder<DocumentSnapshot>(
          future: _getUserDoc,
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
              User creator =
                  User.fromMap(snapshot.data!.data() as Map<String, dynamic>);
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Buy ${creator.name!.split(" ")[0]} a kahwa",
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .copyWith(
                                  fontWeight: kExtraBoldFontWeight,
                                  color: kBlackColor,
                                ),
                          ),
                        ),
                        horizontalSpace(width: 40),
                        CircleAvatar(
                          radius: _screenSize.width / 7,
                          backgroundImage: creator.image != null
                              ? NetworkImage(creator.image!)
                              : null,
                          backgroundColor: kBrownColor,
                          child: creator.image == null
                              ? Text(
                                  getInitials(creator.name!),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium!
                                      .copyWith(
                                        color: kWhiteColor,
                                      ),
                                )
                              : null,
                        ),
                      ],
                    ),
                    verticalSpace(),
                    Row(
                      children: [
                        const Image(
                          image: AssetImage("assets/fenjen.png"),
                          width: 32,
                        ),
                        horizontalSpace(),
                        const Text("×"),
                        horizontalSpace(),
                        PriceInputText(
                          controller: _kahwasController,
                        ),
                        const Spacer(flex: 3),
                        KahwaCounter(
                          onTap: (kahwas) {
                            setState(() {
                              _kahwasController.text = kahwas.toString();
                            });
                          },
                          text: 1,
                          kahwas: _kahwasController.text,
                        ),
                        horizontalSpace(),
                        KahwaCounter(
                          onTap: (kahwas) {
                            setState(() {
                              _kahwasController.text = kahwas.toString();
                            });
                          },
                          text: 3,
                          kahwas: _kahwasController.text,
                        ),
                        horizontalSpace(),
                        KahwaCounter(
                          onTap: (kahwas) {
                            setState(() {
                              _kahwasController.text = kahwas.toString();
                            });
                          },
                          text: 5,
                          kahwas: _kahwasController.text,
                        ),
                      ],
                    ),
                    verticalSpace(height: 16),
                    Row(
                      children: [
                        ChoiceChip(
                          label: Text(Currency.lbp.name.toUpperCase()),
                          selected: _selectedCurrency == Currency.lbp,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCurrency = Currency.lbp;
                            });
                          },
                        ),
                        horizontalSpace(),
                        ChoiceChip(
                          label: Text(Currency.usd.name.toUpperCase()),
                          selected: _selectedCurrency == Currency.usd,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCurrency = Currency.usd;
                            });
                          },
                        ),
                        horizontalSpace(width: 40),
                        Visibility(
                          visible: _selectedCurrency == Currency.usd,
                          child: Expanded(
                            child: Tooltip(
                              message:
                                  "If you are going to pay via a credit/debit card",
                              child: CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  "Pay the processing fee",
                                  textAlign: TextAlign.end,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                value: _payFee,
                                onChanged: (checked) {
                                  setState(() {
                                    _payFee = checked!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    verticalSpace(),
                    InputText(
                      controller: _messageController,
                      hint: "Add a nice message",
                      maxLines: 5,
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Keep this support private"),
                      value: _keepPrivate,
                      onChanged: (value) {
                        setState(() {
                          _keepPrivate = value!;
                        });
                      },
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                setState(() {
                                  _isLoading = true;
                                });

                                // TODO: use the balance to donate, not like im doing it

                                Donation donation = Donation(
                                  creator_id: widget.creatorId,
                                  currency: _selectedCurrency,
                                  kahwa_price: _selectedCurrency == Currency.lbp
                                      ? creator.kahwa_prices!.lbp
                                      : creator.kahwa_prices!.usd,
                                  kahwas: int.parse(_kahwasController.text),
                                  keep_private: _keepPrivate,
                                  message: _messageController.text,
                                  pay_fee: _payFee,
                                  total: _calculate(creator),
                                  timestamp: Timestamp.now(),
                                  supporter: FanSupporter(
                                    id: _user.uid,
                                    name: _user.displayName,
                                    image: _user.photoURL,
                                  ),
                                );

                                await _appDocument
                                    .collection("Donations")
                                    .add(donation.toMap());

                                SnackBar snackBar = SnackBar(
                                  content: Text(
                                      "You will be contacted soon to buy ${creator.name} some kahwas"),
                                );

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
                            : Text(_getText(creator)),
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

  num _calculate(User creator) {
    if (_selectedCurrency == Currency.lbp) {
      return creator.kahwa_prices!.lbp! *
          int.parse(_kahwasController.text).toDouble();
    } else {
      double price = creator.kahwa_prices!.usd! *
          int.parse(_kahwasController.text).toDouble();
      if (_payFee) {
        price = price / (1 - 0.06);
        return double.parse(price.toStringAsFixed(2));
      }
      return price.toInt();
    }
  }

  String _unit() {
    if (_selectedCurrency == Currency.lbp) {
      return "L.L.";
    } else {
      return "\$";
    }
  }

  String _getText(User creator) {
    var formatter = NumberFormat();
    String text = "";
    if (_selectedCurrency == Currency.lbp) {
      text = "${formatter.format(_calculate(creator))} ${_unit()}";
    } else {
      text = "${_unit()}${_calculate(creator)}";
    }
    return "Support $text";
  }
}
