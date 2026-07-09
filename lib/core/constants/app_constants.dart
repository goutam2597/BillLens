class AppConstants {
  // App Info
  static const String appName = 'BillLens';
  static const String appTagline = 'Smart Receipt Scanner';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String keyAuthToken = 'auth_token';
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyOnboardingDone = 'onboarding_done';
  static const String keyThemeMode = 'theme_mode';
  static const String keySelectedCurrency = 'selected_currency';
  static const String keyLanguage = 'language';
  static const String keyLastSyncTime = 'last_sync_time';
  static const String keySubscriptionStatus = 'subscription_status';
  static const String keyNotificationsEnabled = 'notifications_enabled';

  // Subscription Types
  static const String planFree = 'free';
  static const String planPremium = 'premium';

  // Sync Status Values
  static const String syncPending = 'pending';
  static const String syncSynced = 'synced';
  static const String syncFailed = 'failed';
  static const String syncConflict = 'conflict';
  static const String syncDeleted = 'deleted';

  // Payment Methods
  static const List<String> paymentMethods = [
    'Cash',
    'Credit Card',
    'Debit Card',
    'Bank Transfer',
    'Digital Wallet',
    'Check',
    'Other',
  ];

  // Default Business Categories
  static const List<Map<String, String>> defaultBusinessCategories = [
    {'name': 'Client Meeting', 'icon': '🤝', 'color': '2563EB'},
    {'name': 'Travel', 'icon': '✈️', 'color': '3B82F6'},
    {'name': 'Office Supplies', 'icon': '📎', 'color': 'F59E0B'},
    {'name': 'Software', 'icon': '💻', 'color': '8B5CF6'},
    {'name': 'Marketing', 'icon': '📣', 'color': 'EC4899'},
    {'name': 'Fuel', 'icon': '⛽', 'color': 'EF4444'},
    {'name': 'Meals', 'icon': '🍽️', 'color': 'F97316'},
    {'name': 'Internet', 'icon': '🌐', 'color': '06B6D4'},
    {'name': 'Utilities', 'icon': '💡', 'color': '84CC16'},
  ];

  // Default Personal Categories
  static const List<Map<String, String>> defaultPersonalCategories = [
    {'name': 'Food', 'icon': '🛒', 'color': '10B981'},
    {'name': 'Shopping', 'icon': '🛍️', 'color': 'EC4899'},
    {'name': 'Entertainment', 'icon': '🎬', 'color': '8B5CF6'},
    {'name': 'Health', 'icon': '🏥', 'color': 'EF4444'},
    {'name': 'Other', 'icon': '📦', 'color': '64748B'},
  ];

  // Currencies
  static const List<Map<String, String>> currencies = [
    {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar'},
    {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
    {'code': 'GBP', 'symbol': '£', 'name': 'British Pound'},
    {'code': 'INR', 'symbol': '₹', 'name': 'Indian Rupee'},
    {'code': 'BDT', 'symbol': '৳', 'name': 'Bangladeshi Taka'},
    {'code': 'AED', 'symbol': 'د.إ', 'name': 'UAE Dirham'},
    {'code': 'CAD', 'symbol': 'C\$', 'name': 'Canadian Dollar'},
    {'code': 'AUD', 'symbol': 'A\$', 'name': 'Australian Dollar'},
    {'code': 'JPY', 'symbol': '¥', 'name': 'Japanese Yen'},
    {'code': 'SGD', 'symbol': 'S\$', 'name': 'Singapore Dollar'},
  ];

  // Free Plan Limits
  static const int freeMonthlyScans = 10;
  static const int freeExpensesLimit = 50;

  // Image
  static const int maxImageSizeMb = 10;
  static const int receiptImageQuality = 85;

  // Sync
  static const int syncRetryMaxCount = 3;
  static const int syncIntervalSeconds = 30;

  // API Timeout
  static const int connectTimeoutSeconds = 30;
  static const int receiveTimeoutSeconds = 60;

  // Pagination
  static const int pageSize = 20;

  // Date Formats
  static const String dateFormat = 'dd MMM yyyy';
  static const String dateTimeFormat = 'dd MMM yyyy, hh:mm a';
  static const String apiDateFormat = 'yyyy-MM-dd';
  static const String apiDateTimeFormat = 'yyyy-MM-dd HH:mm:ss';

  // Category Types
  static const String categoryBusiness = 'business';
  static const String categoryPersonal = 'personal';

  // Dummy data for Phase 1 UI
  static const String dummyUserName = 'Goutam';
  static const String dummyBusinessName = 'GK Enterprises';
  static const String dummyCurrency = 'USD';
  static const String dummyMonthlyExpense = '\$2,450.00';
}
