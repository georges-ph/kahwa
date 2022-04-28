import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
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

  String _name = "";
  String _email = "";
  String _password = "";
  String _nameError = "";
  String _emailError = "";
  String _passwordError = "";
  bool _isPasswordVisible = true;
  bool _isNameErrorVisible = false;
  bool _isEmailErrorVisible = false;
  bool _isPasswordErrorVisible = false;
  bool _isCreator = false;
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
                          icon: Icons.person_rounded,
                          hint: "Name",
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          onChanged: (value) {
                            _name = value;
                          },
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
                          icon: Icons.mail_rounded,
                          hint: "Email Address",
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onChanged: (value) {
                            _email = value;
                          },
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
                          icon: Icons.lock_rounded,
                          hint: "Password",
                          suffixIcon: _isPasswordVisible
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                          obscureText: _isPasswordVisible,
                          textInputAction: TextInputAction.done,
                          onChanged: (value) {
                            _password = value;
                          },
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
                        CheckboxListTile(
                          title: Text(
                            "I am a creator",
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          value: _isCreator,
                          onChanged: (checked) {
                            setState(() {
                              _isCreator = checked!;
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
                                      _nameError = "";
                                      _emailError = "";
                                      _passwordError = "";
                                      _isNameErrorVisible = false;
                                      _isEmailErrorVisible = false;
                                      _isPasswordErrorVisible = false;
                                    });
                                    if (_name.isEmpty ||
                                        _email.isEmpty ||
                                        _password.isEmpty) {
                                      if (_name.isEmpty) {
                                        setState(() {
                                          _nameError = "Name cannot be empty";
                                          _isNameErrorVisible = true;
                                        });
                                      }
                                      if (_email.isEmpty) {
                                        setState(() {
                                          _emailError =
                                              "Email Address cannot be empty";
                                          _isEmailErrorVisible = true;
                                        });
                                      }

                                      if (_password.isEmpty) {
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
                                        email: _email,
                                        password: _password,
                                      );
                                      await credential.user
                                          ?.updateDisplayName(_name);
                                      await credential.user
                                          ?.sendEmailVerification();
                                      Navigator.pushReplacementNamed(
                                          context, routeProfile);
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
