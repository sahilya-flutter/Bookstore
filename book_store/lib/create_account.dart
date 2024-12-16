import 'package:book_store/custom_field.dart';
import 'package:book_store/home.dart';
import 'package:book_store/signup.dart';
import 'package:flutter/material.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  void searchBooks(String value) {
    // Implement search functionality here
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
                      hintText: 'Username',
                      obscureText: false, onChanged: (value) { searchBooks(value); },
                    ),
                    const SizedBox(height: 16.0),
                    CustomTextField(
                      hintText: 'Password',
                      obscureText: true,
                      onChanged: (value) {
                        searchBooks(value);
                      },
                    ),
                    const SizedBox(height: 24.0),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const HomePage(isGuest: false,),
                          ),
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
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => Signup(),
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
