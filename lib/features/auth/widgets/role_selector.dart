// ============================================================
// role_selector.dart — Doctor / User role picker
// ============================================================
// A simple radio-button group that lets the user choose
// their role during registration.
//
// We use Radio<String> widgets — each one represents a choice.
// ============================================================

import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

/// A widget that displays two radio buttons: "Doctor" and "User".
///
/// [selectedRole]   — the currently selected role
/// [onRoleChanged]  — called when the user picks a different role
class RoleSelector extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String> onRoleChanged;

  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        const Text(
          'Select your role',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),

        // Container with rounded border
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.dividerColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // ── Doctor Radio Button ──
              RadioListTile<String>(
                title: const Row(
                  children: [
                    Icon(Icons.medical_services_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('Doctor'),
                  ],
                ),
                value: AppConstants.roleDoctor,
                groupValue: selectedRole,
                onChanged: (value) {
                  if (value != null) onRoleChanged(value);
                },
                // Remove extra padding
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                visualDensity: VisualDensity.compact,
              ),

              // Divider between the two options
              const Divider(height: 1),

              // ── User Radio Button ──
              RadioListTile<String>(
                title: const Row(
                  children: [
                    Icon(Icons.person_outline, size: 20),
                    SizedBox(width: 8),
                    Text('User'),
                  ],
                ),
                value: AppConstants.roleUser,
                groupValue: selectedRole,
                onChanged: (value) {
                  if (value != null) onRoleChanged(value);
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
