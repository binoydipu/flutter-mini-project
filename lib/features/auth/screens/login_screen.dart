// ============================================================
// login_screen.dart — Email/Password & Google login
// ============================================================
// This screen lets users log into their existing account.
//
// Features:
//   • Email + Password text fields with validation
//   • "Login" button for email/password auth
//   • "Continue with Google" button for OAuth
//   • Link to Register screen for new users
//   • Loading state while auth is in progress
//   • Error messages shown via SnackBar
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/auth_validators.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/google_sign_in_button.dart';

/// LoginScreen — where existing users sign in.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ── Form Key ──
  // Used to validate all text fields at once when the user taps "Login"
  final _formKey = GlobalKey<FormState>();

  // ── Text Controllers ──
  // These hold the current text inside each text field.
  // We read from them when the user taps "Login".
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // ── State Variables ──
  bool _isLoading = false; // Shows a spinner on the Login button
  bool _isGoogleLoading = false; // Shows a spinner on Google button
  bool _obscurePassword = true; // Whether to hide the password text

  @override
  void dispose() {
    // IMPORTANT: Always dispose controllers to free memory
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────────
  // EMAIL/PASSWORD LOGIN
  // ──────────────────────────────────────────────

  /// Called when the user taps the "Login" button.
  Future<void> _handleEmailLogin() async {
    // Step 1: Validate the form (runs all validator functions)
    if (!_formKey.currentState!.validate()) return;

    // Step 2: Show loading spinner
    setState(() => _isLoading = true);

    try {
      // Step 3: Call Supabase to sign in
      await AuthService.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Step 4: Navigate to the main app on success
      if (mounted) context.go(AppConstants.homePath);
    } catch (e) {
      // Step 5: Show error message if login fails
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      // Step 6: Hide loading spinner
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ──────────────────────────────────────────────
  // GOOGLE SIGN IN
  // ──────────────────────────────────────────────

  /// Called when the user taps "Continue with Google".
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);

    try {
      // Call Google sign-in through our auth service
      final response = await AuthService.signInWithGoogle();

      // Check if the user has a profile already
      // (first-time Google users won't have one)
      if (response.user != null) {
        final profile = await AuthService.getUserProfile();

        // If no profile exists, create one with Google's info
        if (profile == null) {
          await AuthService.saveProfile(
            userId: response.user!.id,
            fullName:
                response.user!.userMetadata?['full_name'] ??
                response.user!.email ??
                'User',
            email: response.user!.email ?? '',
            role: AppConstants.roleUser, // Default role for Google sign-in
          );
        }
      }

      // Navigate to the main app
      if (mounted) context.go(AppConstants.homePath);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google sign-in failed: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  // ──────────────────────────────────────────────
  // BUILD THE UI
  // ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            // Padding around the entire form
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Header Section ──
                  _buildHeader(),
                  const SizedBox(height: 40),

                  // ── Email Field ──
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'Enter your email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: validateEmail,
                  ),
                  const SizedBox(height: 16),

                  // ── Password Field ──
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'Enter your password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    validator: (v) => validatePassword(v, isLogin: true),
                    // Toggle button to show/hide password
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Login Button ──
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleEmailLogin,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Login'),
                  ),
                  const SizedBox(height: 16),

                  // ── OR Divider ──
                  _buildDivider(),
                  const SizedBox(height: 16),

                  // ── Google Sign-In Button ──
                  GoogleSignInButton(
                    onPressed: _handleGoogleSignIn,
                    isLoading: _isGoogleLoading,
                  ),
                  const SizedBox(height: 24),

                  // ── Register Link ──
                  _buildRegisterLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // HELPER WIDGETS (kept in the same file for simplicity)
  // ──────────────────────────────────────────────

  /// Builds the top header with icon and title.
  Widget _buildHeader() {
    return Column(
      children: [
        // App icon
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.local_hospital_rounded,
            size: 36,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 20),

        // Title
        const Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),

        // Subtitle
        const Text(
          'Sign in to continue',
          style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  /// Builds the "── OR ──" divider between email login and Google login.
  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppTheme.dividerColor)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppTheme.dividerColor)),
      ],
    );
  }

  /// Builds the "Don't have an account? Register" link at the bottom.
  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account?",
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        TextButton(
          // Navigate to the Register screen
          onPressed: () => context.go(AppConstants.registerPath),
          child: const Text('Register'),
        ),
      ],
    );
  }
}
