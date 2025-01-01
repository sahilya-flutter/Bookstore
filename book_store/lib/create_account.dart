import 'package:book_store/custom_field.dart';
import 'package:book_store/firebase.dart';
import 'package:book_store/home.dart';
import 'package:book_store/signup.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

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

  FirebaseService firebaseService = FirebaseService();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool loading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final users = FirebaseFirestore.instance.collection('userData').obs;
  final GetStorage box = GetStorage();
  final DatabaseReference db =
      FirebaseDatabase.instance.ref().child('userData');

  void emailLogin(BuildContext context, String email, String password) async {
    setState(() {
      loading = true;
    });

    log("Email and password are $email and $password");

    try {
      // Attempt to sign in with email and password
      UserCredential? userCredential;
      try {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } catch (e) {
        log("Error during sign-in: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Check if userCredential is null
      if (userCredential.user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No user found for that email or password.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Fetch user data from Firebase Realtime Database
      final userRef = db.child(userCredential.user!.uid);
      final userSnapshot = await userRef.get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.value as Map<dynamic, dynamic>;

        log('User data is $userData');

        // Store user data in GetStorage for session management
        await box.write('login', 'login');
        await box.write('userName', userData["userName"]);
        await box.write('userId', userData["userId"]);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful! Welcome back'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        );

        // Navigate to HomePage after successful login
        await Future.delayed(
            const Duration(seconds: 1)); // Wait for snackbar to be visible
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const HomePage(isGuest: true),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User data not found in the database.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = parseFirebaseAuthError(e.code);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
      log('Email login error: $errorMessage');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An unexpected error occurred.'),
          backgroundColor: Colors.red,
        ),
      );
      log('Email login error: $e');
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  // Method to parse Firebase Auth errors
  String parseFirebaseAuthError(String errorCode) {
    log('Error code is $errorCode');

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
      return 'An unknown error occurred.';
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
                    Image.asset('assets/images/bookstudy.png'),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: emailController,
                      hintText: 'Email',
                      icon2: const Icon(Icons.person),
                      obscureText: false,
                      onChanged: (value) {},
                    ),
                    const SizedBox(height: 16.0),
                    CustomTextField(
                      controller: passwordController,
                      hintText: 'Password',
                      icon2: IconButton(
                          onPressed: togglepass,
                          icon: Icon(isobscure ? Icons.lock : Icons.lock_open)),
                      icon: IconButton(
                        onPressed: togglepass,
                        icon: Icon(
                          isobscure ? Icons.visibility_off : Icons.visibility,
                        ),
                      ),
                      obscureText: isobscure,
                      onChanged: (value) {},
                    ),
                    const SizedBox(height: 24.0),
                    loading == false
                        ? ElevatedButton(
                            onPressed: () {
                              emailLogin(
                                context,
                                emailController.text.trim(),
                                passwordController.text.trim(),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFCC5500),
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
                                fontSize: 20,
                              ),
                            ),
                          )
                        : const CircularProgressIndicator(),
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
                          child: const Text('Sign up here'),
                        ),
                      ],
                    ),
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
