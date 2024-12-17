import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final Widget? icon;
  final Widget? icon2;
  final ValueChanged<String>? onChanged;
  final TextEditingController controller; // Corrected the type for onChanged

  const CustomTextField({
    super.key,
    required this.hintText,
    this.obscureText = false,
    this.icon,
    this.icon2,
    this.onChanged,
    required this.controller, // Made optional for flexibility
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4.0,
            spreadRadius: 1.0,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        onChanged: onChanged, // Assign the passed callback here
        decoration: InputDecoration(
          prefixIcon: icon2,
          suffixIcon: icon,
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
        ),
        style: const TextStyle(fontSize: 16.0),
      ),
    );
  }
}
