import 'package:book_store/create_account.dart';
import 'package:book_store/custom_field.dart';
import 'package:flutter/material.dart';

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
                    Image.asset("assets/images/images.jpeg"),
                    const SizedBox(
                      height: 24.0,
                    ),
                    const CustomTextField(
                      hintText: "Name",
                      obscureText: false,
                      icon2: Icon(Icons.person_2_outlined),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const CustomTextField(
                      hintText: "Username",
                      obscureText: false,
                      icon2: Icon(Icons.person),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const CustomTextField(
                      hintText: "email",
                      obscureText: false,
                      icon2: Icon(Icons.email_outlined),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    CustomTextField(
                      hintText: "Password",
                      obscureText: isobscure,
                      icon2: Icon(Icons.lock),
                      icon: IconButton(
                          onPressed: togglepass,
                          icon: Icon(isobscure == true
                              ? Icons.visibility_off
                              : Icons.visibility)),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 30),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const CreateAccount(),
                          ));
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
                    ),
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
