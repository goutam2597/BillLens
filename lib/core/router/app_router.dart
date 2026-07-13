import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'app_routes.dart';
import 'main_shell.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/expenses/presentation/pages/expense_list_page.dart';
import '../../features/expenses/presentation/pages/expense_details_page.dart';
import 'package:billlens/features/expenses/presentation/pages/add_expense_page.dart';
import 'package:billlens/features/expenses/domain/entities/expense.dart';
import '../../features/receipt_scanner/presentation/pages/receipt_scanner_page.dart';
import '../../features/receipt_scanner/presentation/pages/receipt_crop_page.dart';
import '../../features/receipt_scanner/presentation/pages/ai_processing_page.dart';
import '../../features/receipt_scanner/presentation/pages/receipt_result_page.dart';
import '../../features/categories/presentation/pages/categories_page.dart';
import '../../features/analytics/presentation/pages/analytics_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/subscription/presentation/pages/subscription_page.dart';
import '../../features/subscription/presentation/pages/checkout_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/change_password_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/sync/presentation/pages/sync_status_page.dart';
import '../../features/help_support/presentation/pages/help_support_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Public paths accessible without authentication
const _publicPaths = [
  '/',
  '/onboarding',
  '/login',
  '/register',
  '/otp',
  '/forgot-password',
];

// Secure storage for token checks
final _secureStorage = FlutterSecureStorage();

Future<bool> _isAuthenticated() async {
  final token = await _secureStorage.read(key: 'auth_token');
  return token != null && token.isNotEmpty;
}

Future<bool> _onboardingComplete() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('onboarding_complete') ?? false;
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) async {
      final location = state.uri.toString();
      final isPublic = _publicPaths.any((p) => location == p);
      final isGoingToSplash = location == AppRoutes.splash || location == '/';

      // Always allow splash
      if (isGoingToSplash) return null;

      // Check onboarding
      final onboardingDone = await _onboardingComplete();

      // If not completed onboarding and not on onboarding/welcome/auth paths
      if (!onboardingDone) {
        if (location != AppRoutes.onboarding &&
            location != AppRoutes.login &&
            location != AppRoutes.register &&
            location != AppRoutes.otp) {
          return AppRoutes.onboarding;
        }
        return null;
      }

      // Check auth
      final authenticated = await _isAuthenticated();

      if (!authenticated && !isPublic) {
        return AppRoutes.login;
      }

      if (authenticated && isPublic) {
        return AppRoutes.dashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        name: 'otp',
        builder: (context, state) => const OtpPage(),
      ),

      // Main tab shell: Home, Expenses, Analytics, Profile.
      StatefulShellRoute.indexedStack(
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                name: 'dashboard',
                builder: (context, state) => const DashboardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.expenseList,
                name: 'expenseList',
                builder: (context, state) => const ExpenseListPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.analytics,
                name: 'analytics',
                builder: (context, state) => const AnalyticsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: 'profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
      ),

      GoRoute(
        path: '/expenses/add',
        name: 'addExpense',
        builder: (context, state) =>
            AddExpensePage(expense: state.extra as Expense?),
      ),
      GoRoute(
        path: '/expenses/:id/edit',
        name: 'editExpense',
        builder: (context, state) =>
            AddExpensePage(expense: state.extra as Expense?),
      ),
      GoRoute(
        path: '/expenses/:id',
        name: 'expenseDetails',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ExpenseDetailsPage(expenseId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.receiptScanner,
        name: 'receiptScanner',
        builder: (context, state) => const ReceiptScannerPage(),
      ),
      GoRoute(
        path: AppRoutes.receiptCrop,
        name: 'receiptCrop',
        builder: (context, state) {
          final imagePath = state.extra as String?;
          return ReceiptCropPage(imagePath: imagePath);
        },
      ),
      GoRoute(
        path: AppRoutes.aiProcessing,
        name: 'aiProcessing',
        builder: (context, state) {
          final imagePath = state.extra as String? ?? '';
          return AiProcessingPage(imagePath: imagePath);
        },
      ),
      GoRoute(
        path: AppRoutes.receiptResult,
        name: 'receiptResult',
        builder: (context, state) {
          final data = state.extra;
          return ReceiptResultPage(processingResult: data);
        },
      ),
      GoRoute(
        path: AppRoutes.categories,
        name: 'categories',
        builder: (context, state) => const CategoriesPage(),
      ),
      GoRoute(
        path: AppRoutes.reports,
        name: 'reports',
        builder: (context, state) => const ReportsPage(),
      ),
      GoRoute(
        path: AppRoutes.subscription,
        name: 'subscription',
        builder: (context, state) => const SubscriptionPage(),
      ),
      GoRoute(
        path: AppRoutes.subscriptionCheckout,
        name: 'subscriptionCheckout',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return CheckoutPage(
            planId: extra?['planId'] as String? ?? 'premium',
            isYearly: extra?['isYearly'] as bool? ?? false,
            price: extra?['price'] as double? ?? 9.99,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        name: 'editProfile',
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.changePassword,
        name: 'changePassword',
        builder: (context, state) => const ChangePasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.syncStatus,
        name: 'syncStatus',
        builder: (context, state) => const SyncStatusPage(),
      ),
      GoRoute(
        path: AppRoutes.helpSupport,
        name: 'helpSupport',
        builder: (context, state) => const HelpSupportPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.uri}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.dashboard),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
