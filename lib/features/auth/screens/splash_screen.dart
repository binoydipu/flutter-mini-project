// ============================================================
// splash_screen.dart — The first screen users see
// ============================================================
// This screen shows briefly while the app checks if the user
// is already logged in.
//
// Flow:
//   App starts → Splash Screen → checks auth state
//     → If logged in   → go to /home
//     → If not logged in → go to /login
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../services/auth_service.dart';

/// SplashScreen — shown while checking authentication status.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Check auth status after the widget is built
    _checkAuthAndNavigate();
  }

  /// Checks if the user is logged in and navigates accordingly.
  Future<void> _checkAuthAndNavigate() async {
    // Wait a moment so the splash screen is visible
    // (also gives Supabase time to restore the session)
    await Future.delayed(const Duration(seconds: 1));

    // Don't navigate if the widget was disposed (user left the screen)
    if (!mounted) return;

    // Check if a user is currently logged in
    if (AuthService.isLoggedIn()) {
      // User IS logged in → go to home
      context.go('/home');
    } else {
      // User is NOT logged in → go to login screen
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Full-screen centered content
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.local_hospital_rounded,
                size: 48,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),

            // App name
            const Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            // Tagline
            const Text(
              AppConstants.appTagline,
              style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 48),

            // Loading spinner
            SpinKitFadingCircle(color: AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }
}
