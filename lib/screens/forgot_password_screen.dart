import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:kahwa/utils/colors.dart';
import 'package:kahwa/utils/sizes.dart';
import 'package:kahwa/utils/typography.dart';
import 'package:kahwa/widgets/input_text.dart';
import 'package:kahwa/widgets/shape_painter.dart';
import 'package:ms_undraw/ms_undraw.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late Size _screenSize;

  late ScrollController _scrollController;
  double _scrollOffset = 0;

  final TextEditingController _emailController = TextEditingController();

  String _emailError = "";
  bool _isEmailErrorVisible = false;
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
    _emailController.dispose();
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
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: _screenSize.width * 0.6,
                          child: Text(
                            "Forgot Password",
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .copyWith(
                                  color: kWhiteColor,
                                  fontWeight: kExtraBoldFontWeight,
                                ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: UnDraw(
                            height: _screenSize.width * 0.75,
                            illustration: UnDrawIllustration.forgot_password,
                            color: kRedColor,
                          ),
                        ),
                        InputText(
                          controller: _emailController,
                          icon: Icons.mail_rounded,
                          hint: "Email Address",
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
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
                        verticalSpace(),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    setState(() {
                                      _emailError = "";
                                      _isEmailErrorVisible = false;
                                    });
                                    if (_emailController.text.isEmpty) {
                                      setState(() {
                                        _emailError =
                                            "Email Address cannot be empty";
                                        _isEmailErrorVisible = true;
                                      });
                                    } else {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      try {
                                        await FirebaseAuth.instance
                                            .sendPasswordResetEmail(
                                                email: _emailController.text);
                                        SnackBar snackBar = const SnackBar(
                                          content: Text(
                                            "An email will be sent to you shortly to reset your password",
                                          ),
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackBar);
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      } on FirebaseAuthException catch (e) {
                                        if (e.code == "invalid-email") {
                                          setState(() {
                                            _emailError = e.message!;
                                            _isEmailErrorVisible = true;
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
                                    }
                                  },
                            child: _isLoading
                                ? const SizedBox.square(
                                    dimension: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                    ),
                                  )
                                : const Text("Reset Password"),
                          ),
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
