// ============================================================
// main.dart — Entry point of the Flutter app
// ============================================================
// This is the FIRST file Flutter runs when the app starts.
// Here we:
//   1. Load environment variables (.env file)
//   2. Initialize Supabase (our backend)
//   3. Initialize Google Sign-In
//   4. Launch the app with our custom theme & router
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:mini_project/features/remainder/services/remainder_service.dart';
import 'package:mini_project/features/remainder/services/remainder_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/services/auth_service.dart';

/// A global reference to the Supabase client.
/// We use this everywhere in the app to talk to Supabase.
/// Example: supabase.auth.signInWithPassword(...)
final supabase = Supabase.instance.client;

void main() async {
  // Ensure Flutter is fully initialized before doing async work
  WidgetsFlutterBinding.ensureInitialized();

  // ── Load the .env file ──
  // The .env file contains our Supabase URL and Anon Key.
  // We keep these in .env so they are NOT hardcoded in our source code.
  await dotenv.load(fileName: ".env");

  // ── Initialize Notifications Remainder ──
  // This sets up our local notification service and reschedules any pending notifications.
  final storage = RemainderStorage();
  final service = RemainderService(storage);

  await service.init();
  await service.rescheduleAll();

  // ── Initialize Supabase ──
  // This connects our app to the Supabase backend.
  // We read the URL and key from the .env file.
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // ── Initialize Google Sign-In ──
  await AuthService.initializeGoogleSignIn();

  // ── Initialize Gemini AI ──
  Gemini.init(apiKey: dotenv.env['GEMINI_API_KEY']!);

  // ── Run the app ──
  runApp(const MyApp());
}

/// The root widget of our application.
/// This sets up the theme and the router (navigation).
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // App title shown in task switcher / browser tab
      title: 'HealthCare Starter',

      // Remove the "DEBUG" banner in the top-right corner
      debugShowCheckedModeBanner: false,

      // Apply our custom light theme (defined in app_theme.dart)
      theme: AppTheme.lightTheme,

      // Use GoRouter for navigation (defined in app_router.dart)
      routerConfig: appRouter,
    );
  }
}
