// ============================================================
// profile_screen.dart — User profile & logout
// ============================================================
// Shows the logged-in user's information:
//   • Name
//   • Email
//   • Role
//
// Also has a Logout button that signs the user out
// and sends them back to the Login screen.
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/user_model.dart';
import '../../auth/services/auth_service.dart';

/// ProfileScreen — shows user info and logout button.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // User profile from Supabase as a typed model
  UserModel? _profile;
  bool _isLoading = true;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  /// Loads the user's profile from Supabase.
  Future<void> _loadProfile() async {
    final profile = await AuthService.getUserProfile();
    if (mounted) {
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    }
  }

  /// Signs the user out and navigates to the Login screen.
  Future<void> _handleLogout() async {
    // Show a confirmation dialog before logging out
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    // If user confirmed logout
    if (shouldLogout == true) {
      setState(() => _isLoggingOut = true);

      try {
        // Call Supabase sign out
        await AuthService.signOut();

        // Navigate to login screen (replace the entire navigation stack)
        if (mounted) context.go('/login');
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: ${e.toString()}'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
          setState(() => _isLoggingOut = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final result = await context.push('/profile/update');
              if (result == true) {
                // Refresh profile if it was updated
                setState(() => _isLoading = true);
                _loadProfile();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // ── Profile Avatar ──
                  _buildAvatar(),
                  const SizedBox(height: 32),

                  // ── Profile Info Cards ──
                  _buildInfoCard(
                    icon: Icons.person_outline,
                    label: 'Full Name',
                    value: _profile?.fullName ?? 'Not set',
                  ),
                  const SizedBox(height: 12),

                  _buildInfoCard(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: _profile?.email.isNotEmpty == true
                        ? _profile!.email
                        : AuthService.getCurrentUser()?.email ?? 'Not set',
                  ),
                  const SizedBox(height: 12),

                  _buildInfoCard(
                    icon: Icons.badge_outlined,
                    label: 'Role',
                    value: _profile?.role ?? 'Not set',
                  ),
                  const SizedBox(height: 12),

                  _buildInfoCard(
                    icon: Icons.calendar_today_outlined,
                    label: 'Member Since',
                    value: _profile?.formattedCreatedAt ?? 'Unknown',
                  ),
                  const SizedBox(height: 32),

                  // ── Logout Button ──
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: _isLoggingOut ? null : _handleLogout,
                      icon: _isLoggingOut
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.logout_rounded),
                      label: Text(_isLoggingOut ? 'Logging out...' : 'Logout'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.errorColor,
                        side: const BorderSide(color: AppTheme.errorColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ──────────────────────────────────────────────
  // HELPER WIDGETS
  // ──────────────────────────────────────────────

  /// Builds the profile avatar with the user's initial.
  Widget _buildAvatar() {
    // Use the helper getter from UserModel for the initial
    final initial = _profile?.initial ?? 'U';
    final role = _profile?.role ?? 'User';

    return Column(
      children: [
        // Circular avatar with the user's first initial
        CircleAvatar(
          radius: 50,
          backgroundColor: AppTheme.primaryColor,
          child: Text(
            initial,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Name
        Text(
          _profile?.fullName ?? 'User',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),

        // Role badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            role,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds a single info row card.
  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 16),

          // Label & value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
