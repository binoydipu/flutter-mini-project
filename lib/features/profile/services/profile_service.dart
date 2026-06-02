import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mini_project/core/services/storage_service.dart';
import 'package:mini_project/features/auth/services/auth_service.dart';
import '../../../main.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/user_model.dart';

/// AuthService — a simple class that wraps Supabase auth methods.
/// All methods are static, so you don't need to create an instance.
/// Just call: AuthService.signInWithEmail(...)
class ProfileService {
  // Private constructor — we only use static methods
  ProfileService._();

  // ──────────────────────────────────────────────
  // GET USER PROFILE FROM DATABASE
  // ──────────────────────────────────────────────

  /// Fetches the user's profile from the "profiles" table.
  /// Returns a [UserModel] object instead of a raw Map.
  /// Returns null if no profile is found.
  static Future<UserModel?> getUserProfile() async {
    final user = AuthService.getCurrentUser();

    // If no user is logged in, return null
    if (user == null) return null;

    try {
      // Query the profiles table where id matches the user's id
      final response = await supabase
          .from(AppConstants.profilesTable)
          .select()
          .eq('id', user.id)
          .maybeSingle(); // Returns null if no row found (instead of throwing)

      // Convert the raw Map into a typed UserModel
      if (response != null) {
        return UserModel.fromMap(response);
      }
      return null;
    } catch (e) {
      // Log the error for debugging
      debugPrint('Error fetching profile: $e');
      return null;
    }
  }

  // ──────────────────────────────────────────────
  // UPDATE USER PROFILE IN DATABASE
  // ──────────────────────────────────────────────

  /// Updates the user's profile in the "profiles" table.
  /// Currently only updates the full name.
  static Future<void> updateUserProfile({
    required String fullName,
    File? avatarFile,
  }) async {
    final user = AuthService.getCurrentUser();
    if (user == null) throw Exception('No user logged in.');

    String? avatarUrl;

    if (avatarFile != null) {
      final publicId = '${user.id}_${DateTime.now().millisecondsSinceEpoch}';
      final uploadedUrl = await StorageService.uploadImage(
        file: avatarFile,
        publicId: publicId,
        folder: 'avatars',
      );
      avatarUrl = uploadedUrl;
    }

    final updatedProfile = {'full_name': fullName, 'avatar_url': avatarUrl};

    await supabase
        .from(AppConstants.profilesTable)
        .update(updatedProfile)
        .eq('id', user.id);
  }
}
