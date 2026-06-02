// ============================================================
// user_model.dart — Data model for user profile
// ============================================================
// Instead of passing around Map<String, dynamic> everywhere,
// we use a proper Dart class. This gives us:
//
//   ✓ Type safety     — no typos in map keys like 'ful_name'
//   ✓ Auto-complete   — IDE shows all available fields
//   ✓ Readability     — user.fullName instead of map['full_name']
//   ✓ Documentation   — each field has a clear purpose
//
// KEY CONCEPTS:
//   • fromMap()  — creates a UserModel from a Supabase response (Map)
//   • toMao()    — converts a UserModel to a Map for Supabase inserts
// ============================================================

/// UserModel represents a user profile stored in the "profiles" table.
///
/// The Supabase "profiles" table has these columns:
///   id, full_name, email, role, created_at, updated_at
class UserModel {
  /// The user's unique ID (same as Supabase Auth user ID)
  final String id;

  /// The user's display name
  final String fullName;

  /// The user's email address
  final String email;

  /// The user's role — either "Admin", "Doctor" or "User"
  final String role;

  /// When the profile was first created
  final DateTime? createdAt;

  /// When the profile was last updated
  /// (automatically set by a Supabase database trigger)
  final DateTime? updatedAt;

  /// Constructor — creates a UserModel with all fields.
  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.createdAt,
    this.updatedAt,
  });

  // ──────────────────────────────────────────────
  // FROM MAP (Supabase → Dart)
  // ──────────────────────────────────────────────

  /// Creates a UserModel from a MAP (Supabase response).
  ///
  /// Example:
  /// ```dart
  /// final map = {'id': '123', 'full_name': 'John', ...};
  /// final user = UserModel.fromJson(map);
  /// ```
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      fullName: map['full_name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: map['role'] as String? ?? 'User',
      // Parse the date strings into DateTime objects
      // tryParse returns null if the string is invalid
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'] as String)
          : null,
    );
  }

  // ──────────────────────────────────────────────
  // TO MAP (Dart → Supabase)
  // ──────────────────────────────────────────────

  /// Converts this UserModel to a MAP for Supabase inserts/updates.
  ///
  /// NOTE: We don't include updated_at here because the
  /// Supabase trigger handles setting it automatically.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'role': role,
      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  // ──────────────────────────────────────────────
  // HELPER GETTERS
  // ──────────────────────────────────────────────

  /// Returns the first letter of the user's name (for avatars).
  String get initial => fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U';

  /// Returns true if the user is a doctor.
  bool get isDoctor => role == 'Doctor';

  /// Returns true if the user is an admin.
  bool get isAdmin => role == 'Admin';

  /// Returns a nicely formatted "Member Since" string.
  String get formattedCreatedAt => _formatDate(createdAt);

  /// Returns a nicely formatted "Last Updated" string.
  String get formattedUpdatedAt => _formatDate(updatedAt);

  /// Formats a DateTime into a readable string like "May 2, 2026".
  static String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  String toString() {
    return 'UserModel(id: $id, fullName: $fullName, email: $email, role: $role)';
  }
}
