// ============================================================
// admin_dashboard_screen.dart
// ============================================================
// Central menu for an admin to manage healthcare entities.
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAdminCard(
            context,
            title: 'Add Doctor',
            icon: Icons.person_add_rounded,
            color: AppTheme.primaryColor,
            route: '/admin/add-doctor',
          ),
          const SizedBox(height: 16),
          _buildAdminCard(
            context,
            title: 'Add Hospital',
            icon: Icons.local_hospital_rounded,
            color: AppTheme.secondaryColor,
            route: '/admin/add-hospital',
          ),
          const SizedBox(height: 16),
          _buildAdminCard(
            context,
            title: 'Add Speciality',
            icon: Icons.medical_services_rounded,
            color: const Color(0xFF059669),
            route: '/admin/add-speciality',
          ),
          const SizedBox(height: 16),
          _buildAdminCard(
            context,
            title: 'Add Symptom',
            icon: Icons.sick_rounded,
            color: const Color(0xFFEC4899),
            route: '/admin/add-symptom',
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: () => context.push(route),
      ),
    );
  }
}
