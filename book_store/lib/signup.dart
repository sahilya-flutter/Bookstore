import 'package:book_store/create_account.dart';
import 'package:book_store/custom_field.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:developer';
import 'dart:io';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  bool isobscure = true;
  void togglepass() {
    setState(() {
      isobscure = !isobscure;
    });
  }

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();

  RxBool loading = false.obs;
  RxBool isVisible1 = false.obs;
  RxBool isVisible2 = false.obs;
  RxBool isVisible = false.obs;
  bool signupLoading = false;
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
    setState(() {
      signupLoading = true;
    });

    // Check if user already exists
    final existingUser =
        await users.value.where("email", isEqualTo: email).get();
    if (existingUser.docs.isNotEmpty) {
      setState(() {
        signupLoading = false;
      });

      // Get.snackbar('User Alert', 'User already exists',
      //     backgroundColor: Colors.red,
      //     colorText: Colors.white,
      //     snackPosition: SnackPosition.TOP);
      return;
    }

    // Create user in Firebase Auth
    try {
      UserCredential value = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      log('Email and password are $email, $password');
      log('usernname is $userName and name is $name');
      log("Username is ${userName} uid is ${value.user!.uid} num is ${name}");

      String uid = await _getNextUserId();
      Map<String, dynamic> userData = {
        "userName": userName ?? '',
        "userId": uid,
        "email": email,
        "name": name ?? '',
        "signUpTime": DateFormat('hh:mm:ss a').format(DateTime.now()),
        "signUpDate": DateFormat('dd-MMM-yyyy').format(DateTime.now()),
      };

      // Insert user data into Firestore with image URL
      await db.child(value.user!.uid).set(userData);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('')));
      // Get.snackbar('Signup Successful', 'Please login',
      //     backgroundColor: Colors.green,
      //     colorText: Colors.white,
      //     snackPosition: SnackPosition.TOP);
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const CreateAccount(),
      ));
    } on FirebaseAuthException catch (e) {
      setState(() {
        signupLoading = false;
      });

      String errorMessage = parseFirebaseAuthError(e.code);
      // Get.snackbar('Error', errorMessage,
      //     backgroundColor: Colors.red,
      //     colorText: Colors.white,
      //     snackPosition: SnackPosition.TOP);
    } catch (e) {
      setState(() {
        signupLoading = false;
      });

      // Get.snackbar('Error', 'An unexpected error occurred.',
      //     backgroundColor: Colors.red,
      //     colorText: Colors.white,
      //     snackPosition: SnackPosition.TOP);
    } finally {
      setState(() {
        signupLoading = false;
      });
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
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/images/bookstudy.png'),
                    const SizedBox(
                      height: 24.0,
                    ),
                    CustomTextField(
                      controller: nameController,
                      hintText: "Name",
                      obscureText: false,
                      icon2: const Icon(Icons.person_2_outlined),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    CustomTextField(
                      controller: usernameController,
                      hintText: "Username",
                      obscureText: false,
                      icon2: const Icon(Icons.person),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    CustomTextField(
                      controller: emailController,
                      hintText: "email",
                      obscureText: false,
                      icon2: const Icon(Icons.email_outlined),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    CustomTextField(
                      controller: passwordController,
                      hintText: "Password",
                      obscureText: isobscure,
                      icon2: const Icon(Icons.lock),
                      icon: IconButton(
                          onPressed: togglepass,
                          icon: Icon(isobscure == true
                              ? Icons.visibility_off
                              : Icons.visibility)),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    signupLoading == false
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 30),
                            child: ElevatedButton(
                              onPressed: () {
                                signUp(
                                  context,
                                  emailController.text.trim(),
                                  passwordController.text.trim(),
                                  name: nameController.text.trim(),
                                  userName: usernameController.text.trim(),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                minimumSize: const Size(double.infinity, 48.0),
                              ),
                              child: const Text(
                                'Create Account',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 20),
                              ),
                            ),
                          )
                        : const CircularProgressIndicator(),
                    Row(
                      children: [
                        const Text("Alredy have an account?"),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const CreateAccount(),
                              ));
                            },
                            child: const Text("Log In here"))
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
