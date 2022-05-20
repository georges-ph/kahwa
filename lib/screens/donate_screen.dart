import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kahwa/enums/colors.dart' as colors_enum;
import 'package:kahwa/enums/currency.dart';
import 'package:kahwa/models/balance.dart';
import 'package:kahwa/models/donation.dart';
import 'package:kahwa/models/goal.dart';
import 'package:kahwa/models/kahwa_prices.dart';
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
  late DocumentReference _goalDocument;
  late DocumentReference _balanceDocument;
  late DocumentReference _creatorBalanceDocument;

  late Future<void> _runFuture;

  late User _creator;
  late KahwaPrices _kahwaPrices;
  late Color _creatorColor;

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
    _goalDocument = _appDocument.collection("Goals").doc(widget.creatorId);
    _balanceDocument = _appDocument.collection("Balances").doc(_user.uid);
    _creatorBalanceDocument =
        _appDocument.collection("Balances").doc(widget.creatorId);
    _runFuture = _getData();
  }

  @override
  void dispose() {
    _kahwasController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _getData() async {
    DocumentSnapshot userDoc =
        await _appDocument.collection("Users").doc(widget.creatorId).get();
    DocumentSnapshot pricesDoc = await _appDocument
        .collection("kahwaPrices")
        .doc(widget.creatorId)
        .get();

    _creator = User.fromMap(userDoc.data() as Map<String, dynamic>);
    _kahwaPrices =
        KahwaPrices.fromMap(pricesDoc.data() as Map<String, dynamic>);

    _creatorColor = colors_enum.getColor(_creator.color!);
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;

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
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                        primary: _creatorColor,
                      ),
                  checkboxTheme: Theme.of(context).checkboxTheme.copyWith(
                        fillColor: MaterialStateProperty.all(_creatorColor),
                      ),
                  chipTheme: Theme.of(context).chipTheme.copyWith(
                        selectedColor: _creatorColor.withOpacity(0.8),
                        backgroundColor: _creatorColor.withOpacity(0.2),
                      ),
                ),
                child: SingleChildScrollView(
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
                              "Buy ${_creator.name!.split(" ")[0]} a kahwa",
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                          ),
                          horizontalSpace(width: 40),
                          CircleAvatar(
                            radius: _screenSize.width / 7,
                            backgroundImage: _creator.image != null
                                ? NetworkImage(_creator.image!)
                                : null,
                            backgroundColor: _creatorColor,
                            child: _creator.image == null
                                ? Text(
                                    getInitials(_creator.name!),
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
                            image: AssetImage("assets/cup.png"),
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
                            // visible: _selectedCurrency == Currency.usd,
                            visible: false,
                            child: Expanded(
                              child: Tooltip(
                                message:
                                    "If you are going to pay via a credit/debit card",
                                child: CheckboxListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    "Pay the processing fee",
                                    textAlign: TextAlign.end,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
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
                          onPressed: _isLoading ? null : _donate,
                          child: _isLoading
                              ? const SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                  ),
                                )
                              : Text(_getText(_creator)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  _donate() async {
    setState(() {
      _isLoading = true;
    });

    Donation donation = Donation(
      creator_id: widget.creatorId,
      currency: _selectedCurrency,
      kahwa_price: _selectedCurrency == Currency.lbp
          ? _kahwaPrices.lbp
          : _kahwaPrices.usd,
      kahwas: int.parse(_kahwasController.text),
      keep_private: _keepPrivate,
      message: _messageController.text,
      pay_fee: _payFee,
      total: _calculate(_creator),
      supporter_id: _user.uid,
    );

    _firebaseFirestore.runTransaction((transaction) async {
      final goalDoc = await transaction.get(_goalDocument);
      final balanceDoc = await transaction.get(_balanceDocument);
      final creatorBalanceDoc = await transaction.get(_creatorBalanceDocument);

      Balance balance =
          Balance.fromMap(balanceDoc.data() as Map<String, dynamic>);
      Balance creatorBalance =
          Balance.fromMap(creatorBalanceDoc.data() as Map<String, dynamic>);

      if ((_selectedCurrency == Currency.lbp &&
              balance.current_lbp! < _calculate(_creator)) ||
          (_selectedCurrency == Currency.usd &&
              balance.current_usd! < _calculate(_creator))) {
        return false;
      }

      int total = _calculate(_creator);

      if (_selectedCurrency == Currency.lbp) {
        balance.current_lbp = balance.current_lbp! - total;
        balance.spent_lbp = balance.spent_lbp! + total;
        creatorBalance.current_lbp = creatorBalance.current_lbp! + total;
        creatorBalance.received_lbp = creatorBalance.received_lbp! + total;
      } else {
        balance.current_usd = balance.current_usd! - total;
        balance.spent_usd = balance.spent_usd! + total;
        creatorBalance.current_usd = creatorBalance.current_usd! + total;
        creatorBalance.received_usd = creatorBalance.received_usd! + total;
      }

      transaction.set(
          _appDocument.collection("Donations").doc(), donation.toMap());
      transaction.update(_balanceDocument, balance.toMap());
      transaction.update(_creatorBalanceDocument, creatorBalance.toMap());
      if (_selectedCurrency == Currency.lbp && goalDoc.exists) {
        Goal goal = Goal.fromMap(goalDoc.data() as Map<String, dynamic>);
        goal.current = goal.current! + total;
        transaction.update(_goalDocument, goal.toMap());
      }

      return true;
    }).then((success) {
      if (!success) {
        SnackBar snackBar =
            const SnackBar(content: Text("You do not have enough credit"));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        SnackBar snackBar = SnackBar(
          content: Text(
              "Congrats! You just bought ${_creator.name} ${int.parse(_kahwasController.text)} ${int.parse(_kahwasController.text) == 1 ? "kahwa" : "kahwas"}"),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }

      setState(() {
        _isLoading = false;
      });
    });
  }

  int _calculate(User creator) {
    if (_selectedCurrency == Currency.lbp) {
      return _kahwaPrices.lbp! * int.parse(_kahwasController.text);
    } else {
      // double price =
      return _kahwaPrices.usd! * int.parse(_kahwasController.text);
      // if (_payFee) {
      //   price = price / (1 - 0.06);
      //   return double.parse(price.toStringAsFixed(2));
      // }
      // return price.toInt();
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
