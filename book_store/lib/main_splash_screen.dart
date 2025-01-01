import 'dart:async';
import 'package:book_store/create_account.dart';
import 'package:book_store/home.dart';
import 'package:book_store/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class MainSplashScreen extends StatefulWidget {
  const MainSplashScreen({super.key});

  @override
  State<MainSplashScreen> createState() => _MainSplashScreenState();
}

class _MainSplashScreenState extends State<MainSplashScreen> {
  final GetStorage box = GetStorage();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(seconds: 3), () async {
      box.read("login") == 'login'
          ? Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const HomePage(isGuest: false),
              ),
            )
          : Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const CreateAccount(),
              ),
            );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 200,
            ),
            Container(
              height: 144, // Height of the image
              width: 144, // Width of the image
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors
                    .white, // Background color (matches splash background)
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey, // Shadow color
                    blurRadius: 10.0, // Shadow blur radius
                  ),
                ],
              ),
              child: Image.asset(
                "assets/images/BookStore.png",
                fit: BoxFit.contain, // Keeps the image proportions
              ),
            ),
            const SizedBox(height: 244),
            const Text(
              "Mega Book Store",
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
