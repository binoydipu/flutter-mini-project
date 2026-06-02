// ============================================================
// auth_service.dart — All authentication logic in one place
// ============================================================
// This file handles ALL communication with Supabase Auth.
//
// WHY separate this from the UI?
//   → So our screens stay clean (only UI code)
//   → So we can reuse auth logic anywhere
//   → So students can easily find auth-related code
//
// Methods included:
//   • initializeGoogleSignIn() — Must call once at app startup
//   • signUpWithEmail()   — Register a new user
//   • signInWithEmail()   — Login an existing user
//   • signInWithGoogle()  — Login/Register via Google
//   • signOut()           — Logout from Supabase + Google
//   • saveProfile()       — Save user profile to database
//   • getCurrentUser()    — Get the logged-in user
//   • getUserProfile()    — Fetch profile as UserModel
// ============================================================

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../main.dart'; // For the global `supabase` variable
import '../../../core/constants/app_constants.dart';

/// AuthService — a simple class that wraps Supabase auth methods.
/// All methods are static, so you don't need to create an instance.
/// Just call: AuthService.signInWithEmail(...)
class AuthService {
  // Private constructor — we only use static methods
  AuthService._();

  // ──────────────────────────────────────────────
  // EMAIL/PASSWORD SIGN UP (Register)
  // ──────────────────────────────────────────────

  /// Registers a new user with email & password.
  /// After successful signup, we also save their profile data.
  ///
  /// [email]    — the user's email address
  /// [password] — the user's chosen password
  /// [fullName] — the user's display name
  /// [role]     — either "Doctor" or "User"
  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    // Step 1: Create the user account in Supabase Auth
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    // Step 2: If signup was successful, save extra info in the profiles table
    if (response.user != null) {
      await saveProfile(
        userId: response.user!.id,
        fullName: fullName,
        email: email,
        role: role,
      );
    }

    return response;
  }

  // ──────────────────────────────────────────────
  // EMAIL/PASSWORD SIGN IN (Login)
  // ──────────────────────────────────────────────

  /// Logs in a user with their email and password.
  /// Returns the auth response which contains the session.
  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    // This calls Supabase to verify the email + password
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    return response;
  }

  // ──────────────────────────────────────────────
  // GOOGLE SIGN-IN INITIALIZATION (v7 — must call once)
  // ──────────────────────────────────────────────

  /// Initializes the Google Sign-In plugin.
  ///
  /// IMPORTANT (google_sign_in v7 change):
  ///   In v7, GoogleSignIn is a singleton (GoogleSignIn.instance).
  ///   You MUST call initialize() exactly once before using
  ///   authenticate() or disconnect().
  ///
  /// Call this from main.dart during app startup.
  static Future<void> initializeGoogleSignIn() async {
    final webClientId = dotenv.env['WEB_CLIENT_ID']!;
    final androidClientId = dotenv.env['ANDROID_CLIENT_ID']!;

    await GoogleSignIn.instance.initialize(
      // clientId is the platform-specific client ID (Android/iOS)
      clientId: androidClientId,
      // serverClientId is the Web client ID — required to get the idToken
      serverClientId: webClientId,
    );
  }

  // ──────────────────────────────────────────────
  // GOOGLE OAUTH SIGN IN
  // ──────────────────────────────────────────────

  /// Signs in with Google using the native Google Sign-In flow.
  ///
  /// After Google sign-in, we check if the user already has a profile.
  /// If not, a profile will need to be created (handled by the caller).
  static Future<AuthResponse> signInWithGoogle() async {
    // Step 1: Trigger the Google account picker using authenticate()
    // In v7, authenticate() replaces the old signIn() method.
    // It shows the Google account selection sheet to the user.
    final googleAccount = await GoogleSignIn.instance.authenticate();

    // Step 2: Get the authentication tokens from the signed-in account
    // .authentication gives us the idToken and accessToken
    final googleAuth = googleAccount.authentication;
    final idToken = googleAuth.idToken;

    // The idToken is required for Supabase authentication
    if (idToken == null) {
      throw Exception('No ID token found from Google.');
    }
    final authorization =
        await googleAccount.authorizationClient.authorizationForScopes([
          'email',
          'profile',
        ]) ??
        await googleAccount.authorizationClient.authorizeScopes([
          'email',
          'profile',
        ]);

    final accessToken = authorization.accessToken;

    // Step 3: Use the Google tokens to sign in with Supabase
    // This creates or links the user in Supabase Auth
    final response = await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    return response;
  }

  // ──────────────────────────────────────────────
  // SIGN OUT (Logout from Supabase + Google)
  // ──────────────────────────────────────────────

  /// Signs out the current user from BOTH Supabase and Google.
  ///
  /// Why disconnect from Google too?
  ///   → disconnect() (v7) fully clears the cached Google account,
  ///     so the user gets a fresh account picker next time.
  ///   → In v6, this was GoogleSignIn().signOut().
  ///     In v7, use GoogleSignIn.instance.disconnect().
  static Future<void> signOut() async {
    // Step 1: Disconnect from Google (clears the cached Google account)
    try {
      await GoogleSignIn.instance.signOut();
    } catch (e) {
      // It's okay if this fails — the user might not have used Google
      debugPrint('Google disconnect skipped: $e');
    }

    // Step 2: Sign out from Supabase (clears the auth session)
    await supabase.auth.signOut();
  }

  // ──────────────────────────────────────────────
  // SAVE PROFILE TO DATABASE
  // ──────────────────────────────────────────────

  /// Saves user profile data to the "profiles" table in Supabase.
  ///
  /// We use "upsert" which means:
  ///   → INSERT if the row doesn't exist
  ///   → UPDATE if the row already exists
  ///
  /// This is useful for Google sign-in where the user might already exist.
  static Future<void> saveProfile({
    required String userId,
    required String fullName,
    required String email,
    required String role,
  }) async {
    // NOTE: We don't set created_at or updated_at here.
    //   → created_at has a DEFAULT in the database (set on first insert)
    //   → updated_at is set by a Supabase trigger on every update
    await supabase.from(AppConstants.profilesTable).upsert({
      'id': userId,
      'full_name': fullName,
      'email': email,
      'role': role,
    });
  }

  // ──────────────────────────────────────────────
  // GET CURRENT USER
  // ──────────────────────────────────────────────

  /// Returns the currently logged-in user, or null if not logged in.
  /// This is a synchronous check — it reads from the local session.
  static User? getCurrentUser() {
    return supabase.auth.currentUser;
  }

  /// Returns true if a user is currently logged in.
  static bool isLoggedIn() {
    return supabase.auth.currentSession != null;
  }
}
