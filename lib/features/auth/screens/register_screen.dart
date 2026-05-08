// ============================================================
// register_screen.dart — Create a new account
// ============================================================
// This screen lets new users create an account.
//
// Features:
//   • Full Name, Email, Password, Confirm Password fields
//   • Role selector (Doctor / User)
//   • "Register" button for email/password signup
//   • "Continue with Google" button for OAuth signup
//   • Link to Login screen for existing users
//   • Form validation with error messages
//   • Saves profile data to Supabase after signup
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/auth_validators.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/google_sign_in_button.dart';
import '../widgets/role_selector.dart';

/// RegisterScreen — where new users create their account.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // ── Form Key ──
  final _formKey = GlobalKey<FormState>();

  // ── Text Controllers ──
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // ── State Variables ──
  String _selectedRole = AppConstants.roleUser; // Default role is "User"
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    // Clean up controllers when the screen is destroyed
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────────
  // EMAIL/PASSWORD REGISTER
  // ──────────────────────────────────────────────

  /// Called when the user taps the "Register" button.
  Future<void> _handleEmailRegister() async {
    // Step 1: Validate all form fields
    if (!_formKey.currentState!.validate()) return;

    // Step 2: Show loading spinner
    setState(() => _isLoading = true);

    try {
      // Step 3: Create the account and save the profile
      await AuthService.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
        role: _selectedRole,
      );

      // Step 4: Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Registration successful! Please check your email to verify your account.',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to login so they can sign in
        // (Supabase may require email verification first)
        context.go(AppConstants.loginPath);
      }
    } catch (e) {
      // Step 5: Show error if registration fails
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.toString()}'),
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
  // GOOGLE SIGN UP
  // ──────────────────────────────────────────────

  /// Called when the user taps "Continue with Google" on the register screen.
  Future<void> _handleGoogleSignUp() async {
    setState(() => _isGoogleLoading = true);

    try {
      // Sign in with Google (creates account if first time)
      final response = await AuthService.signInWithGoogle();

      // Save profile with the selected role
      if (response.user != null) {
        await AuthService.saveProfile(
          userId: response.user!.id,
          fullName:
              response.user!.userMetadata?['full_name'] ??
              response.user!.email ??
              'User',
          email: response.user!.email ?? '',
          role: _selectedRole, // Use the role they selected on this screen
        );
      }

      // Navigate to the main app
      if (mounted) context.go(AppConstants.homePath);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google sign-up failed: ${e.toString()}'),
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
      // AppBar with back button
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go(AppConstants.loginPath),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ──
                _buildHeader(),
                const SizedBox(height: 32),

                // ── Full Name Field ──
                CustomTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  prefixIcon: Icons.person_outline,
                  validator: validateName,
                ),
                const SizedBox(height: 16),

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
                  hint: 'Create a password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  validator: validatePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(
                        () => _obscurePassword = !_obscurePassword,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // ── Confirm Password Field ──
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hint: 'Re-enter your password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscureConfirmPassword,
                  // Custom validator that checks against the password field
                  validator: (value) => validateConfirmPassword(
                    value,
                    _passwordController.text,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(
                        () => _obscureConfirmPassword =
                            !_obscureConfirmPassword,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // ── Role Selector ──
                RoleSelector(
                  selectedRole: _selectedRole,
                  onRoleChanged: (role) {
                    // Update the selected role when user picks one
                    setState(() => _selectedRole = role);
                  },
                ),
                const SizedBox(height: 24),

                // ── Register Button ──
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleEmailRegister,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Register'),
                ),
                const SizedBox(height: 16),

                // ── OR Divider ──
                _buildDivider(),
                const SizedBox(height: 16),

                // ── Google Sign-Up Button ──
                GoogleSignInButton(
                  onPressed: _handleGoogleSignUp,
                  isLoading: _isGoogleLoading,
                ),
                const SizedBox(height: 24),

                // ── Login Link ──
                _buildLoginLink(),

                // Extra bottom padding for scrolling
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // HELPER WIDGETS
  // ──────────────────────────────────────────────

  /// Header with title and subtitle.
  Widget _buildHeader() {
    return const Column(
      children: [
        Text(
          'Create Account',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Fill in your details to get started',
          style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  /// "── OR ──" divider.
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

  /// "Already have an account? Login" link.
  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an account?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        TextButton(
          // Navigate back to the Login screen
          onPressed: () => context.go(AppConstants.loginPath),
          child: const Text('Login'),
        ),
      ],
    );
  }
}
