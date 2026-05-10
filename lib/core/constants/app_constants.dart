// ============================================================
// app_constants.dart — App-wide constant values
// ============================================================
// Store all fixed values here so they can be reused.
// If you need to change a value, you change it in ONE place.
// ============================================================

/// AppConstants holds static strings and values used across the app.
class AppConstants {
  // Private constructor — prevents creating instances
  AppConstants._();

  // ── App Info ──
  static const String appName = 'HealthCare Starter';
  static const String appTagline = 'Your health, simplified.';

  // ── User Roles ──
  // Users pick one of these roles during registration.
  static const String roleDoctor = 'Doctor';
  static const String roleUser = 'User';

  // ── Admin Role ──
  // This role is not selectable by users. It's assigned manually in the database.
  static const String roleAdmin = 'Admin';

  // ── Supabase Table Names ──
  // The name of our profiles table in Supabase.
  static const String profilesTable = 'profiles';

  // ── Validation Rules ──
  static const int passwordMinLength = 6;

  // ── Route Paths ──
  // Centralized route paths so we don't use raw strings everywhere.
  static const String splashPath = '/';
  static const String loginPath = '/login';
  static const String registerPath = '/register';
  static const String homePath = '/home';
  static const String appointmentsPath = '/appointments';
  static const String profilePath = '/profile';
}
