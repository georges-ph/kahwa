import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:kahwa/enums/colors.dart' as colors_enum;
import 'package:kahwa/models/balance.dart';
import 'package:kahwa/models/billing_details.dart';
import 'package:kahwa/models/goal.dart';
import 'package:kahwa/models/kahwa_prices.dart';
import 'package:kahwa/models/user.dart' as user_model;
import 'package:kahwa/utils/colors.dart';
import 'package:kahwa/utils/routes.dart';
import 'package:kahwa/utils/sizes.dart';
import 'package:kahwa/utils/typography.dart';
import 'package:kahwa/widgets/input_text.dart';
import 'package:kahwa/widgets/shape_painter.dart';
import 'package:ms_undraw/ms_undraw.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late Size _screenSize;

  late ScrollController _scrollController;
  double _scrollOffset = 0;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _nameError = "";
  String _emailError = "";
  String _passwordError = "";
  bool _isPasswordVisible = true;
  bool _isNameErrorVisible = false;
  bool _isEmailErrorVisible = false;
  bool _isPasswordErrorVisible = false;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;

    return KeyboardSizeProvider(
      child: Scaffold(
        body: Consumer<ScreenHeight>(
          builder: (context, result, child) {
            return Stack(
              children: [
                Positioned(
                  bottom: result.isOpen
                      ? _scrollOffset - result.keyboardHeight
                      : _scrollOffset,
                  right: 0,
                  left: 0,
                  child: CustomPaint(
                    painter: ShapePainter(),
                    child: SizedBox(
                      width: _screenSize.width,
                      height: _screenSize.height,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: _screenSize.width * 0.6,
                          child: Text(
                            "Create an account",
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .copyWith(
                                  color: kWhiteColor,
                                  fontWeight: kExtraBoldFontWeight,
                                ),
                          ),
                        ),
                        verticalSpace(),
                        Align(
                          alignment: Alignment.center,
                          child: UnDraw(
                            height: _screenSize.width * 0.75,
                            illustration: UnDrawIllustration.authentication,
                            color: kRedColor,
                          ),
                        ),
                        verticalSpace(),
                        InputText(
                          controller: _nameController,
                          icon: Icons.person_rounded,
                          hint: "Name",
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                        ),
                        Visibility(
                          visible: _isNameErrorVisible,
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                            child: Text(
                              _nameError,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium!
                                  .copyWith(
                                    color: kRedColor,
                                  ),
                            ),
                          ),
                        ),
                        verticalSpace(height: 16),
                        InputText(
                          controller: _emailController,
                          icon: Icons.mail_rounded,
                          hint: "Email Address",
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),
                        Visibility(
                          visible: _isEmailErrorVisible,
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                            child: Text(
                              _emailError,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium!
                                  .copyWith(
                                    color: kRedColor,
                                  ),
                            ),
                          ),
                        ),
                        verticalSpace(height: 16),
                        InputText(
                          controller: _passwordController,
                          icon: Icons.lock_rounded,
                          hint: "Password",
                          suffixIcon: _isPasswordVisible
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                          obscureText: _isPasswordVisible,
                          textInputAction: TextInputAction.done,
                          suffixOnTap: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        Visibility(
                          visible: _isPasswordErrorVisible,
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                            child: Text(
                              _passwordError,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium!
                                  .copyWith(
                                    color: kRedColor,
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
                                      _nameError = "";
                                      _emailError = "";
                                      _passwordError = "";
                                      _isNameErrorVisible = false;
                                      _isEmailErrorVisible = false;
                                      _isPasswordErrorVisible = false;
                                    });
                                    if (_nameController.text.isEmpty ||
                                        _emailController.text.isEmpty ||
                                        _passwordController.text.isEmpty) {
                                      if (_nameController.text.isEmpty) {
                                        setState(() {
                                          _nameError = "Name cannot be empty";
                                          _isNameErrorVisible = true;
                                        });
                                      }
                                      if (_emailController.text.isEmpty) {
                                        setState(() {
                                          _emailError =
                                              "Email Address cannot be empty";
                                          _isEmailErrorVisible = true;
                                        });
                                      }

                                      if (_passwordController.text.isEmpty) {
                                        setState(() {
                                          _passwordError =
                                              "Password cannot be empty";
                                          _isPasswordErrorVisible = true;
                                        });
                                      }
                                      return;
                                    }
                                    try {
                                      setState(() {
                                        _isLoading = true;
                                      });

                                      final credential = await FirebaseAuth
                                          .instance
                                          .createUserWithEmailAndPassword(
                                        email: _emailController.text,
                                        password: _passwordController.text,
                                      );

                                      await credential.user?.updateDisplayName(
                                          _nameController.text);

                                      await credential.user
                                          ?.sendEmailVerification();

                                      // final dynamicLinkParams =
                                      //     DynamicLinkParameters(
                                      //   link: Uri.parse(
                                      //       "https://kahwa.page.link/${credential.user!.uid}"),
                                      //   uriPrefix: "https://kahwa.page.link/",
                                      //   androidParameters: AndroidParameters(
                                      //     packageName: "com.example.kahwa",
                                      //     fallbackUrl:
                                      //         Uri.parse("https://jundbits.ga/"),
                                      //   ),
                                      //   socialMetaTagParameters:
                                      //       SocialMetaTagParameters(
                                      //           title: _nameController.text,
                                      //           description:
                                      //               "Support ${_nameController.text} by buying them a kahwa",
                                      //           imageUrl: Uri.parse(
                                      //             "https://firebasestorage.googleapis.com/v0/b/development-71207.appspot.com/o/kahwa%2Ffenjen.png?alt=media&token=3f476325-20d9-4f4d-9924-d39438a40c1d",
                                      //           )),
                                      // );

                                      // final dynamicLink =
                                      //     await FirebaseDynamicLinks.instance
                                      //         .buildShortLink(
                                      //   dynamicLinkParams,
                                      //   shortLinkType:
                                      //       ShortDynamicLinkType.unguessable,
                                      // );

                                      // String linkId = dynamicLink.shortUrl
                                      //     .toString()
                                      //     .split("https://kahwa.page.link/")[1];

                                      user_model.User user = user_model.User(
                                        name: _nameController.text,
                                        email: _emailController.text,
                                        image: null,
                                        id: credential.user!.uid,
                                        kahwa_prices: KahwaPrices(
                                          lbp: 1000,
                                          usd: 1,
                                          thanks_message: null,
                                        ),
                                        balance: Balance(
                                          available_withdraw_lbp: 0,
                                          available_withdraw_usd: 0,
                                          current_lbp: 0,
                                          current_usd: 0,
                                          received_lbp: 0,
                                          received_usd: 0,
                                          spent_lbp: 0,
                                          spent_usd: 0,
                                        ),
                                        billing_details: BillingDetails(
                                          first_name: null,
                                          last_name: null,
                                          phone: null,
                                          whish_phone: null,
                                        ),
                                        goal: Goal(
                                          current: null,
                                          description: null,
                                          target: null,
                                          title: null,
                                        ),
                                        fans: [],
                                        about: null,
                                        color: colors_enum.Colors.red,
                                        website: null,
                                        // link_id: linkId,
                                      );

                                      await FirebaseFirestore.instance
                                          .collection("kahwa")
                                          .doc("AppCollections")
                                          .collection("Users")
                                          .doc(credential.user!.uid)
                                          .set(user.toMap());

                                      Navigator.pushReplacementNamed(
                                          context, routeSplash);
                                    } on FirebaseAuthException catch (e) {
                                      if (e.code == "invalid-email" ||
                                          e.code == "email-already-in-use") {
                                        setState(() {
                                          _emailError = e.message!;
                                          _isEmailErrorVisible = true;
                                        });
                                      } else if (e.code == "weak-password") {
                                        setState(() {
                                          _passwordError = e.message!;
                                          _isPasswordErrorVisible = true;
                                        });
                                      } else {
                                        SnackBar snackBar = SnackBar(
                                          content: Text(e.message!),
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackBar);
                                      }
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                  },
                            child: _isLoading
                                ? const SizedBox.square(
                                    dimension: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                    ),
                                  )
                                : const Text("Sign Up"),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account?",
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            TextButton(
                              onPressed: () => Navigator.pushReplacementNamed(
                                  context, routeLogIn),
                              child: const Text("Log In"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
