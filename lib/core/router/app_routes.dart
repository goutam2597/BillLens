class AppRoutes {
  // Auth
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String otp = '/otp';
  static const String forgotPassword = '/forgot-password';

  // Main
  static const String dashboard = '/dashboard';
  static const String expenseList = '/expenses';
  static const String expenseDetails = '/expenses/:id';
  static const String addExpense = '/expenses/add';
  static const String editExpense = '/expenses/:id/edit';

  // Scanner
  static const String receiptScanner = '/scanner';
  static const String receiptCrop = '/scanner/crop';
  static const String aiProcessing = '/scanner/processing';
  static const String receiptResult = '/scanner/result';

  // Categories
  static const String categories = '/categories';

  // Analytics
  static const String analytics = '/analytics';
  static const String aiInsights = '/ai-insights';

  // Reports
  static const String reports = '/reports';

  // Subscription
  static const String subscription = '/subscription';

  // Profile & Settings
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String changePassword = '/profile/change-password';
  static const String settings = '/settings';

  // Sync
  static const String syncStatus = '/sync-status';

  // Support
  static const String helpSupport = '/help';
}
