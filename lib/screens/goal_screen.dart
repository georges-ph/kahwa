import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kahwa/models/user.dart' as user_model;
import 'package:kahwa/utils/sizes.dart';
import 'package:kahwa/widgets/input_text.dart';

class GoalScreen extends StatefulWidget {
  const GoalScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  late User _user;
  late DocumentReference _appDocument;

  late user_model.User _userModel;

  late Future<void> _runFuture;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _targetController;
  late TextEditingController _currentController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _user = _firebaseAuth.currentUser!;
    _appDocument = _firebaseFirestore.collection("kahwa").doc("AppCollections");
    _runFuture = _getUserData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    super.dispose();
  }

  Future<void> _getUserData() async {
    DocumentSnapshot<Map<String, dynamic>> userDocument =
        await _appDocument.collection("Users").doc(_user.uid).get();
    _userModel =
        user_model.User.fromMap(userDocument.data() as Map<String, dynamic>);

    _titleController = TextEditingController(text: _userModel.goal!.title);
    _descriptionController =
        TextEditingController(text: _userModel.goal!.description);
    _targetController =
        TextEditingController(text: _userModel.goal!.target.toString());
    _currentController =
        TextEditingController(text: _userModel.goal!.current.toString());
  }

  @override
  Widget build(BuildContext context) {
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
                  children: [
                    Text(
                        _userModel.goal == null ? "Add New Goal" : "Edit Goal"),
                    InputText(
                      controller: _titleController,
                      title: "Goal Title",
                      hint: "New camera",
                      textInputAction: TextInputAction.next,
                    ),
                    verticalSpace(),
                    InputText(
                      controller: _descriptionController,
                      title: "Goal Description",
                      hint: "Enter a description for your goal",
                      maxLines: 5,
                      textInputAction: TextInputAction.next,
                    ),
                    verticalSpace(),
                    InputText(
                      controller: _targetController,
                      title: "Target Amount",
                      hint: 0.toString(),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                    ),
                    verticalSpace(),
                    InputText(
                      controller: _currentController,
                      title: "Current amount",
                      hint: 0.toString(),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                    ),
                    verticalSpace(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                if (_titleController.text.isEmpty ||
                                    _descriptionController.text.isEmpty ||
                                    _targetController.text.isEmpty) {
                                  SnackBar snackBar = const SnackBar(
                                    content: Text(
                                        "You cannot add a goal without a title, description and target amount"),
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                  return;
                                }

                                setState(() {
                                  _isLoading = true;
                                });

                                _userModel.goal!.title = _titleController.text;
                                _userModel.goal!.description =
                                    _descriptionController.text;
                                _userModel.goal!.target =
                                    int.parse(_targetController.text);
                                _userModel.goal!.current =
                                    int.parse(_currentController.text);

                                await FirebaseFirestore.instance
                                    .collection("kahwa")
                                    .doc("AppCollections")
                                    .collection("Users")
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .update(_userModel.toMap());

                                setState(() {
                                  _isLoading = false;
                                });

                                Navigator.pop(context);
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
