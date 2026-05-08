// ============================================================
// custom_text_field.dart — Reusable text input widget
// ============================================================
// Instead of writing TextField code over and over in each screen,
// we create ONE reusable widget and use it everywhere.
//
// This keeps our screens short and consistent.
// ============================================================

import 'package:flutter/material.dart';

/// A styled text field that we use across all auth screens.
///
/// Usage:
/// ```dart
/// CustomTextField(
///   controller: emailController,
///   label: 'Email',
///   hint: 'Enter your email',
///   prefixIcon: Icons.email_outlined,
///   keyboardType: TextInputType.emailAddress,
///   validator: validateEmail,
/// )
/// ```
class CustomTextField extends StatelessWidget {
  // The controller manages the text value inside the field
  final TextEditingController controller;

  // Label text shown above the field when focused
  final String label;

  // Hint text shown inside the field when empty
  final String hint;

  // Icon shown at the start of the field (optional)
  final IconData? prefixIcon;

  // What type of keyboard to show (email, number, text, etc.)
  final TextInputType keyboardType;

  // Whether to hide the text (for passwords)
  final bool obscureText;

  // Validation function — returns error message or null
  final String? Function(String?)? validator;

  // Widget shown at the end of the field (e.g., show/hide password button)
  final Widget? suffixIcon;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      // Connect the controller so we can read the value later
      controller: controller,

      // Set the keyboard type (email keyboard has @ symbol, etc.)
      keyboardType: keyboardType,

      // Hide text if this is a password field
      obscureText: obscureText,

      // Validation function called when form is submitted
      validator: validator,

      // Visual decoration of the field
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
