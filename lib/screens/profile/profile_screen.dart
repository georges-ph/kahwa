// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kahwa/models/user.dart' as user_model;
import 'package:kahwa/screens/profile/strings.dart';
import 'package:kahwa/screens/profile/widgets/price_input_text.dart';
import 'package:kahwa/utils/colors.dart';
import 'package:kahwa/utils/routes.dart';
import 'package:kahwa/utils/sizes.dart';
import 'package:kahwa/utils/typography.dart';
import 'package:kahwa/widgets/input_text.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  late User _user;
  late DocumentReference _appDocument;

  late Future<DocumentSnapshot> _getUserDoc;

  late Size _screenSize;

  String _kahwa_lbp = "";
  String _kahwa_usd = "";
  String _phone = "";

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _user = _firebaseAuth.currentUser!;
    _appDocument = _firebaseFirestore.collection("kahwa").doc("AppCollections");
    _getUserDoc = _appDocument.collection("Users").doc(_user.uid).get();
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
              user_model.User userModel =user_model. User.fromMap(
                  snapshot.data!.data() as Map<String, dynamic>);
              _kahwa_lbp = userModel.kahwa_lbp.toString();
              _kahwa_usd = userModel.kahwa_usd.toString();
              return SingleChildScrollView(
                padding: EdgeInsets.all(24),
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: _screenSize.width / 5,
                      backgroundImage: _user.photoURL != null
                          ? NetworkImage(_user.photoURL!)
                          : null,
                      backgroundColor: kRedColor,
                      child: _user.photoURL == null
                          ? Text(
                              getInitials(_user.displayName!),
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall!
                                  .copyWith(
                                    color: kWhiteColor,
                                  ),
                            )
                          : null,
                    ),
                    verticalSpace(),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(
                        context,
                        routeDonate,
                        arguments: _user.uid,
                      ),
                      child: Text(
                        _user.displayName!,
                        style:
                            Theme.of(context).textTheme.headlineSmall!.copyWith(
                                  fontWeight: kBoldFontWeight,
                                  color: kBlackColor,
                                ),
                      ),
                    ),
                    verticalSpace(height: 32),
                    InputText(
                      icon: Icons.link_rounded,
                      text: "kahwa.web.app/${_user.uid}",
                      readOnly: true,
                      suffixIcon: Icons.content_copy_rounded,
                      suffixOnTap: () async {
                        await Clipboard.setData(
                          ClipboardData(
                            text: "kahwa.web.app/${_user.uid}",
                          ),
                        );
                        SnackBar snackBar =
                            SnackBar(content: Text("Copied to clipboard"));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      },
                    ),
                    verticalSpace(),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "kahwa Price",
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  fontSize: 18,
                                  fontWeight: kBoldFontWeight,
                                ),
                      ),
                    ),
                    verticalSpace(height: 16),
                    Row(
                      children: [
                        Image(
                          image: AssetImage("assets/fenjen.png"),
                          width: 32,
                        ),
                        horizontalSpace(),
                        Text("×"),
                        horizontalSpace(),
                        Text("1"),
                        horizontalSpace(width: 16),
                        Text("LBP"),
                        horizontalSpace(),
                        PriceInputText(
                          price: userModel.kahwa_lbp!,
                          formatLbp: true,
                          onChanged: (value) => _kahwa_lbp = value,
                        ),
                        horizontalSpace(width: 16),
                        Text("USD"),
                        horizontalSpace(),
                        PriceInputText(
                          price: userModel.kahwa_usd!,
                          onChanged: (value) => _kahwa_usd = value,
                        ),
                      ],
                    ),
                    verticalSpace(),
                    InputText(
                      icon: Icons.phone_rounded,
                      hint: "WHISH Phone Number",
                      text: userModel.phone != "0" ? userModel.phone : _phone,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      onChanged: (value) => _phone = value,
                    ),
                    verticalSpace(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:_isLoading
                                ? null
                                :  () async {
                          if (_kahwa_lbp.isEmpty ||
                              _kahwa_usd.isEmpty ||
                              _phone.isEmpty) {
                            SnackBar snackBar = SnackBar(
                                content: Text("Fields cannot be empty"));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);

                            return;
                          }

                          setState(() {
                            _isLoading = true;
                          });

                         user_model. User userModel = user_model. User(
                            kahwa_lbp: int.parse(_kahwa_lbp),
                            kahwa_usd: int.parse(_kahwa_usd),
                            phone: _phone,
                          );

                          await _appDocument
                              .collection("Users")
                              .doc(_user.uid)
                              .update(userModel.toMap());

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
                            : Text("Save"),
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

  
}
