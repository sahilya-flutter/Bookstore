import 'package:book_store/custom_field.dart';
import 'package:book_store/firebase.dart';
import 'package:book_store/home.dart';
import 'package:book_store/signup.dart';
import 'package:flutter/material.dart';
import 'package:book_store/create_account.dart';
import 'package:book_store/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'dart:io';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:intl/intl.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  bool isobscure = true;
  void togglepass() {
    setState(() {
      isobscure = !isobscure;
    });
  }

  void searchBooks(String value) {
    // Implement search functionality here
  }
  FirebaseService firebaseService = FirebaseService();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  bool loading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final users = FirebaseFirestore.instance.collection('userData').obs;
  final fcmTokens = FirebaseFirestore.instance.collection('FCMTOKENS').obs;
  final GetStorage box = GetStorage();
  final DatabaseReference db =
      FirebaseDatabase.instance.ref().child('userData');
  Future<void> emailLogin(
      BuildContext context, String email, String password) async {
    setState(() {
      loading = true;
    });

    log("emain and pass is $email and $password");

    try {
      // Attempt to sign in with email and password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if the user is not null
      if (userCredential.user != null) {
        final userDoc = await users.value.doc(userCredential.user!.uid).get();

        if (userDoc.exists) {
          // Fetch and store user data
          // await box.write('login', 'login');
          // await box.write('userName', userDoc["userName"]);
          // await box.write('userId', userDoc["userId"]);

          // log("Username is : ${box.read('userName')}, UserId is : ${box.read('userId')}");

          Get.snackbar('Login Successful', 'Welcome to my app',
              backgroundColor: Colors.green,
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP);
        } else {
          Get.snackbar('Error', 'User data not found',
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP);
        }
      } else {
        Get.snackbar('Error', 'User not found',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = parseFirebaseAuthError(e.code);
      Get.snackbar('User Alert', errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP);

      log('Email login error: $errorMessage');
    } catch (e) {
      // Get.snackbar('Error', 'An unexpected error occurred.',
      //     backgroundColor: Colors.red,
      //     colorText: Colors.white,
      //     snackPosition: SnackPosition.TOP);

      log('Email login error: $e');
    } finally {
      setState(() {
        loading = false;
      });
      // Ensure loading is false at the end
    }
  }

  // Method to parse Firebase Auth errors
  String parseFirebaseAuthError(String errorCode) {
    log('error code is $errorCode');

    if (errorCode == 'weak-password') {
      return 'The password provided is too weak.';
    } else if (errorCode == 'email-already-in-use') {
      return 'The account already exists for that email.';
    } else if (errorCode == 'invalid-email') {
      return 'The email address is not valid.';
    } else if (errorCode == 'operation-not-allowed') {
      return 'Email/password accounts are not enabled. Please enable them in the Firebase Console.';
    } else if (errorCode == 'user-disabled') {
      return 'The user account has been disabled.';
    } else if (errorCode == 'user-not-found') {
      return 'No user found for that email.';
    } else if (errorCode == 'wrong-password') {
      return 'The password is incorrect for the provided email.';
    } else if (errorCode == 'too-many-requests') {
      return 'Too many requests. Please try again later.';
    } else if (errorCode == 'network-request-failed') {
      return 'Network error occurred. Please check your internet connection.';
    } else if (errorCode == "invalid-credential") {
      return 'Invalid Email id or Password';
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fill,
              opacity: 0.2,
              image: AssetImage("assets/images/background.jpeg"),
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Image.asset("assets/images/images.jpeg"),
                    const SizedBox(
                      height: 20,
                    ),
                    CustomTextField(
                      controller: email,
                      hintText: 'Username',
                      icon2: Icon(Icons.person),
                      obscureText: false,
                      onChanged: (value) {
                        searchBooks(value);
                      },
                    ),
                    const SizedBox(height: 16.0),
                    CustomTextField(
                      controller: password,
                      hintText: 'Password',
                      icon2: Icon(Icons.lock),
                      icon: IconButton(
                          onPressed: togglepass,
                          icon: Icon(isobscure == true
                              ? Icons.visibility_off
                              : Icons.visibility)),
                      obscureText: true,
                      onChanged: (value) {
                        searchBooks(value);
                      },
                    ),
                    const SizedBox(height: 24.0),
                    loading == false
                        ? ElevatedButton(
                            onPressed: () {
                              emailLogin(context, email.text.trim(),
                                      password.text.trim())
                                  .then(
                                (value) {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => const HomePage(
                                        isGuest: false,
                                      ),
                                    ),
                                  );
                                },
                              );

                              // Handle login button press
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              minimumSize: const Size(double.infinity, 48.0),
                            ),
                            child: const Text(
                              'Log In',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 20),
                            ),
                          )
                        : CircularProgressIndicator(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const Signup(),
                              ));
                            },
                            child: const Text('Sign up here'))
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
