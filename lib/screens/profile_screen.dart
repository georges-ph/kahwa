import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kahwa/models/user.dart' as user_model;
import 'package:kahwa/utils/colors.dart';
import 'package:kahwa/utils/sizes.dart';
import 'package:kahwa/utils/typography.dart';
import 'package:kahwa/widgets/input_text.dart';
import 'package:kahwa/widgets/price_input_text.dart';

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

  // final TextEditingController _linkController = TextEditingController();
  final TextEditingController _kahwaLbpController = TextEditingController();
  final TextEditingController _kahwaUsdController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  late user_model.User _userModel;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _user = _firebaseAuth.currentUser!;
    _appDocument = _firebaseFirestore.collection("kahwa").doc("AppCollections");
    _runFuture = _getUserData();
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
      body: SafeArea(
        child: FutureBuilder(
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
                    Text(
                      _user.displayName!,
                      style:
                          Theme.of(context).textTheme.headlineSmall!.copyWith(
                                fontWeight: kBoldFontWeight,
                                color: kBlackColor,
                              ),
                    ),
                    verticalSpace(height: 32),
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
                        const Image(
                          image: AssetImage("assets/fenjen.png"),
                          width: 32,
                        ),
                        horizontalSpace(),
                        const Text("×"),
                        horizontalSpace(),
                        const Text("1"),
                        horizontalSpace(width: 24),
                        const Text("LBP"),
                        horizontalSpace(),
                        PriceInputText(
                          controller: _kahwaLbpController,
                        ),
                        horizontalSpace(width: 24),
                        const Text("USD"),
                        horizontalSpace(),
                        PriceInputText(
                          controller: _kahwaUsdController,
                        ),
                      ],
                    ),
                    verticalSpace(),
                    InputText(
                      controller: _phoneController,
                      icon: Icons.phone_rounded,
                      hint: "WHISH Phone Number",
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                    ),
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
      ),
    );
  }
}
