// ============================================================
// appointments_screen.dart — Appointments tab placeholder
// ============================================================
// This screen is a placeholder for the Appointments feature.
// It shows a simple "Coming Soon" message.
//
// Students can build on this screen later to add:
//   • A list of upcoming appointments
//   • A booking form
//   • Calendar view
// ============================================================

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// AppointmentsScreen — placeholder for the appointments feature.
class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Appointments',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  size: 48,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                'No Appointments Yet',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              const Text(
                'Your upcoming appointments will appear here.\nBook an appointment from the Home tab.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Hint for students
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED), // Amber 50
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFED7AA),
                  ), // Amber 200
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Color(0xFFF59E0B), // Amber 500
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '💡 Students: Build the appointment booking feature here!',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF92400E), // Amber 800
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
