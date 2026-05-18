// ============================================================
// update_profile_screen.dart — Update user profile information
// ============================================================
// This screen allows the user to update their profile details.
// Features:
//   • Avatar UI (visual only)
//   • Full Name, Phone, Address, Blood Group fields
//   • Saves only Full Name to Supabase (others are UI only for now)
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/models/user_model.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/services/auth_validators.dart';
import '../../auth/widgets/custom_text_field.dart';

/// UpdateProfileScreen — allows users to update their details.
class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  // ── Form Key ──
  final _formKey = GlobalKey<FormState>();

  // ── Text Controllers ──
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _bloodGroupController = TextEditingController();

  // ── State Variables ──
  bool _isLoading = false;
  bool _isSaving = false;
  UserModel? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bloodGroupController.dispose();
    super.dispose();
  }

  /// Loads the user's profile from Supabase to pre-fill the form.
  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final profile = await AuthService.getUserProfile();

    if (mounted && profile != null) {
      setState(() {
        _profile = profile;
        _nameController.text = profile.fullName;
        _emailController.text = profile.email;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  /// Called when the user taps "Save Changes".
  Future<void> _handleSave() async {
    // Validate form fields
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // Save only the full name to Supabase
      await AuthService.updateUserProfile(
        fullName: _nameController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Go back to the previous screen
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Update failed: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Avatar Placeholder ──
                    Center(child: _buildAvatarEditor()),
                    const SizedBox(height: 32),

                    // ── Full Name ──
                    CustomTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      prefixIcon: Icons.person_outline,
                      validator: validateName,
                    ),
                    const SizedBox(height: 16),

                    // ── Email ──
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email (read-only)',
                      hint: 'Enter your email',
                      prefixIcon: Icons.email_outlined,
                      enabled: false,
                    ),
                    const SizedBox(height: 16),

                    // ── Phone Number ──
                    CustomTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      hint: 'Enter your phone number',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    // ── Address ──
                    CustomTextField(
                      controller: _addressController,
                      label: 'Address',
                      hint: 'Enter your address',
                      prefixIcon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 16),

                    // ── Blood Group ──
                    CustomTextField(
                      controller: _bloodGroupController,
                      label: 'Blood Group',
                      hint: 'e.g. O+, A-',
                      prefixIcon: Icons.bloodtype_outlined,
                    ),
                    const SizedBox(height: 32),

                    // ── Save Button ──
                    ElevatedButton(
                      onPressed: _isSaving ? null : _handleSave,
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // ──────────────────────────────────────────────
  // HELPER WIDGETS
  // ──────────────────────────────────────────────

  /// Builds a visual-only avatar editor widget.
  Widget _buildAvatarEditor() {
    final initial = _profile?.initial ?? 'U';

    return Stack(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
          child: Text(
            initial,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(
              Icons.camera_alt_outlined,
              size: 20,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
