// ============================================================
// app_theme.dart — App-wide theme configuration
// ============================================================
// This file defines how our app LOOKS — colors, text styles,
// button shapes, input field styles, etc.
//
// We use Material 3 (the latest Material Design) for a modern look.
// ============================================================

import 'package:flutter/material.dart';

/// AppTheme holds our app's visual design as a ThemeData object.
/// We keep it in a separate file to keep main.dart clean.
class AppTheme {
  // Private constructor — no one should create an instance of this class.
  AppTheme._();

  // ── Color Palette ──
  // These are the main colors used throughout the app.
  static const Color primaryColor = Color(0xFF2563EB); // Blue 600
  static const Color secondaryColor = Color(0xFF7C3AED); // Violet 600
  static const Color surfaceColor = Color(0xFFF8FAFC); // Slate 50
  static const Color backgroundColor = Colors.white;
  static const Color errorColor = Color(0xFFDC2626); // Red 600
  static const Color textPrimary = Color(0xFF1E293B); // Slate 800
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color dividerColor = Color(0xFFE2E8F0); // Slate 200

  /// The light theme used by our app.
  static ThemeData get lightTheme {
    return ThemeData(
      // Enable Material 3 for modern look & feel
      useMaterial3: true,

      // Set the color scheme from our primary color
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        surface: surfaceColor,
        error: errorColor,
      ),

      // Scaffold (page background) color
      scaffoldBackgroundColor: backgroundColor,

      // ── AppBar Style ──
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textPrimary,
        elevation: 0, // Flat, no shadow
        centerTitle: true,
      ),

      // ── Elevated Button Style ──
      // Used for primary actions like "Login", "Register"
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52), // Full-width, 52px tall
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Outlined Button Style ──
      // Used for secondary actions like "Continue with Google"
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: dividerColor, width: 1.5),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // ── Text Button Style ──
      // Used for links like "Don't have an account? Register"
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Input Decoration (TextField) Style ──
      // Used for email, password, name fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        hintStyle: const TextStyle(color: textSecondary, fontSize: 14),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
      ),

      // ── Card Style ──
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: dividerColor),
        ),
      ),

      // ── Bottom Navigation Bar Style ──
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: primaryColor.withValues(alpha: 0.1),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textSecondary,
          );
        }),
      ),
    );
  }
}
