// ============================================================
// auth_validators.dart — Form validation helpers
// ============================================================
// These functions check if user input is valid.
// We keep them separate so screens stay clean.
//
// Each function returns:
//   → null      if the input is valid
//   → a String  error message if the input is invalid
//
// This is the format Flutter's TextFormField expects.
// ============================================================

import 'package:mini_project/core/constants/app_constants.dart';

/// Validates an email address.
/// Returns null if valid, or an error message if invalid.
String? validateEmail(String? value) {
  // Check if empty
  if (value == null || value.trim().isEmpty) {
    return 'Please enter your email';
  }

  // Check email format using a simple regex pattern
  // This checks for: something@something.something
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(value.trim())) {
    return 'Please enter a valid email address';
  }

  return null; // Valid!
}

/// Validates a password.
/// Returns null if valid, or an error message if invalid.
/// If it is for Login then don't check length
String? validatePassword(String? value, {bool isLogin = false}) {
  // Check if empty
  if (value == null || value.isEmpty) {
    return 'Please enter your password';
  }

  // Check minimum length
  if (!isLogin && value.length < AppConstants.passwordMinLength) {
    return 'Password must be at least ${AppConstants.passwordMinLength} characters';
  }

  return null; // Valid!
}

/// Validates the confirm password field.
/// Checks that it matches the original password.
String? validateConfirmPassword(String? value, String password) {
  // Check if empty
  if (value == null || value.isEmpty) {
    return 'Please confirm your password';
  }

  // Check if passwords match
  if (value != password) {
    return 'Passwords do not match';
  }

  return null; // Valid!
}

/// Validates a name field.
/// Returns null if valid, or an error message if invalid.
String? validateName(String? value) {
  // Check if empty
  if (value == null || value.trim().isEmpty) {
    return 'Please enter your full name';
  }

  // Check minimum length (at least 2 characters for a name)
  if (value.trim().length < 2) {
    return 'Name must be at least 2 characters';
  }

  return null; // Valid!
}
