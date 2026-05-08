// ============================================================
// app_router.dart — All navigation routes defined here
// ============================================================
// GoRouter handles navigation in our app.
//
// Route Structure:
//   /           → SplashScreen (checks auth, redirects)
//   /login      → LoginScreen
//   /register   → RegisterScreen
//   /shell      → MainShell (bottom nav container)
//     ├── Home tab         → HomeScreen
//     ├── Appointments tab → AppointmentsScreen
//     └── Profile tab      → ProfileScreen
//
// KEY CONCEPTS:
//   • GoRoute         — a single route (one URL = one screen)
//   • ShellRoute — a shell with multiple tabs
//   • GoRoute — each tab in the shell
//
// ============================================================

import 'package:go_router/go_router.dart';
import 'package:mini_project/features/auth/services/auth_service.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/home/screens/appointments_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../shared/main_shell.dart';
import '../constants/app_constants.dart';

/// The global GoRouter instance used by MaterialApp.router.
/// This defines ALL the routes in the app.
final GoRouter appRouter = GoRouter(
  // The initial route when the app starts
  initialLocation: AppConstants.splashPath,

  // ── Redirect Logic ──
  // This runs BEFORE every navigation to check conditions.
  redirect: (context, state) {
    final loc = state.uri.toString();

    bool isLoggedIn = AuthService.isLoggedIn();
    final isAuthRoute = loc == '/login' || loc == '/register';

    if (!isLoggedIn && !isAuthRoute) return '/login';
    if (isLoggedIn && isAuthRoute) return '/home';

    // No redirect needed — continue to the requested route
    return null;
  },

  // List of all routes
  routes: [
    // ── Splash Screen ──
    // The first screen shown. It checks if the user is logged in
    // and redirects to /shell or /login accordingly.
    GoRoute(
      path: AppConstants.splashPath,
      builder: (context, state) => const SplashScreen(),
    ),

    // ── Login Screen ──
    GoRoute(
      path: AppConstants.loginPath,
      builder: (context, state) => const LoginScreen(),
    ),

    // ── Register Screen ──
    GoRoute(
      path: AppConstants.registerPath,
      builder: (context, state) => const RegisterScreen(),
    ),

    // ── Main Shell (Bottom Navigation) ──
    ShellRoute(
      // The builder wraps all tabs inside our MainShell widget
      builder: (context, state, child) => MainShell(child: child),

      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),

        GoRoute(
          path: '/appointments',
          builder: (context, state) => const AppointmentsScreen(),
        ),

        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
);
