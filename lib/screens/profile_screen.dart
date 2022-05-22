import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kahwa/enums/colors.dart' as colors_enum;
import 'package:kahwa/models/user.dart' as user_model;
import 'package:kahwa/utils/colors.dart';
import 'package:kahwa/utils/sizes.dart';
import 'package:kahwa/utils/statics.dart';
import 'package:kahwa/utils/typography.dart';
import 'package:kahwa/widgets/check_color_box.dart';
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
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  late User _user;
  late DocumentReference _appDocument;
  late DocumentReference<Map<String, dynamic>> _userDocument;
  late final Reference _profilePicturesStorageReference =
      _firebaseStorage.ref().child("kahwa/Profile Pictures");

  late Future<void> _runFuture;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _aboutMeController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  // final TextEditingController _linkController = TextEditingController();

  late user_model.User _userModel;
  late colors_enum.Colors _checkedColor;

  bool _isImageLoading = false;
  bool _isLoading = false;

  double _uploadProgress = 0;

  @override
  void initState() {
    super.initState();
    _user = _firebaseAuth.currentUser!;
    _appDocument = _firebaseFirestore.collection("kahwa").doc("AppCollections");
    _userDocument = _appDocument.collection("Users").doc(_user.uid);
    _runFuture = _getUserData();
    _nameController.text = _user.displayName!;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutMeController.dispose();
    _websiteController.dispose();
    // _linkController.dispose();
    super.dispose();
  }

  Future<void> _getUserData() async {
    DocumentSnapshot<Map<String, dynamic>> document = await _userDocument.get();
    _userModel =
        user_model.User.fromMap(document.data() as Map<String, dynamic>);

    _userModel.image = _user.photoURL;

    _aboutMeController.text = _userModel.about ?? "";
    _websiteController.text = _userModel.website ?? "";
    _checkedColor = _userModel.color ?? colors_enum.Colors.brown;
    // _linkController.text = "kahwa.page.link/${_userModel.link_id}";
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final tempImage = File(image.path);
    _cropImage(tempImage);
  }

  Future _cropImage(File image) async {
    final croppedImage = await ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      cropStyle: CropStyle.circle,
      uiSettings: [
        AndroidUiSettings(
          hideBottomControls: true,
        ),
      ],
    );
    if (croppedImage == null) return;
    final tempImage = File(croppedImage.path);
    _uploadImage(tempImage);
  }

  void _uploadImage(File image) {
    setState(() {
      _isImageLoading = true;
    });
    final userReference =
        _profilePicturesStorageReference.child("${_user.uid}.jpg");
    userReference.putFile(image).snapshotEvents.listen((taskSnapshot) {
      switch (taskSnapshot.state) {
        case TaskState.running:
          final progress =
              taskSnapshot.bytesTransferred / taskSnapshot.totalBytes;

          setState(() {
            _uploadProgress = progress;
          });
          break;

        case TaskState.success:
          userReference.getDownloadURL().then((url) async {
            await _user.updatePhotoURL(url);
            setState(() {
              Statics.userImage = url;
              _userModel.image = url;
              _isImageLoading = false;
            });
          });

          break;

        case TaskState.error:
        case TaskState.canceled:
        default:
          setState(() {
            _isImageLoading = false;
          });
          SnackBar snackBar =
              const SnackBar(content: Text("Error uploading image"));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          break;
      }
    });
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
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(24),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Profile".toUpperCase(),
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    verticalSpace(height: 40),
                    Align(
                      alignment: Alignment.center,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: _screenSize.width / 5,
                            backgroundImage: _userModel.image != null
                                ? NetworkImage(_userModel.image!)
                                : null,
                            backgroundColor: kBrownColor.withOpacity(0.6),
                            child: _userModel.image == null
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
                          Visibility(
                            visible: _isImageLoading,
                            child: Positioned.fill(
                              child: CircularProgressIndicator(
                                value: _uploadProgress == 0
                                    ? null
                                    : _uploadProgress,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: ElevatedButton(
                              onPressed: () => _pickImage(),
                              child: const Icon(Icons.camera_alt_rounded),
                              style: TextButton.styleFrom(
                                shape: const CircleBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
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
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  fontWeight: kSemiBoldFontWeight,
                                ),
                      ),
                    ),
                    verticalSpace(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CheckColorBox(
                          color: kBrownColor,
                          checkedValue:
                              _checkedColor == colors_enum.Colors.brown,
                          checked: (checked) {
                            setState(() {
                              if (checked) {
                                _checkedColor = colors_enum.Colors.brown;
                              }
                            });
                          },
                        ),
                        CheckColorBox(
                          color: kPinkColor,
                          checkedValue:
                              _checkedColor == colors_enum.Colors.pink,
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
                          checkedValue:
                              _checkedColor == colors_enum.Colors.cyan,
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
                          checkedValue:
                              _checkedColor == colors_enum.Colors.green,
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
                                if (_nameController.text.isEmpty ||
                                    _aboutMeController.text.isEmpty ||
                                    _websiteController.text.isEmpty) {
                                  SnackBar snackBar = const SnackBar(
                                      content: Text("Fields cannot be empty"));
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                  return;
                                }

                                setState(() {
                                  _isLoading = true;
                                });

                                _userModel.name = _nameController.text;
                                _userModel.about = _aboutMeController.text;
                                _userModel.website = _websiteController.text;
                                _userModel.color = _checkedColor;

                                await _user
                                    .updateDisplayName(_nameController.text);

                                await _userDocument.update(_userModel.toMap());

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
