# BillLens — Completion Plan

## What's Done vs What's Left

### ✅ FULLY DONE (auth + expenses)
- Auth: BLoC, events, states, domain layer (entity, repo interface, use cases), data layer (model, local/remote datasources, repo impl), DI wiring, pages wired
- Expenses: Same — all 3 BLoCs, domain, data, DI, 3 pages wired to BLoCs

### 🔴 REMAINING — 10 feature shells + backend

Every remaining feature has only `presentation/pages/` with a static UI page. No BLoC, no data layer, no domain layer, no DI registration. The backend doesn't exist at all.

---

## Phase 1: Remaining BLoCs (Events + States + BLoC classes)

Follow the exact same pattern as `auth_bloc.dart` (events extend Equatable, states extend Equatable, BLoC handles all events).

### 1. SplashBloc — ALREADY WRITTEN ✅
- `features/splash/presentation/bloc/splash_event.dart` ✅
- `features/splash/presentation/bloc/splash_state.dart` ✅
- `features/splash/presentation/bloc/splash_bloc.dart` ✅
- Depends on: `AuthRepository`, `LocalStorageService`
- Events: AppStarted, CheckAuthStatus, CheckOnboardingStatus
- States: SplashInitial, SplashLoading, SplashAuthenticated, SplashUnauthenticated, SplashFirstTimeUser

### 2. OnboardingCubit — ALREADY WRITTEN ✅
- `features/onboarding/presentation/cubit/onboarding_cubit.dart` ✅
- Depends on: `LocalStorageService`
- Single method: `completeOnboarding()` → sets shared pref

### 3. OtpBloc — ALREADY WRITTEN ✅
- `features/auth/presentation/bloc/otp_event.dart` ✅
- `features/auth/presentation/bloc/otp_state.dart` ✅
- `features/auth/presentation/bloc/otp_bloc.dart` ✅
- Depends on: `AuthRepository` (needs `verifyOtp` + `resendOtp` methods added)

### 4. DashboardBloc — NEEDS TO BE WRITTEN
- `features/dashboard/presentation/bloc/dashboard_event.dart`
- `features/dashboard/presentation/bloc/dashboard_state.dart`
- `features/dashboard/presentation/bloc/dashboard_bloc.dart`
- Events: LoadDashboardData, LoadRecentExpenses, CheckSyncStatus
- States: DashboardInitial, DashboardLoading, DashboardLoaded(summary, recentExpenses, syncStatus), DashboardError
- Depends on: `ExpenseRepository` (to load recent expenses + total), `SyncRepository` (for sync status)

### 5. CategoryBloc — NEEDS TO BE WRITTEN
- `features/categories/presentation/bloc/category_event.dart`
- `features/categories/presentation/bloc/category_state.dart`
- `features/categories/presentation/bloc/category_bloc.dart`
- Events: LoadCategories, AddCategory(name, type, icon, color), UpdateCategory(category), DeleteCategory(id)
- Depends on: `CategoryRepository` (full CRUD)

### 6. ReceiptScannerBloc — NEEDS TO BE WRITTEN
- `features/receipt_scanner/presentation/bloc/receipt_scanner_event.dart`
- `features/receipt_scanner/presentation/bloc/receipt_scanner_state.dart`
- `features/receipt_scanner/presentation/bloc/receipt_scanner_bloc.dart`
- Events: InitializeCamera, CaptureReceipt, PickReceiptFromGallery, ToggleFlash
- States: ScannerInitial, ScannerReady, ScannerCapturing, ScannerImageCaptured(imagePath), ScannerError

### 7. ReceiptProcessingBloc — NEEDS TO BE WRITTEN
- `features/receipt_scanner/presentation/bloc/receipt_processing_event.dart`
- `features/receipt_scanner/presentation/bloc/receipt_processing_state.dart`
- `features/receipt_scanner/presentation/bloc/receipt_processing_bloc.dart`
- Events: StartReceiptProcessing(imagePath), RunOcrExtraction, RunAiCategorization
- States: ProcessingInitial, ProcessingLoading, OcrCompleted(data), AiCategorizationCompleted, ProcessingSuccess(expense), ProcessingError
- Depends on: `ReceiptRepository` (OCR + AI calls)

### 8. AnalyticsBloc — NEEDS TO BE WRITTEN
- `features/analytics/presentation/bloc/analytics_event.dart`
- `features/analytics/presentation/bloc/analytics_state.dart`
- `features/analytics/presentation/bloc/analytics_bloc.dart`
- Events: LoadAnalytics, ChangeAnalyticsDateRange(range)
- States: AnalyticsInitial, AnalyticsLoading, AnalyticsLoaded(monthlyStats, categoryDistribution, weeklyTrend, businessVsPersonal), AnalyticsError
- Depends on: `AnalyticsRepository`

### 9. ReportsBloc — NEEDS TO BE WRITTEN
- `features/reports/presentation/bloc/reports_event.dart`
- `features/reports/presentation/bloc/reports_state.dart`
- `features/reports/presentation/bloc/reports_bloc.dart`
- Events: GenerateReport(type, dateRange), ExportPdfReport, ExportCsvReport
- States: ReportsInitial, ReportsGenerating, ReportsGenerated(reportData), ReportsExported(path), ReportsError
- Depends on: `ReportsRepository`

### 10. SubscriptionBloc — NEEDS TO BE WRITTEN
- `features/subscription/presentation/bloc/subscription_event.dart`
- `features/subscription/presentation/bloc/subscription_state.dart`
- `features/subscription/presentation/bloc/subscription_bloc.dart`
- Events: LoadPlans, PurchasePlan(planId), RestorePurchase, VerifySubscription
- States: SubscriptionInitial, SubscriptionLoading, SubscriptionLoaded(plans, currentPlan), SubscriptionPurchased, SubscriptionError
- Depends on: `SubscriptionRepository`

### 11. ProfileBloc — NEEDS TO BE WRITTEN
- `features/profile/presentation/bloc/profile_event.dart`
- `features/profile/presentation/bloc/profile_state.dart`
- `features/profile/presentation/bloc/profile_bloc.dart`
- Events: LoadProfile, UpdateProfile(user), LogoutRequested, DeleteAccountRequested
- States: ProfileInitial, ProfileLoading, ProfileLoaded(user, subscriptionStatus), ProfileUpdated, ProfileError
- Depends on: `AuthRepository`, `UserRepository`

### 12. SettingsBloc — NEEDS TO BE WRITTEN
- `features/settings/presentation/bloc/settings_event.dart`
- `features/settings/presentation/bloc/settings_state.dart`
- `features/settings/presentation/bloc/settings_bloc.dart`
- Events: LoadSettings, UpdateTheme(mode), UpdateCurrency(currency), UpdateNotificationSettings(enabled), UpdateLanguage(language)
- States: SettingsInitial, SettingsLoaded(theme, currency, notificationsEnabled, language), SettingsUpdated, SettingsError
- Depends on: `LocalStorageService`

### 13. SyncBloc — NEEDS TO BE WRITTEN
- `features/sync/presentation/bloc/sync_event.dart`
- `features/sync/presentation/bloc/sync_state.dart`
- `features/sync/presentation/bloc/sync_bloc.dart`
- Events: LoadSyncStatus, StartManualSync, RetryFailedSync, AutoSyncStarted
- States: SyncInitial, SyncIdle, SyncInProgress, SyncCompleted(offlineCount, pendingCount, lastSyncTime), SyncFailed
- Depends on: `SyncRepository`

### 14. AdsBloc — NEEDS TO BE WRITTEN
- `features/ads/presentation/bloc/ads_event.dart`
- `features/ads/presentation/bloc/ads_state.dart`
- `features/ads/presentation/bloc/ads_bloc.dart`
- Events: LoadAds, ShowBannerAd, ShowNativeAd, ShowRewardedAd, HideAds
- States: AdsInitial, AdsLoaded, AdsHidden, AdsError

---

## Phase 2: Domain Layers (Repository Interfaces + Use Cases)

Each feature needs its repository interface under `domain/repositories/` and use cases under `domain/usecases/`.

### Categories
- `features/categories/domain/repositories/category_repository.dart` → abstract, methods: getCategories(), getBusinessCategories(), getPersonalCategories(), addCategory(..), updateCategory(..), deleteCategory(id)
- `features/categories/domain/usecases/get_categories_usecase.dart`
- `features/categories/domain/usecases/add_category_usecase.dart`
- `features/categories/domain/usecases/update_category_usecase.dart`
- `features/categories/domain/usecases/delete_category_usecase.dart`
- Already exists: `features/categories/domain/entities/category.dart` ✅

### Receipt Scanner
- `features/receipt_scanner/domain/entities/receipt_data.dart` → fields: vendor, amount, date, category, confidence, explanation, imagePath
- `features/receipt_scanner/domain/repositories/receipt_repository.dart` → abstract, methods: processReceipt(imagePath) returns ReceiptData, saveReceiptImage(imagePath)
- `features/receipt_scanner/domain/usecases/process_receipt_usecase.dart`
- `features/receipt_scanner/domain/usecases/save_receipt_image_usecase.dart`

### Dashboard
- `features/dashboard/domain/repositories/dashboard_repository.dart` → abstract, methods: getMonthlySummary(), getRecentExpenses(limit)
- `features/dashboard/domain/usecases/get_dashboard_data_usecase.dart`

### Analytics
- `features/analytics/domain/repositories/analytics_repository.dart` → abstract, methods: getMonthlyStats(), getCategoryDistribution(), getWeeklyTrend(), getBusinessVsPersonal()
- `features/analytics/domain/usecases/get_analytics_usecase.dart`

### Reports
- `features/reports/domain/repositories/reports_repository.dart` → abstract, methods: generateReport(type, range), exportPdf(data), exportCsv(data)
- `features/reports/domain/usecases/generate_report_usecase.dart`
- `features/reports/domain/usecases/export_report_usecase.dart`

### Subscription
- `features/subscription/domain/entities/plan.dart` → fields: id, name, price, features[], scanLimit
- `features/subscription/domain/repositories/subscription_repository.dart` → abstract, methods: getPlans(), getCurrentSubscription(), purchasePlan(planId), restorePurchase()
- `features/subscription/domain/usecases/get_plans_usecase.dart`
- `features/subscription/domain/usecases/purchase_plan_usecase.dart`

### Sync
- `features/sync/domain/entities/sync_status.dart` → fields: offlineExpenses, pendingSync, failedSync, lastSyncTime
- `features/sync/domain/repositories/sync_repository.dart` → abstract, methods: getSyncStatus(), syncNow(), retryFailed(), getPendingItems()
- `features/sync/domain/usecases/sync_data_usecase.dart`
- `features/sync/domain/usecases/get_sync_status_usecase.dart`

### Ads
- `features/ads/domain/repositories/ads_repository.dart` → abstract, methods: shouldShowAds(), loadBannerAd(), loadNativeAd(), loadRewardedAd()
- Already minimal — AdsBloc can work directly without complex domain layer since ads are mostly UI-level.

---

## Phase 3: Data Layers (Models + Datasources + Repo Impls)

Each feature needs: Model class (extends entity), LocalDataSource, RemoteDataSource (mock OK), RepositoryImpl.

### Categories Data Layer
- `features/categories/data/models/category_model.dart` → extends Category entity, adds fromJson/toJson, fromEntity, copyWithModel
- `features/categories/data/datasources/category_local_data_source.dart` → Drift CRUD using the `Categories` table (already in tables.dart)
- `features/categories/data/datasources/category_remote_data_source.dart` → Mock Dio calls to /api/categories
- `features/categories/data/repositories/category_repository_impl.dart` → offline-first: save local, try remote sync

### Receipt Scanner Data Layer
- `features/receipt_scanner/data/models/receipt_data_model.dart`
- `features/receipt_scanner/data/datasources/receipt_remote_data_source.dart` → POST /api/ai/process-receipt (OCR + AI), POST /api/upload-receipt
- `features/receipt_scanner/data/repositories/receipt_repository_impl.dart` → process locally if offline, remote if online

### Dashboard Data Layer
- `features/dashboard/data/datasources/dashboard_local_data_source.dart` → queries Expenses table for summary + recent items
- `features/dashboard/data/repositories/dashboard_repository_impl.dart` → reads from ExpenseLocalDataSource (reuse existing)

### Analytics Data Layer
- `features/analytics/data/datasources/analytics_local_data_source.dart` → aggregate queries on Expenses table
- `features/analytics/data/repositories/analytics_repository_impl.dart`

### Reports Data Layer
- `features/reports/data/datasources/reports_local_data_source.dart` → queries data, generates PDF/CSV using `pdf` and `csv` packages
- `features/reports/data/repositories/reports_repository_impl.dart`

### Subscription Data Layer
- `features/subscription/data/models/plan_model.dart`
- `features/subscription/data/datasources/subscription_remote_data_source.dart` → GET /api/plans, GET /api/subscription/status, POST /api/subscribe
- `features/subscription/data/repositories/subscription_repository_impl.dart`

### Sync Data Layer
- `features/sync/data/datasources/sync_local_data_source.dart` → queries sync_queue table, pending counts
- `features/sync/data/datasources/sync_remote_data_source.dart` → POST /api/sync/upload, GET /api/sync/download
- `features/sync/data/repositories/sync_repository_impl.dart` → batch upload/download with conflict resolution

### ConnectivityService
- `features/sync/data/services/connectivity_service.dart` → wraps `connectivity_plus`, streams connectivity changes, triggers auto-sync

---

## Phase 4: DI Registration (injection.dart)

Add manual registrations in `lib/core/di/injection.dart` for every new BLoC, repository, datasource, and use case. Follow the existing pattern:
```dart
if (!getIt.isRegistered<CategoryBloc>()) {
  getIt.registerFactory<CategoryBloc>(
    () => CategoryBloc(
      getCategoriesUseCase: getIt<GetCategoriesUseCase>(),
      addCategoryUseCase: getIt<AddCategoryUseCase>(),
      updateCategoryUseCase: getIt<UpdateCategoryUseCase>(),
      deleteCategoryUseCase: getIt<DeleteCategoryUseCase>(),
    ),
  );
}
```

Services to register:
- `ConnectivityService` as lazySingleton
- `SyncRepository` as lazySingleton
- All new BLoCs as factories

---

## Phase 5: PHP/MySQL Backend

Create `backend/` at project root with this structure:

### Config
- `backend/config/database.php` → PDO connection to MySQL (host, db, user, pass from env)
- `backend/config/jwt.php` → JWT secret key, token expiry
- `backend/config/app.php` → APP_URL, UPLOAD_DIR, ALLOWED_TYPES, MAX_FILE_SIZE

### Middleware
- `backend/middleware/cors_middleware.php` → Allow Origin, Methods, Headers
- `backend/middleware/auth_middleware.php` → Verify JWT from Authorization header, return 401 if invalid

### Controllers (each handles routing, input validation, calls service, returns JSON)
- `AuthController.php` → register, login, logout, verifyOtp, resendOtp, resetPassword
- `UserController.php` → getProfile, updateProfile, deleteAccount
- `ExpenseController.php` → index(search/filter/sort), store, show, update, destroy
- `CategoryController.php` → index, store, update, destroy
- `ReceiptController.php` → upload (store file, return URL)
- `SyncController.php` → upload (batch), download (since timestamp)
- `AiController.php` → processReceipt (OCR + AI categorization)
- `SubscriptionController.php` → getPlans, subscribe, verifyPayment, getStatus

### Models (each wraps PDO/mysqli for its table)
- `User.php` → CRUD, findByEmail, create, update
- `Expense.php` → CRUD with user_id filter, search, date range filter
- `Category.php` → CRUD with user_id filter
- `Receipt.php` → CRUD with user_id
- `Subscription.php` → findByUser, create, update
- `Payment.php` → create, findByTransaction
- `SyncLog.php` → log sync events

### Services
- `JwtService.php` → generateToken(user), validateToken(token), decodePayload(token)
- `UploadService.php` → store(file, folder), delete(path), validateType/Size
- `OcrService.php` → call external OCR API, extract vendor/amount/date
- `AiService.php` → call OpenAI/Gemini for categorization
- `SyncService.php` → batchProcess(uploadData), getChangesSince(timestamp), conflictResolution
- `PaymentService.php` → verify with gateway, update subscription

### Database
- `backend/database/schema.sql` → CREATE TABLE statements for all 8 tables:
  - users (id, name, email, password_hash, business_name, currency, subscription_status, email_verified_at, created_at, updated_at)
  - categories (id, user_id, local_id, name, type, icon, color, created_at, updated_at, deleted_at)
  - expenses (id, user_id, local_id, vendor, amount, currency, category_id, date, payment_method, client_name, project_name, notes, receipt_image, ai_confidence, ai_explanation, created_at, updated_at, deleted_at)
  - receipts (id, user_id, expense_id, image_url, local_path, ocr_text, ai_result, created_at)
  - subscriptions (id, user_id, plan_name, status, start_date, end_date, payment_gateway, created_at, updated_at)
  - payments (id, user_id, subscription_id, amount, currency, gateway, transaction_id, status, created_at)
  - sync_logs (id, user_id, action, table_name, record_id, status, error_message, created_at)
  - notifications (id, user_id, title, message, type, is_read, created_at)

### Router / Entry
- `backend/.htaccess` → RewriteEngine On, route all to index.php
- `backend/index.php` → Parse URI, instantiate controller, call method, return JSON

### API Endpoints Summary
| Method | Endpoint | Controller |
|--------|----------|-----------|
| POST | /api/register | AuthController::register |
| POST | /api/login | AuthController::login |
| POST | /api/logout | AuthController::logout |
| POST | /api/verify-otp | AuthController::verifyOtp |
| POST | /api/resend-otp | AuthController::resendOtp |
| POST | /api/reset-password | AuthController::resetPassword |
| GET | /api/profile | UserController::getProfile |
| PUT | /api/profile | UserController::updateProfile |
| DELETE | /api/delete-account | UserController::deleteAccount |
| GET | /api/expenses | ExpenseController::index |
| POST | /api/expenses | ExpenseController::store |
| GET | /api/expenses/{id} | ExpenseController::show |
| PUT | /api/expenses/{id} | ExpenseController::update |
| DELETE | /api/expenses/{id} | ExpenseController::destroy |
| GET | /api/categories | CategoryController::index |
| POST | /api/categories | CategoryController::store |
| PUT | /api/categories/{id} | CategoryController::update |
| DELETE | /api/categories/{id} | CategoryController::destroy |
| POST | /api/upload-receipt | ReceiptController::upload |
| POST | /api/ai/process-receipt | AiController::processReceipt |
| POST | /api/sync/upload | SyncController::upload |
| GET | /api/sync/download | SyncController::download |
| GET | /api/plans | SubscriptionController::getPlans |
| POST | /api/subscribe | SubscriptionController::subscribe |
| POST | /api/payment/verify | SubscriptionController::verifyPayment |
| GET | /api/subscription/status | SubscriptionController::getStatus |

---

## Phase 6: Router Updates + Auth Guard + Screen 25

### 6a. Screen 25 — Help & Support
- `features/help_support/presentation/pages/help_support_page.dart` → FAQ section (ExpansionTile), Contact Support button, Privacy Policy link, Terms of Service link, App Version display
- Route: `/help` → already defined in `app_routes.dart` as `helpSupport`
- Wire in `app_router.dart`: add GoRoute for `/help` → HelpSupportPage

### 6b. Auth Guard
- Add `redirect` callback on GoRouter in `app_router.dart`:
  - Check if token exists (via AuthRepository or FlutterSecureStorage)
  - If unauthenticated and trying to access protected routes → redirect to welcome
  - If authenticated and accessing auth routes → redirect to dashboard

### 6c. Page-to-BLoC Wiring
- DashboardPage → wrap with BlocProvider<DashboardBloc>, dispatch LoadDashboardData on init
- CategoriesPage → wrap with BlocProvider<CategoryBloc>, dispatch LoadCategories on init
- ReceiptScannerPage → wrap with BlocProvider<ReceiptScannerBloc>
- AiProcessingPage → wrap with BlocProvider<ReceiptProcessingBloc>
- ReceiptResultPage → wire to ReceiptProcessingBloc results
- AnalyticsPage → wrap with BlocProvider<AnalyticsBloc>
- ReportsPage → wrap with BlocProvider<ReportsBloc>
- SubscriptionPage → wrap with BlocProvider<SubscriptionBloc>
- ProfilePage → wrap with BlocProvider<ProfileBloc>
- SettingsPage → wrap with BlocProvider<SettingsBloc>
- SyncStatusPage → wrap with BlocProvider<SyncBloc>

### 6d. Main App Wiring
- In `app.dart`: provide all global BLoCs at the MaterialApp.router level
- In `main.dart`: initialize Hive (if not done), register connectivity stream

---

## Phase 7: Receipt Scanner + AI Flow Completion

### Image Cropper
- Wire `image_cropper` in `ReceiptCropPage`: use `ImageCropper().cropImage(sourcePath: imagePath)` → pass cropped path to AI Processing page

### AI Processing
- `ReceiptProcessingBloc` handles the flow:
  1. Compress image (`flutter_image_compress`)
  2. If online → POST to /api/ai/process-receipt
  3. If offline → save image locally, mark expense as pending, allow manual entry
- `AiProcessingPage` listens to bloc states and shows step-by-step progress
- On success → navigate to ReceiptResultPage with extracted data

### Receipt Result
- `ReceiptResultPage` receives extracted data, shows fields (vendor, amount, date, category, confidence)
- "Save Expense" → dispatches CreateExpense event to ExpenseFormBloc
- "Edit" → navigates to AddExpensePage with pre-filled data

---

## Phase 8: Sync System Complete

### ConnectivityService
- Streams network status changes
- When online → triggers auto-sync via SyncBloc
- When offline → saves to local only, adds to sync_queue

### Sync Flow
1. App starts → check pending sync items
2. Network becomes available → start sync
3. Batch upload: send all pending expense/category creates/updates/deletes
4. Batch download: get all server changes since last_sync_time
5. Conflict resolution: server wins if server.updated_at > local.updated_at
6. Update sync_status on all synced records to 'synced'

---

## Phase 9: Ads + Subscription Complete

### AdsBloc Logic
- Check subscription status on app start
- If free user → show ads (banner on dashboard, native every 5 items in list, rewarded for AI insights)
- If premium user → never show ads
- Use Google AdMob ad unit IDs (test IDs for development)

### SubscriptionBloc Logic
- Load plans from backend
- Current subscription from local preferences + remote verification
- Purchase flow integrates with in-app purchase / Stripe

---

## File Creation Order (Recommended)

### Batch 1: Domain Layer (Interfaces)
1. CategoryRepository interface
2. ReceiptRepository interface
3. DashboardRepository interface
4. AnalyticsRepository interface
5. ReportsRepository interface
6. SubscriptionRepository interface
7. SyncRepository interface
8. AdsRepository interface (optional)
9. ReceiptData entity
10. Plan entity
11. SyncStatus entity
12. All use cases for each repository

### Batch 2: Data Layer
13. CategoryModel
14. CategoryLocalDataSource (Drift)
15. CategoryRemoteDataSource (Dio mock)
16. CategoryRepositoryImpl
17. ReceiptDataModel
18. ReceiptRemoteDataSource
19. ReceiptRepositoryImpl
20. DashboardRepositoryImpl (reuses ExpenseLocalDataSource)
21. AnalyticsRepositoryImpl
22. ReportsRepositoryImpl
23. PlanModel
24. SubscriptionRemoteDataSource
25. SubscriptionRepositoryImpl
26. SyncLocalDataSource
27. SyncRemoteDataSource
28. SyncRepositoryImpl
29. ConnectivityService

### Batch 3: BLoCs
30. DashboardEvent, DashboardState, DashboardBloc
31. CategoryEvent, CategoryState, CategoryBloc
32. ReceiptScannerEvent, ReceiptScannerState, ReceiptScannerBloc
33. ReceiptProcessingEvent, ReceiptProcessingState, ReceiptProcessingBloc
34. AnalyticsEvent, AnalyticsState, AnalyticsBloc
35. ReportsEvent, ReportsState, ReportsBloc
36. SubscriptionEvent, SubscriptionState, SubscriptionBloc
37. ProfileEvent, ProfileState, ProfileBloc
38. SettingsEvent, SettingsState, SettingsBloc
39. SyncEvent, SyncState, SyncBloc
40. AdsEvent, AdsState, AdsBloc

### Batch 4: DI + Router + Pages
41. Update injection.dart with all registrations
42. Add auth guard to app_router.dart
43. Build HelpSupportPage
44. Wire all pages to their BLoCs
45. Update app.dart with global BLoC providers

### Batch 5: Backend
46-75. All backend files as listed in Phase 5

---

## Verification

After implementation, run:
- `flutter analyze` → should show no errors
- `flutter build apk --debug` → should compile
- Test screens navigate correctly
- Test BLoCs with flutter_bloc_test (optional)
