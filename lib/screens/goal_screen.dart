import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kahwa/models/goal.dart';
import 'package:kahwa/utils/colors.dart';
import 'package:kahwa/utils/sizes.dart';
import 'package:kahwa/utils/statics.dart';
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
  late DocumentReference<Map<String, dynamic>> _goalDocument;

  late Goal _goal;

  late Future<void> _runFuture;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _currentController = TextEditingController();

  bool _isLoading = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _user = _firebaseAuth.currentUser!;
    _appDocument = _firebaseFirestore.collection("kahwa").doc("AppCollections");
    _goalDocument = _appDocument.collection("Goals").doc(_user.uid);
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
    DocumentSnapshot<Map<String, dynamic>> document = await _goalDocument.get();
    if (!document.exists) {
      _goal = Goal(
        id: _user.uid,
      );
      return;
    }
    _goal = Goal.fromMap(document.data() as Map<String, dynamic>);

    _titleController.text = _goal.title ?? "";
    _descriptionController.text = _goal.description ?? "";
    _targetController.text = _goal.target.toString();
    _currentController.text = _goal.current.toString();
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Text(
                        _goal.title == null ? "Add New Goal" : "Edit Goal",
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ),
                    verticalSpace(height: 40),
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

                                _goal.title = _titleController.text;
                                _goal.description = _descriptionController.text;
                                _goal.target =
                                    int.parse(_targetController.text);
                                _goal.current =
                                    _currentController.text.isNotEmpty
                                        ? int.parse(_currentController.text)
                                        : 0;

                                Statics.goal = _goal;

                                await _goalDocument.set(
                                    _goal.toMap(), SetOptions(merge: true));

                                SnackBar snackBar = const SnackBar(
                                    content: Text("Saved successfully"));

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
                    _goal.title == null
                        ? Container()
                        : verticalSpace(height: 16),
                    _goal.title == null
                        ? Container()
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kWhiteColor,
                                foregroundColor: kBrownColor,
                                side: const BorderSide(
                                  color: kBrownColor,
                                ),
                              ),
                              onPressed: _isDeleting
                                  ? null
                                  : () async {
                                      setState(() {
                                        _isDeleting = true;
                                      });

                                      _firebaseFirestore
                                          .runTransaction((transaction) async {
                                        transaction.delete(_goalDocument);
                                        transaction.set(
                                            _appDocument
                                                .collection("Users")
                                                .doc(_user.uid)
                                                .collection("ArchivedGoals")
                                                .doc(),
                                            _goal.toMap());
                                        return true;
                                      }).then((success) {
                                        if (success) {
                                          SnackBar snackBar = const SnackBar(
                                              content: Text("Goal deleted"));

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(snackBar);

                                          setState(() {
                                            _isDeleting = false;
                                          });

                                          Navigator.pop(context, true);
                                        }
                                      });
                                    },
                              child: _isDeleting
                                  ? const SizedBox.square(
                                      dimension: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : const Text("Delete Goal"),
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
