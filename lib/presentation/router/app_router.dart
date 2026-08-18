import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../splash/splash_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import '../auth/forgot_password_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../health_assistant/chat_screen.dart';
import '../emergency/sos_screen.dart';
import '../emergency/sos_history_screen.dart';
import '../fall_detection/fall_detection_screen.dart';
import '../medicine/medicine_list_screen.dart';
import '../medicine/add_medicine_screen.dart';
import '../contacts/contacts_screen.dart';
import '../contacts/add_contact_screen.dart';
import '../health_records/health_records_screen.dart';
import '../profile/profile_screen.dart';
import '../profile/edit_profile_screen.dart';

/// Route names for navigation
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
  static const String healthAssistant = '/health-assistant';
  static const String sos = '/sos';
  static const String sosHistory = '/sos-history';
  static const String fallDetection = '/fall-detection';
  static const String medicines = '/medicines';
  static const String addMedicine = '/add-medicine';
  static const String contacts = '/contacts';
  static const String addContact = '/add-contact';
  static const String healthRecords = '/health-records';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';

  // For tab-based navigation
  static const String dashboardTab = '/dashboard';
  static const String healthTab = '/health-assistant';
  static const String sosTab = '/sos';
  static const String profileTab = '/profile';
}

/// Application router configuration using GoRouter
class AppRouter {
  AppRouter._();

  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      debugLogDiagnostics: true,
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.onboarding,
          name: 'onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: AppRoutes.login,
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.register,
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: AppRoutes.forgotPassword,
          name: 'forgotPassword',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: AppRoutes.dashboard,
          name: 'dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: AppRoutes.healthAssistant,
          name: 'healthAssistant',
          builder: (context, state) => const ChatScreen(),
        ),
        GoRoute(
          path: AppRoutes.sos,
          name: 'sos',
          builder: (context, state) => const SOSScreen(),
        ),
        GoRoute(
          path: AppRoutes.sosHistory,
          name: 'sosHistory',
          builder: (context, state) => const SosHistoryScreen(),
        ),
        GoRoute(
          path: AppRoutes.fallDetection,
          name: 'fallDetection',
          builder: (context, state) => const FallDetectionScreen(),
        ),
        GoRoute(
          path: AppRoutes.medicines,
          name: 'medicines',
          builder: (context, state) => const MedicineListScreen(),
        ),
        GoRoute(
          path: AppRoutes.addMedicine,
          name: 'addMedicine',
          builder: (context, state) => const AddMedicineScreen(),
        ),
        GoRoute(
          path: AppRoutes.contacts,
          name: 'contacts',
          builder: (context, state) => const ContactsScreen(),
        ),
        GoRoute(
          path: AppRoutes.addContact,
          name: 'addContact',
          builder: (context, state) => const AddContactScreen(),
        ),
        GoRoute(
          path: AppRoutes.healthRecords,
          name: 'healthRecords',
          builder: (context, state) => const HealthRecordsScreen(),
        ),
        GoRoute(
          path: AppRoutes.profile,
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: AppRoutes.editProfile,
          name: 'editProfile',
          builder: (context, state) => const EditProfileScreen(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Page not found: ${state.uri}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.dashboard),
                child: const Text('Go to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
