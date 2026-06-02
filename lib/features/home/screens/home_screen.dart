// ============================================================
// home_screen.dart — The main dashboard after login
// ============================================================
// This is the first thing users see after logging in.
// It shows:
//   • A welcome message with the user's name and role
//   • Quick action cards (Book Appointment, View Doctors, etc.)
//
// We fetch the user's profile from Supabase to show their name.
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mini_project/features/profile/services/profile_service.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/models/user_model.dart';

/// HomeScreen — the main dashboard tab.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // User profile loaded from Supabase as a typed model
  UserModel? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Load the user's profile when the screen appears
    _loadProfile();
  }

  /// Fetches the user's profile from the Supabase "profiles" table.
  Future<void> _loadProfile() async {
    final profile = await ProfileService.getUserProfile();
    if (mounted) {
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: _isLoading
          // Show a spinner while loading the profile
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              // Pull-to-refresh to reload profile data
              onRefresh: _loadProfile,
              child: SingleChildScrollView(
                // Always allow scrolling (needed for RefreshIndicator)
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Welcome Header ──
                    _buildWelcomeHeader(),
                    const SizedBox(height: 32),

                    // ── Quick Actions Title ──
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Action Cards Grid ──
                    _buildActionCards(),
                  ],
                ),
              ),
            ),
    );
  }

  // ──────────────────────────────────────────────
  // HELPER WIDGETS
  // ──────────────────────────────────────────────

  /// Builds the welcome card at the top with user info.
  Widget _buildWelcomeHeader() {
    // Get the user's name and role from the UserModel
    final fullName = _profile?.fullName ?? 'User';
    final role = _profile?.role ?? 'User';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // A gradient background for a modern look
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting text
          Text(
            'Welcome, $fullName 👋',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),

          // Role badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Role: $role',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Motivational text
          const Text(
            'Your health, simplified.',
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  /// Builds a grid of quick action cards.
  Widget _buildActionCards() {
    final actions = [
      _ActionItem(
        icon: Icons.calendar_month_rounded,
        title: 'Book\nAppointment',
        color: const Color(0xFF2563EB),
      ),
      _ActionItem(
        icon: Icons.people_rounded,
        title: 'View\nDoctors',
        color: const Color(0xFF7C3AED),
        route: '/doctors',
      ),
      _ActionItem(
        icon: Icons.local_hospital_rounded,
        title: 'Partner\nHospitals',
        color: const Color(0xFFEC4899),
        route: '/hospitals',
      ),
    ];

    if (_profile?.isAdmin == true) {
      actions.add(_ActionItem(
        icon: Icons.admin_panel_settings_rounded,
        title: 'Admin\nPanel',
        color: const Color(0xFF059669),
        route: '/admin',
      ));
    }

    // Build a 2-column grid
    return GridView.builder(
      // Disable GridView's own scrolling (parent handles it)
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 cards per row
        crossAxisSpacing: 16, // Horizontal gap
        mainAxisSpacing: 16, // Vertical gap
        childAspectRatio: 1.1, // Slightly wider than tall
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return _buildActionCard(action);
      },
    );
  }

  /// Builds a single action card.
  Widget _buildActionCard(_ActionItem action) {
    return Card(
      child: InkWell(
        // Rounded corners on the tap ripple
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (action.route != null) {
            context.push(action.route!);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${action.title.replaceAll('\n', ' ')} — Coming soon!',
                ),
                duration: const Duration(seconds: 1),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon with colored background
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: action.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(action.icon, color: action.color, size: 24),
              ),

              // Card title
              Text(
                action.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A simple data class for action card items.
/// We use an underscore prefix (_) to make it private to this file.
class _ActionItem {
  final IconData icon;
  final String title;
  final Color color;
  final String? route;

  _ActionItem({required this.icon, required this.title, required this.color, this.route});
}
