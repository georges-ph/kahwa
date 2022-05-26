import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kahwa/enums/colors.dart' as colors_enum;
import 'package:kahwa/models/balance.dart';
import 'package:kahwa/models/kahwa_prices.dart';
import 'package:kahwa/models/user.dart' as user_model;
import 'package:kahwa/utils/colors.dart';
import 'package:kahwa/utils/routes.dart';
import 'package:kahwa/utils/sizes.dart';
import 'package:kahwa/utils/statics.dart';
import 'package:kahwa/utils/typography.dart';
import 'package:kahwa/widgets/input_text.dart';
import 'package:kahwa/widgets/shape_painter.dart';

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

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: KeyboardSizeProvider(
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
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
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
                            child: SvgPicture.asset(
                              "assets/undraw_authentication.svg",
                              height: _screenSize.width * 0.7,
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
                                      color: kBrownColor,
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
                                      color: kBrownColor,
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

                                        await credential.user
                                            ?.updateDisplayName(
                                                _nameController.text);
                                        await credential.user
                                            ?.sendEmailVerification();

                                        final dynamicLinkParams =
                                            DynamicLinkParameters(
                                          link: Uri.parse(
                                              "${Statics.dynamicUrlPrefix}?id=${credential.user!.uid}"),
                                          uriPrefix: Statics.dynamicUrlPrefix,
                                          androidParameters: AndroidParameters(
                                            packageName: "ga.jundbits.kahwa",
                                            fallbackUrl: Uri.parse(
                                                "https://kahwa.jundbits.ga/download"),
                                          ),
                                          socialMetaTagParameters:
                                              SocialMetaTagParameters(
                                                  title: _nameController.text,
                                                  description:
                                                      "Support ${_nameController.text} by buying them a kahwa",
                                                  imageUrl: Uri.parse(
                                                    "https://firebasestorage.googleapis.com/v0/b/jundbits-27eab.appspot.com/o/kahwa%2Fcup%20social.png?alt=media&token=86342b10-5786-464f-b167-a4885b82d5b4",
                                                  )),
                                        );

                                        final dynamicLink =
                                            await FirebaseDynamicLinks.instance
                                                .buildShortLink(
                                          dynamicLinkParams,
                                          shortLinkType:
                                              ShortDynamicLinkType.unguessable,
                                        );

                                        String linkId = dynamicLink.shortUrl
                                            .toString()
                                            .split(
                                                "${Statics.dynamicUrlPrefix}/")[1];

                                        String userId = credential.user!.uid;

                                        user_model.User user = user_model.User(
                                          name: _nameController.text,
                                          email: _emailController.text,
                                          image: null,
                                          id: userId,
                                          about: null,
                                          color: colors_enum.Colors.brown,
                                          website: null,
                                          fans: [],
                                          link_id: linkId,
                                        );

                                        KahwaPrices kahwaPrices = KahwaPrices(
                                          lbp: 1000,
                                          usd: 1,
                                          thanks_message: null,
                                        );

                                        Balance balance = Balance(
                                          withdrawn_lbp: 0,
                                          withdrawn_usd: 0,
                                          current_lbp: 0,
                                          current_usd: 0,
                                          received_lbp: 0,
                                          received_usd: 0,
                                          spent_lbp: 0,
                                          spent_usd: 0,
                                        );

                                        FirebaseFirestore firebaseFirestore =
                                            FirebaseFirestore.instance;
                                        final batch = firebaseFirestore.batch();

                                        DocumentReference appDocument =
                                            firebaseFirestore
                                                .collection("kahwa")
                                                .doc("AppCollections");

                                        DocumentReference userDocument =
                                            appDocument
                                                .collection("Users")
                                                .doc(userId);
                                        DocumentReference kahwaPricesDocument =
                                            appDocument
                                                .collection("kahwaPrices")
                                                .doc(userId);
                                        DocumentReference balanceDocument =
                                            appDocument
                                                .collection("Balances")
                                                .doc(userId);

                                        batch.set(userDocument, user.toMap());
                                        batch.set(kahwaPricesDocument,
                                            kahwaPrices.toMap());
                                        batch.set(
                                            balanceDocument, balance.toMap());
                                        await batch.commit();

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
      ),
    );
  }
}
