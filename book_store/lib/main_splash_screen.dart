import 'dart:async';
import 'package:book_store/splash_screen.dart';
import 'package:flutter/material.dart';

class MainSplashScreen extends StatefulWidget {
  const MainSplashScreen({super.key});

  @override
  State<MainSplashScreen> createState() => _MainSplashScreenState();
}

class _MainSplashScreenState extends State<MainSplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to LoginPage after 3 seconds
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SplashScreen()),
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
