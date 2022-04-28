
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kahwa/enums/currency.dart';
import 'package:kahwa/models/donation.dart';
import 'package:kahwa/models/user.dart';
import 'package:kahwa/screens/profile/strings.dart';
import 'package:kahwa/utils/colors.dart';
import 'package:kahwa/utils/sizes.dart';
import 'package:kahwa/utils/typography.dart';
import 'package:kahwa/widgets/input_text.dart';

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

  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  late DocumentReference _appDocument;
  late Future<DocumentSnapshot> _getUserDoc;

  TextEditingController controller = TextEditingController(text: 1.toString());

  Currency _currency = Currency.lbp;
  bool _payFee = false;
  String _message = "";
  bool _keepPrivate = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _appDocument = _firebaseFirestore.collection("kahwa").doc("AppCollections");
    _getUserDoc = _appDocument.collection("Users").doc(widget.creatorId).get();
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<DocumentSnapshot>(
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
              User creator = User.fromMap(
                  snapshot.data!.data() as Map<String, dynamic>);
              return SingleChildScrollView(
                padding: EdgeInsets.all(24),
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
                          radius: _screenSize.width / 6,
                          backgroundImage: creator.image != null
                              ? NetworkImage(creator.image!)
                              : null,
                          backgroundColor: kRedColor,
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
                        Image(
                          image: AssetImage("assets/fenjen.png"),
                          width: 32,
                        ),
                        horizontalSpace(),
                        Text("×"),
                        horizontalSpace(),
                        Expanded(
                          child: Container(
                            decoration: ShapeDecoration(
                              color: kGreyColor.withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: TextField(
                              controller: controller,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 1.toString(),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.all(4),
                              ),
                            ),
                          ),
                        ),
                        Spacer(flex: 4),
                        KahwaCounter(
                          onTap: (kahwas) {
                            setState(() {
                              controller.text = kahwas.toString();
                            });
                          },
                          text: 1,
                          kahwas: controller.text,
                        ),
                        horizontalSpace(),
                        KahwaCounter(
                          onTap: (kahwas) {
                            setState(() {
                              controller.text = kahwas.toString();
                            });
                          },
                          text: 3,
                          kahwas: controller.text,
                        ),
                        horizontalSpace(),
                        KahwaCounter(
                          onTap: (kahwas) {
                            setState(() {
                              controller.text = kahwas.toString();
                            });
                          },
                          text: 5,
                          kahwas: controller.text,
                        ),
                      ],
                    ),
                    verticalSpace(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<Currency>(
                            contentPadding: EdgeInsets.zero,
                            visualDensity: VisualDensity(
                              horizontal: VisualDensity.minimumDensity,
                              vertical: VisualDensity.minimumDensity,
                            ),
                            title: Text(Currency.lbp.name.toUpperCase()),
                            value: Currency.lbp,
                            groupValue: _currency,
                            onChanged: (value) {
                              setState(() {
                                _currency = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<Currency>(
                            contentPadding: EdgeInsets.zero,
                            visualDensity: VisualDensity(
                              horizontal: VisualDensity.minimumDensity,
                              vertical: VisualDensity.minimumDensity,
                            ),
                            title: Text(Currency.usd.name.toUpperCase()),
                            value: Currency.usd,
                            groupValue: _currency,
                            onChanged: (value) {
                              setState(() {
                                _currency = value!;
                              });
                            },
                          ),
                        ),
                        horizontalSpace(width: 40),
                        Expanded(
                          flex: 2,
                          child: CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            visualDensity: VisualDensity(
                              horizontal: VisualDensity.minimumDensity,
                              vertical: VisualDensity.minimumDensity,
                            ),
                            title: Text("Pay the processing fee"),
                            value: _payFee,
                            onChanged: (value) {
                              setState(() {
                                _payFee = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    verticalSpace(),
                    InputText(
                      hint: "Add a nice message",
                      text: _message,
                      onChanged: (value) {
                        setState(() {
                          _message = value;
                        });
                      },
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text("Keep this message private"),
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

                                Donation donationModel = Donation(
                                  currency: _currency,
                                  kahwa_price: _currency == Currency.lbp
                                      ? creator.kahwa_lbp
                                      : creator.kahwa_usd,
                                  kahwas: int.parse(controller.text),
                                  keep_private: _keepPrivate,
                                  message: _message,
                                  pay_fee: _payFee,
                                  total: _calculate(creator),
                                );

                                await _appDocument
                                    .collection("Donations")
                                    .add(donationModel.toMap());
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
                            ? SizedBox.square(
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

            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  int _calculate(User creator) {
    if (_currency == Currency.lbp) {
      return creator.kahwa_lbp! * int.parse(controller.text);
    } else {
      return creator.kahwa_usd! * int.parse(controller.text);
    }
  }

  String _unit() {
    if (_currency == Currency.lbp) {
      return "L.L.";
    } else {
      return "\$";
    }
  }

  String _getText(User creator) {
    var formatter = NumberFormat();
    String text = "";
    if (_currency == Currency.lbp) {
      text = "${formatter.format(_calculate(creator))} ${_unit()}";
    } else {
      text = "${_unit()}${_calculate(creator)}";
    }
    return "Support $text";
  }
}

class KahwaCounter extends StatelessWidget {
  const KahwaCounter({
    Key? key,
    required this.text,
    required this.kahwas,
    required this.onTap,
  }) : super(key: key);

  final int text;
  final String kahwas;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(text),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: kahwas == text.toString() ? kRedColor : kWhiteColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: kRedColor,
          ),
        ),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            text.toString(),
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: kahwas == text.toString() ? kWhiteColor : kRedColor,
                ),
          ),
        ),
      ),
    );
  }
}
