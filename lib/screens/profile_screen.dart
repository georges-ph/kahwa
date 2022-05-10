// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kahwa/enums/colors.dart' as colors_enum;
import 'package:kahwa/models/user.dart' as user_model;
import 'package:kahwa/utils/colors.dart';
import 'package:kahwa/utils/sizes.dart';
import 'package:kahwa/utils/typography.dart';
import 'package:kahwa/widgets/input_text.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Size _screenSize;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  late User _user;
  late DocumentReference _appDocument;

  late Future<void> _runFuture;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _aboutMeController = TextEditingController();
  TextEditingController _websiteController = TextEditingController();
  // final TextEditingController _linkController = TextEditingController();
  final TextEditingController _kahwaLbpController = TextEditingController();
  final TextEditingController _kahwaUsdController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  late user_model.User _userModel;

  bool _isLoading = false;

  colors_enum.Colors _checkedColor = colors_enum.Colors.red;

  @override
  void initState() {
    super.initState();
    _user = _firebaseAuth.currentUser!;
    _appDocument = _firebaseFirestore.collection("kahwa").doc("AppCollections");
    _runFuture = _getUserData();
    _nameController.text = _user.displayName!;
  }

  Future<void> _getUserData() async {
    DocumentSnapshot<Map<String, dynamic>> userDocument =
        await _appDocument.collection("Users").doc(_user.uid).get();
    _userModel =
        user_model.User.fromMap(userDocument.data() as Map<String, dynamic>);

    // _linkController.text = "kahwa.page.link/${_userModel.link_id}";
    _kahwaLbpController.text = _userModel.kahwa_lbp.toString();
    _kahwaUsdController.text = _userModel.kahwa_usd.toString();
    _phoneController.text = _userModel.phone ?? "";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutMeController.dispose();
    _websiteController.dispose();
    // _linkController.dispose();
    _kahwaLbpController.dispose();
    _kahwaUsdController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
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
              padding: const EdgeInsets.all(24),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: _screenSize.width / 5,
                        backgroundImage: _user.photoURL != null
                            ? NetworkImage(_user.photoURL!)
                            : null,
                        backgroundColor: _user.photoURL == null
                            ? kRedColor.withOpacity(0.6)
                            : null,
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
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: ElevatedButton(
                          onPressed: () {},
                          child: Icon(Icons.camera_alt_rounded),
                          style: TextButton.styleFrom(
                            shape: CircleBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  verticalSpace(height: 40),
                  InputText(
                    controller: _nameController,
                    title: "Name",
                    hint: "John Doe",
                    icon: Icons.person_rounded,
                  ),
                  verticalSpace(),
                  InputText(
                    controller: _aboutMeController,
                    title: "About Me",
                    hint:
                        "Hey 👋 I just created a page here. You can now buy me a kahwa!",
                    maxLines: 5,
                  ),
                  verticalSpace(),
                  InputText(
                    controller: _websiteController,
                    title: "Website",
                    icon: Icons.link_rounded,
                    hint: "example.com",
                  ),
                  verticalSpace(),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Change your page theme",
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: kSemiBoldFontWeight,
                          ),
                    ),
                  ),
                  verticalSpace(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CheckColorBox(
                        color: kRedColor,
                        checkedValue: _checkedColor == colors_enum.Colors.red,
                        checked: (checked) {
                          setState(() {
                            if (checked) {
                              _checkedColor = colors_enum.Colors.red;
                            }
                          });
                        },
                      ),
                      CheckColorBox(
                        color: kPinkColor,
                        checkedValue: _checkedColor == colors_enum.Colors.pink,
                        checked: (checked) {
                          setState(() {
                            if (checked) {
                              _checkedColor = colors_enum.Colors.pink;
                            }
                          });
                        },
                      ),
                      CheckColorBox(
                        color: kPurpleColor,
                        checkedValue:
                            _checkedColor == colors_enum.Colors.purple,
                        checked: (checked) {
                          setState(() {
                            if (checked) {
                              _checkedColor = colors_enum.Colors.purple;
                            }
                          });
                        },
                      ),
                      CheckColorBox(
                        color: kCyanColor,
                        checkedValue: _checkedColor == colors_enum.Colors.cyan,
                        checked: (checked) {
                          setState(() {
                            if (checked) {
                              _checkedColor = colors_enum.Colors.cyan;
                            }
                          });
                        },
                      ),
                      CheckColorBox(
                        color: kGreenColor,
                        checkedValue: _checkedColor == colors_enum.Colors.green,
                        checked: (checked) {
                          setState(() {
                            if (checked) {
                              _checkedColor = colors_enum.Colors.green;
                            }
                          });
                        },
                      ),
                      CheckColorBox(
                        color: kYellowColor,
                        checkedValue:
                            _checkedColor == colors_enum.Colors.yellow,
                        checked: (checked) {
                          setState(() {
                            if (checked) {
                              _checkedColor = colors_enum.Colors.yellow;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  // Input(
                  //   controller: _linkController,
                  //   icon: Icons.link_rounded,
                  //   readOnly: true,
                  //   suffixIcon: Icons.content_copy_rounded,
                  //   suffixOnTap: () async {
                  //     await Clipboard.setData(
                  //       ClipboardData(
                  //         text: "https://${_linkController.text}",
                  //       ),
                  //     );
                  //     SnackBar snackBar =
                  //         SnackBar(content: Text("Copied to clipboard"));
                  //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  //   },
                  // ),
                  // verticalSpace(),

                  verticalSpace(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              if (_kahwaLbpController.text.isEmpty ||
                                  _kahwaUsdController.text.isEmpty ||
                                  _phoneController.text.isEmpty) {
                                SnackBar snackBar = const SnackBar(
                                    content: Text("Fields cannot be empty"));
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);

                                return;
                              }

                              setState(() {
                                _isLoading = true;
                              });

                              _userModel.kahwa_lbp =
                                  int.parse(_kahwaLbpController.text);
                              _userModel.kahwa_usd =
                                  int.parse(_kahwaUsdController.text);
                              _userModel.phone = _phoneController.text;

                              await _appDocument
                                  .collection("Users")
                                  .doc(_user.uid)
                                  .update(_userModel.toMap());

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
    );
  }
}

class CheckColorBox extends StatelessWidget {
  const CheckColorBox({
    Key? key,
    required this.color,
    required this.checkedValue,
    required this.checked,
  }) : super(key: key);

  final Color color;
  final bool checkedValue;
  final Function(bool) checked;

  @override
  Widget build(BuildContext context) {
    bool _checked = checkedValue;
    return GestureDetector(
      onTap: () {
        _checked = !_checked;
        checked(_checked);
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: ShapeDecoration(
          shape: CircleBorder(),
          color: color,
        ),
        child: Icon(
          Icons.check_rounded,
          color: _checked ? kWhiteColor : kTransparentColor,
        ),
      ),
    );
  }
}
