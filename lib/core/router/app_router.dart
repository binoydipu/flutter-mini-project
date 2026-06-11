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
import 'package:mini_project/core/models/hospital_model.dart';
import 'package:mini_project/core/models/doctor_model.dart';
import 'package:mini_project/features/admin/screens/edit_hospital_screen.dart';
import 'package:mini_project/features/ai/screens/chat_screen.dart';
import 'package:mini_project/features/auth/services/auth_service.dart';
import 'package:mini_project/features/healthcare/screens/emergency_screen.dart';
import 'package:mini_project/features/healthcare/screens/hospital_details_screen.dart';
import 'package:mini_project/features/healthcare/screens/nearest_hospitals_screen.dart';
import 'package:mini_project/features/healthcare/screens/search_doctors_screen.dart';
import 'package:mini_project/features/profile/services/profile_service.dart';
import 'package:mini_project/features/remainder/screens/add_remainder_screen.dart';
import 'package:mini_project/features/remainder/screens/remainder_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/home/screens/appointments_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/update_profile_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/admin/screens/add_doctor_screen.dart';
import '../../features/admin/screens/edit_doctor_screen.dart';
import '../../features/admin/screens/add_hospital_screen.dart';
import '../../features/admin/screens/add_speciality_screen.dart';
import '../../features/admin/screens/add_symptom_screen.dart';
import '../../features/healthcare/screens/doctors_screen.dart';
import '../../features/healthcare/screens/doctor_details_screen.dart';
import '../../features/healthcare/screens/hospitals_screen.dart';
import '../../shared/main_shell.dart';

/// The global GoRouter instance used by MaterialApp.router.
/// This defines ALL the routes in the app.
final GoRouter appRouter = GoRouter(
  // The initial route when the app starts
  initialLocation: '/',

  // ── Redirect Logic ──
  // This runs BEFORE every navigation to check conditions.
  redirect: (context, state) {
    final loc = state.uri.toString();

    bool isLoggedIn = AuthService.isLoggedIn();
    final isAuthRoute = loc == '/login' || loc == '/register';
    final isAdminRoute = loc.startsWith('/admin');

    if (!isLoggedIn && !isAuthRoute) return '/login';
    if (isLoggedIn && isAuthRoute) return '/home';

    ProfileService.isAdmin().then((isAdmin) {
      if (isLoggedIn && isAdminRoute && !isAdmin) return '/home';
    });

    // No redirect needed — continue to the requested route
    return null;
  },

  // List of all routes
  routes: [
    // ── Splash Screen ──
    // The first screen shown. It checks if the user is logged in
    // and redirects to /shell or /login accordingly.
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),

    // ── Login Screen ──
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

    // ── Register Screen ──
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),

    // ── Admin Routes ──
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: '/admin/add-doctor',
      builder: (context, state) => const AddDoctorScreen(),
    ),
    GoRoute(
      path: '/admin/edit-doctor',
      builder: (context, state) {
        final doctor = state.extra as DoctorModel;
        return EditDoctorScreen(doctor: doctor);
      },
    ),
    GoRoute(
      path: '/admin/edit-hospital',
      builder: (context, state) {
        final hospital = state.extra as HospitalModel;
        return EditHospitalScreen(hospital: hospital);
      },
    ),
    GoRoute(
      path: '/admin/add-hospital',
      builder: (context, state) => const AddHospitalScreen(),
    ),
    GoRoute(
      path: '/admin/add-speciality',
      builder: (context, state) => const AddSpecialityScreen(),
    ),
    GoRoute(
      path: '/admin/add-symptom',
      builder: (context, state) => const AddSymptomScreen(),
    ),

    // ── Healthcare Routes ──
    GoRoute(
      path: '/doctors',
      builder: (context, state) => const DoctorsScreen(),
    ),
    GoRoute(
      path: '/doctors/:id',
      builder: (context, state) {
        final doctor = state.extra as DoctorModel;
        return DoctorDetailsScreen(doctor: doctor);
      },
    ),
    GoRoute(
      path: '/hospitals',
      builder: (context, state) => const HospitalsScreen(),
    ),
    GoRoute(
      path: '/hospitals/:id',
      builder: (context, state) {
        final hospital = state.extra as HospitalModel;
        return HospitalDetailsScreen(hospital: hospital);

        // final hospitalId = state.pathParameters['id'];
        // another way is to get hospital id from path parameters:
        // and then fetch hospital details inside HospitalDetailsScreen using that id.
        // But since we already have the hospital object when navigating,
        // we can pass it via state.extra to avoid an extra fetch.
      },
    ),

    // ── Main Shell (Bottom Navigation) ──
    ShellRoute(
      // The builder wraps all tabs inside our MainShell widget
      builder: (context, state, child) => MainShell(child: child),

      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),

        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchDoctorsScreen(),
        ),

        GoRoute(
          path: '/remainder',
          builder: (context, state) => const RemainderScreen(),
        ),

        GoRoute(
          path: '/chat',
          builder: (context, state) => const ChatScreen(),
        ),
        
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),

    // ── Profile Routes ──
    GoRoute(
      path: '/profile/update',
      builder: (context, state) => const UpdateProfileScreen(),
    ),
    GoRoute(
      path: '/emergency',
      builder: (context, state) => const EmergencyScreen(),
    ),
    GoRoute(
      path: '/nearest-hospitals',
      builder: (context, state) => const NearestHospitalsScreen(),
    ),
    GoRoute(
      path: '/add-remainder',
      builder: (context, state) => const AddRemainderScreen(),
    ),
  ],
);
