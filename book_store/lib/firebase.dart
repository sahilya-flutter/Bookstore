import 'dart:developer';
import 'dart:io';

import 'package:book_store/create_account.dart';
import 'package:book_store/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:intl/intl.dart';

class FirebaseService {
  final GetStorage box = GetStorage();

  final userNameController = TextEditingController();
  RxBool loading = false.obs;
  RxBool isVisible1 = false.obs;
  RxBool isVisible2 = false.obs;
  RxBool isVisible = false.obs;
  RxBool signupLoading = false.obs;
  RxBool googleLoading = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final users = FirebaseFirestore.instance.collection('userData').obs;
  final fcmTokens = FirebaseFirestore.instance.collection('FCMTOKENS').obs;
  final DatabaseReference db =
      FirebaseDatabase.instance.ref().child('userData');
  final Rx<File?> profileImage = Rx<File?>(null);

  void signUp(
    BuildContext context,
    String email,
    String password, {
    String? userName,
    String? name,
  }) async {
    signupLoading.value = true;

    // Check if user already exists
    final existingUser =
        await users.value.where("email", isEqualTo: email).get();
    if (existingUser.docs.isNotEmpty) {
      signupLoading.value = false;

      Get.snackbar('User Alert', 'User already exists',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
      return;
    }

    // Create user in Firebase Auth
    try {
      UserCredential value = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      log('Email and password are $email, $password');
      log("Username is ${userNameController.text} uid is ${value.user!.uid} num is ${name}");

      String uid = await _getNextUserId();

      // Upload profile image to Firebase Storage and get the URL

      Map<String, dynamic> userData = {
        "userName": userNameController.text.trim(),
        "userId": uid,
        "email": email,
        "name": name,
        "signUpTime": DateFormat('hh:mm:ss a').format(DateTime.now()),
        "signUpDate": DateFormat('dd-MMM-yyyy').format(DateTime.now()),
      };

      // Insert user data into Firestore with image URL
      await db.child(value.user!.uid).set(userData);

      Get.snackbar('Signup Successful', 'Please login',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const CreateAccount(),
      ));
      clearForm();
    } on FirebaseAuthException catch (e) {
      signupLoading.value = false;

      String errorMessage = parseFirebaseAuthError(e.code);
      Get.snackbar('Error', errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
    } catch (e) {
      signupLoading.value = false;

      Get.snackbar('Error', 'An unexpected error occurred.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
    } finally {
      signupLoading.value = false;
    }
  }

  // Method to get the next available user ID
  Future<String> _getNextUserId() async {
    final querySnapshot =
        await users.value.orderBy("userId", descending: true).limit(1).get();

    if (querySnapshot.docs.isNotEmpty) {
      // Convert userId to int, increment, then convert back to String
      int nextUserId = int.parse(querySnapshot.docs.first["userId"]) + 1;
      return nextUserId.toString();
    } else {
      return '1'; // Start user ID from 1 if there are no users
    }
  }

  void clearForm() {}

  // void resetPassword() {
  //   Get.dialog(
  //     AlertDialog(
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(16),
  //       ),
  //       title: const Text('Reset Password'),
  //       content: const Text('Enter your email id to get reset link'),
  //       actions: [
  //         TextFormField(
  //           validator: (value) {
  //             if (value == null || value.isEmpty) {
  //               return 'Please enter your email id';
  //             }
  //             return null;
  //           },
  //           decoration: const InputDecoration(
  //             hintText: 'Enter email',
  //             fillColor: Color.fromARGB(255, 210, 230, 249),
  //           ),
  //         ),
  //         const SizedBox(
  //           height: 8,
  //         ),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             TextButton(
  //               onPressed: () => Get.back(),
  //               child: Text(
  //                 'Cancel',
  //                 style: TextStyle(color: Colors.red, fontSize: 15),
  //               ),
  //             ),
  //             ElevatedButton(
  //               onPressed: () {
  //                 if (emailController.text != '') {
  //                   forgotloign(emailController.text);

  //                   Get.back();
  //                 } else {
  //                   Get.snackbar('User Alert', 'Please enter email',
  //                       backgroundColor: Colors.red,
  //                       colorText: Colors.white,
  //                       snackPosition: SnackPosition.TOP);
  //                 }
  //               },
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: Colors.red,
  //               ),
  //               child: Text(
  //                 'Send',
  //               ),
  //             ),
  //           ],
  //         )
  //       ],
  //     ),
  //   );
  // }

  // void forgotloign(String email) {
  //   _auth.sendPasswordResetEmail(email: email).then((value) {
  //     emailController.clear();
  //     Get.back();
  //     Get.snackbar('User Alert', 'Sent email to reset password',
  //         backgroundColor: Colors.green,
  //         colorText: Colors.white,
  //         snackPosition: SnackPosition.TOP);
  //     //Get.toNamed('/login_screen');
  //   }).onError((error, stackTrace) {
  //     Get.snackbar('Error', error.toString(), snackPosition: SnackPosition.TOP);
  //   });
  // }

  void emailLogin(BuildContext context, String email, String password) async {
    loading.value = true;

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
          await box.write('login', 'login');
          await box.write('userName', userDoc["userName"]);
          await box.write('userId', userDoc["userId"]);

          log("Username is : ${box.read('userName')}, UserId is : ${box.read('userId')}");

          Get.snackbar('Login Successful', 'Welcome to my app',
              backgroundColor: Colors.green,
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP);

          clearForm();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const HomePage(
                isGuest: false,
              ),
            ),
          );
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
      loading.value = false; // Ensure loading is false at the end
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

  void firebasesignInWithGoogle(
    BuildContext context,
  ) {
    try {
      googleLoading.value = true;

      GoogleAuthProvider googleAuthProvider = GoogleAuthProvider();
      _auth.signInWithProvider(googleAuthProvider).then(
        (value) {
          //  Utils().toastMessage(value.user!.email.toString());
          // Get.to(() => const FirebaseHomeScreen());

          googleLoading.value = false;
        },
      ).onError(
        (error, stackTrace) {
          //Utils().toastMessage(error.toString());

          googleLoading.value = false;
        },
      );
    } catch (e) {
      log(e.toString());
    }
  }
}
