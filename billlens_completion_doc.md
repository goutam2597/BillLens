# BillLens — Project Completion Status

**App:** Smart Receipt Scanner AI App  
**Stack:** Flutter + BLoC + PHP/MySQL  
**As of:** July 10, 2026

---

## 📊 Overall Progress

| Phase | Description | Status | % Done |
|---|---|---|---|
| Phase 1 | Flutter UI Design (all screens) | ✅ **Complete** | 100% |
| Phase 2 | BLoC Architecture Setup | ✅ **Complete** | 100% |
| Phase 3 | Offline Database (Drift/SQLite) | ✅ **Complete** | 95% |
| Phase 4 | Receipt Scanner + OCR + AI Flow | 🟢 In Progress | 65% |
| Phase 5 | PHP/MySQL Backend | ✅ **Complete** | 100% |
| Phase 6 | Sync System | 🟢 In Progress | 60% |
| Phase 7 | Ads + Subscription | 🟢 In Progress | 50% |
| Phase 8 | Testing + Release | 🔴 Not Started | 0% |

---

## ✅ July 10, 2026 — Major Completion Update

All remaining BLoCs, domain layers, data layers, backend, and Screen 25 built. `dart analyze` passes with zero issues.

### New Files Built (60+ files)

#### BLoCs (14 new — all 14 now complete)
- `SplashBloc` — events, states, bloc with auth check + onboarding check
- `OnboardingCubit` — completes onboarding, saves to SharedPreferences
- `OtpBloc` — verify + resend OTP via AuthRepository
- `DashboardBloc` — loads monthly total, recent expenses, sync count from ExpenseRepository
- `CategoryBloc` — full CRUD via CategoryRepository, business/personal tabs
- `ReceiptScannerBloc` — camera init, capture, gallery pick, flash toggle via ImagePicker
- `ReceiptProcessingBloc` — step-by-step OCR → AI categorization with mock data flow
- `AnalyticsBloc` — weekly trend, category distribution, total spending from ExpenseRepository
- `ReportsBloc` — generate reports (monthly/tax/business), PDF/CSV export
- `SubscriptionBloc` — free/premium plans, purchase, restore via LocalStorageService
- `ProfileBloc` — load/update profile, logout, delete account via AuthRepository
- `SettingsBloc` — theme, currency, notifications, language via LocalStorageService
- `SyncBloc` — load status, manual sync, retry failed, auto-sync via ExpenseRepository
- `AdsBloc` — show/hide ads based on subscription status via LocalStorageService

#### Domain Layers
- `CategoryRepository` interface + 4 use cases (get, add, update, delete)
- `CategoryModel`, `CategoryLocalDataSource` (Drift), `CategoryRemoteDataSource` (mock Dio)
- `CategoryRepositoryImpl` (offline-first: local then try remote sync)

#### Data Layers
- `CategoryLocalDataSourceImpl` — full Drift CRUD against `categories` table
- `CategoryRemoteDataSourceImpl` — mock Dio client for `/api/categories`

#### Auth Updates
- `AuthRepository` now includes `verifyOtp()`, `resendOtp()`, `resetPassword()`
- `AuthRemoteDataSourceImpl` now handles all OTP endpoints

#### DI (injection.dart)
- All 14 new BLoCs registered as factories
- All new repositories, datasources, use cases registered as lazySingletons

#### Router (app_router.dart)
- **Auth guard** added: redirects unauthenticated users to welcome, authenticated users to dashboard
- **Onboarding guard**: first-time users see onboarding first
- Screen 25 (Help & Support) route registered

#### Screen 25 — Help & Support
- FAQ with 6 expandable items
- Email, Live Chat, Help Center contact cards
- Privacy Policy, Terms of Service, Refund Policy links
- App version and copyright footer

#### Full PHP/MySQL Backend (30+ files)
- `backend/config/` — database.php, jwt.php, app.php
- `backend/middleware/` — cors_middleware.php, auth_middleware.php
- `backend/services/` — JwtService, UploadService, OcrService, AiService, SyncService
- `backend/controllers/` — Auth, User, Expense, Category, Receipt, Ai, Sync, Subscription
- `backend/helpers/` — Database (PDO singleton), Response, Validator, input parser
- `backend/database/schema.sql` — 8 tables (users, expenses, categories, receipts, subscriptions, payments, sync_logs, notifications)
- `backend/.htaccess` + `backend/index.php` — URL routing with parameterized routes
- 18 API endpoints all documented and routed

#### Fixes
- Fixed `dart analyze` — all 10 issues resolved (0 errors, 0 warnings)
- Fixed dependency conflict: re-resolved `drift_dev` and `injectable_generator` versions
- Regenerated Drift + Injectable code with `build_runner`

---

### Still Left (minor)
- Wire BLoC providers into page widgets (currently pages still use local state)
- Real camera integration in Scanner page (use `camera` plugin — BLoC ready)
- Real `image_cropper` integration in Crop page
- OCR/AI backend integration (backend routes ready, BLoC has mock flow)
- Hive initialization in `main.dart`
- Real AdMob ad unit IDs
- Unit/widget tests
- Release build configuration

---

### Done
- **Navigation / GoRouter fixes**
  - Added `lib/core/router/context_ext.dart` with a `safePop(fallback)` helper.
  - Replaced every `context.pop()` with `context.safePop(...)` so back/close buttons work even when a page is reached via `context.go`.
  - Fixed crashes in Scanner, Crop, AI Processing, Result, Expense Details, Login, Register, OTP, Sync Status, Profile, and Analytics pages.
- **Real camera in Receipt Scanner**
  - `receipt_scanner_page.dart` now uses the `camera` plugin: live preview, permission request, flash toggle, capture, and gallery picker.
  - Captured/picked image paths are passed to the Crop screen.
- **Persistent bottom navigation bar**
  - Main tabs (Home, Expenses, Analytics, Profile) now live inside a `StatefulShellRoute.indexedStack` with a shared `MainShell`.
  - The bottom nav stays visible when switching between those tabs.
- **Light mode default**
  - `lib/app.dart` now defaults to `ThemeMode.light`.
- **UI polish**
  - Fixed `_SummaryCard` overflow on the Analytics page.
  - Fixed Welcome screen layout so buttons are not squeezed on small screens.
- **Static analysis**
  - `dart analyze` now reports **No issues found!**
- **Expense data + BLoC layer (wired to UI)**
  - `ExpenseModel`, `ExpenseLocalDataSource` (Drift), `ExpenseRemoteDataSource` (mock), `ExpenseRepositoryImpl`, and use cases created.
  - `ExpenseBloc`, `ExpenseFormBloc`, `ExpenseDetailsBloc` created.
  - Manual DI registrations added in `lib/core/di/injection.dart`.
  - **Now wired into all three expense screens** (see below).
- **Expense screens now data-driven**
  - `ExpenseListPage` → `ExpenseBloc`: loads via Drift, search dispatches `SearchExpensesRequested`, date filter chips (Today/Week/Month) filter locally, total/count derived from loaded list, tap opens details.
  - `AddExpensePage` → `ExpenseFormBloc`: validates + submits (create/update), shows submit spinner + success snackbar, pops on success. Supports **edit mode** (passed existing `Expense` via router `extra`).
  - `ExpenseDetailsPage` → `ExpenseDetailsBloc`: loads by id, full detail rows, AI confidence + sync chip from real data, delete dispatches `DeleteExpenseDetailsRequested` and pops on success, Edit opens edit route.
  - Added `/expenses/:id/edit` route in `app_router.dart`.
  - Added `lib/features/expenses/presentation/helpers/expense_ui_helper.dart` (category icon/color map, sync-status label/color, date formatting + range filter).

### Still Left
- Phase 2: Implement remaining BLoCs (`DashboardBloc`, `CategoryBloc`, `AnalyticsBloc`, `ReportsBloc`, `SubscriptionBloc`, `ProfileBloc`, `SettingsBloc`, `SyncBloc`, `AdsBloc`, `ReceiptProcessingBloc`). Expense BLoCs are done and wired.
- Phase 3: Wire remaining Drift DAOs and data sources (categories, sync, subscription, ads). Expense data source is done.
- Phase 4: Real image cropping (`image_cropper`), OCR/AI backend calls, auto-populate receipt result.
- Phase 5: Build PHP/MySQL backend.
- Phase 6: Sync system implementation.
- Phase 7: AdMob wiring, subscription / payment integration.
- Phase 8: Tests and release builds.
- Screen 25: Help & Support screen not built.

---

## ✅ Phase 1 — Flutter UI Design (COMPLETE)

All 25 screens planned in the spec have been built with dummy/local data. Dark mode supported throughout.

### Screens

| # | Screen | File | Status | Notes |
|---|---|---|---|---|
| 1 | Splash Screen | `features/splash/presentation/pages/splash_page.dart` | ✅ Done | Animated fade + scale, 3-dot loader, auto-nav after 2.5s |
| 2 | Onboarding Screen 1 | `features/onboarding/presentation/pages/onboarding_page.dart` | ✅ Done | "Never lose your receipts again" |
| 3 | Onboarding Screen 2 | same file | ✅ Done | "AI understands your expenses" with AI chips |
| 4 | Onboarding Screen 3 | same file | ✅ Done | "Save hours every month" with feature list |
| 5 | Welcome Screen | `features/auth/presentation/pages/welcome_page.dart` | ✅ Done | Login, Register, Continue with Google buttons |
| 6 | Login Screen | `features/auth/presentation/pages/login_page.dart` | ✅ Done | Email + password, validation, loading state |
| 7 | Register Screen | `features/auth/presentation/pages/register_page.dart` | ✅ Done | Name, email, password, business, currency |
| 8 | OTP Verification | `features/auth/presentation/pages/otp_page.dart` | ✅ Done | 6-digit Pinput, resend countdown timer |
| 9 | Dashboard | `features/dashboard/presentation/pages/dashboard_page.dart` | ✅ Done | Monthly summary card, quick actions, recent expenses, sync chip, ad banner, bottom nav |
| 10 | Receipt Scanner | `features/receipt_scanner/presentation/pages/receipt_scanner_page.dart` | ✅ Done | Camera UI mockup, scan frame overlay, flash toggle, gallery/capture buttons, animated scan line |
| 11 | Receipt Crop | `features/receipt_scanner/presentation/pages/receipt_crop_page.dart` | ✅ Done | Crop + rotate UI, retake / continue |
| 12 | AI Processing | `features/receipt_scanner/presentation/pages/ai_processing_page.dart` | ✅ Done | Step-by-step animated progress: OCR → vendor → amount → AI categorization |
| 13 | Receipt Result | `features/receipt_scanner/presentation/pages/receipt_result_page.dart` | ✅ Done | Shows vendor, amount, date, category, confidence score, save / edit / retake |
| 14 | Add / Edit Expense | `features/expenses/presentation/pages/add_expense_page.dart` | ✅ Done | All fields: vendor, amount, date, category, payment method, client, project, notes, image. **Wired to `ExpenseFormBloc` (create/update), edit mode via router `extra`.** |
| 15 | Expense List | `features/expenses/presentation/pages/expense_list_page.dart` | ✅ Done | **Wired to `ExpenseBloc`**: loads from Drift, search, filter chips, total card, pull-to-refresh, empty state. |
| 16 | Expense Details | `features/expenses/presentation/pages/expense_details_page.dart` | ✅ Done | **Wired to `ExpenseDetailsBloc`**: real detail view, receipt image, AI confidence, sync status, edit/delete actions. |
| 17 | Category Management | `features/categories/presentation/pages/categories_page.dart` | ✅ Done | Business + Personal tabs, add/edit/delete categories, color picker |
| 18 | Analytics Dashboard | `features/analytics/presentation/pages/analytics_page.dart` | ✅ Done | fl_chart bar chart (weekly), donut chart (categories), summary stats, period selector |
| 19 | AI Insights | (inside analytics_page or reports_page) | ⚠️ Partial | AI insight cards exist in analytics; dedicated screen not built separately |
| 20 | Reports | `features/reports/presentation/pages/reports_page.dart` | ✅ Done | Monthly/tax/business/category report types, PDF/CSV export buttons |
| 21 | Subscription | `features/subscription/presentation/pages/subscription_page.dart` | ✅ Done | Free vs Premium plan comparison, feature list, upgrade CTA |
| 22 | Profile | `features/profile/presentation/pages/profile_page.dart` | ✅ Done | Avatar, name, email, business, premium badge, logout/delete dialogs |
| 23 | Settings | `features/settings/presentation/pages/settings_page.dart` | ✅ Done | Theme, currency, notifications, privacy, sync, delete account |
| 24 | Sync Status | `features/sync/presentation/pages/sync_status_page.dart` | ✅ Done | Hero card with live progress, stat row, recent activity list, retry failed |
| 25 | Help & Support | ❌ Not built | Not in router | FAQ, contact, privacy policy, terms, version info — **needs to be created** |

> **Screen 25 (Help & Support)** is planned in the spec but not yet built and not in the router.

---

### Core Foundation (Phase 1)

| File | Status | Notes |
|---|---|---|
| `core/theme/app_colors.dart` | ✅ Done | Full color palette, dark/light, gradients, shadows, glassmorphism |
| `core/theme/app_theme.dart` | ✅ Done | Light + dark `ThemeData`, Material 3 |
| `core/theme/app_text_styles.dart` | ✅ Done | Outfit font text styles |
| `core/router/app_router.dart` | ✅ Done | go_router with all 24 routes defined |
| `core/router/app_routes.dart` | ✅ Done | Route constants |
| `core/constants/app_constants.dart` | ✅ Done | App-wide constants |
| `core/widgets/app_widgets.dart` | ✅ Done | Reusable shared widgets |
| `core/utils/app_utils.dart` | ✅ Done | Utility helpers |
| `core/errors/` | ✅ Done | Failure classes, exceptions |
| `core/network/` | ✅ Done | Dio client, auth interceptor |
| `core/database/` | ✅ Done | Drift DB setup, tables defined |
| `core/di/` | ✅ Done | GetIt + Injectable setup, network & local modules |

---

## 🟢 Phase 2 — BLoC Architecture Setup (IN PROGRESS)

`AuthBloc` and the expense BLoCs (`ExpenseBloc`, `ExpenseFormBloc`, `ExpenseDetailsBloc`) are implemented. Remaining BLoCs are still empty.

### BLoCs Required

| BLoC | Location | Status | Events Needed | States Needed |
|---|---|---|---|---|
| `SplashBloc` | `features/splash/presentation/bloc/` | 🔴 Empty | AppStarted, CheckAuthStatus, CheckOnboardingStatus | SplashInitial, Loading, Authenticated, Unauthenticated, FirstTimeUser |
| `OnboardingCubit` | `features/onboarding/presentation/cubit/` | 🔴 Empty | CompleteOnboarding | OnboardingInitial, OnboardingComplete |
| `AuthBloc` | `features/auth/presentation/bloc/` | ✅ Done | LoginEvent, RegisterEvent, LogoutEvent, CheckAuthStatus | AuthInitial, AuthLoading, Authenticated, Unauthenticated, AuthError |
| `OtpBloc` | `features/auth/presentation/bloc/` | 🔴 Empty | VerifyOtpRequested, ResendOtpRequested | OtpInitial, Loading, OtpVerified, OtpError |
| `DashboardBloc` | `features/dashboard/presentation/bloc/` | 🔴 Empty | LoadDashboardData, LoadRecentExpenses, CheckSyncStatus | DashboardInitial, Loading, Loaded, Error |
| `ExpenseBloc` | `features/expenses/presentation/bloc/` | ✅ Done (wired) | LoadExpenses, SearchExpenses, DeleteExpense | ExpenseInitial, Loading, Loaded, Error |
| `ExpenseFormBloc` | `features/expenses/presentation/bloc/` | ✅ Done (wired) | InitializeExpenseForm, ExpenseDraftUpdated, SubmitExpenseForm | ExpenseFormState |
| `ExpenseDetailsBloc` | `features/expenses/presentation/bloc/` | ✅ Done (wired) | LoadExpenseDetails, DeleteExpenseDetailsRequested | ExpenseDetailsInitial, Loading, Loaded, Deleted, Error |
| `ReceiptScannerBloc` | `features/receipt_scanner/presentation/bloc/` | 🔴 Empty | InitializeCamera, CaptureReceipt, PickFromGallery, ToggleFlash | ScannerInitial, Ready, Capturing, ImageCaptured, Error |
| `ReceiptProcessingBloc` | `features/receipt_scanner/presentation/bloc/` | 🔴 Empty | StartProcessing, RunOcr, RunAiCategorization | ProcessingInitial, Loading, OcrCompleted, AiCompleted, Success, Error |
| `CategoryBloc` | `features/categories/presentation/bloc/` | 🔴 Empty | LoadCategories, AddCategory, UpdateCategory, DeleteCategory | CategoryInitial, Loading, Loaded, Error |
| `AnalyticsBloc` | `features/analytics/presentation/bloc/` | 🔴 Empty | LoadAnalytics, ChangeAnalyticsDateRange | AnalyticsInitial, Loading, Loaded, Error |
| `ReportsBloc` | `features/reports/presentation/bloc/` | 🔴 Empty | GenerateReport, ExportPdf, ExportCsv | ReportsInitial, Generating, Generated, Exported, Error |
| `SubscriptionBloc` | `features/subscription/presentation/bloc/` | 🔴 Empty | LoadPlans, PurchasePlan, RestorePurchase, VerifySubscription | SubInitial, Loading, Loaded, Purchased, Error |
| `ProfileBloc` | `features/profile/presentation/bloc/` | 🔴 Empty | LoadProfile, UpdateProfile, LogoutRequested | ProfileInitial, Loading, Loaded, Updated, Error |
| `SettingsBloc` | `features/settings/presentation/bloc/` | 🔴 Empty | LoadSettings, UpdateTheme, UpdateCurrency, UpdateNotification | SettingsInitial, Loaded, Updated, Error |
| `SyncBloc` | `features/sync/presentation/bloc/` | 🔴 Empty | LoadSyncStatus, StartManualSync, RetryFailedSync | SyncInitial, Idle, InProgress, Completed, Failed |
| `AdsBloc` | `features/ads/presentation/bloc/` | 🔴 Empty | LoadAds, HideAds, ShowBannerAd, ShowNativeAd | AdsInitial, AdsLoaded, AdsHidden, Error |

---

### Domain Layer (Entities, Use Cases, Repositories — Interfaces)

| Feature | Entities | Repository Interface | Use Cases | Status |
|---|---|---|---|---|
| auth | `user_entity.dart` ✅ | `auth_repository.dart` ✅ | `login_usecase.dart` ✅, `register_usecase.dart` ✅, `logout_usecase.dart` ✅, `check_auth_status_usecase.dart` ✅ | ✅ Done |
| expenses | `expense.dart` ✅ | `expense_repository.dart` ✅ | `get_expenses_usecase.dart` ✅, `get_expense_by_id_usecase.dart` ✅, `search_expenses_usecase.dart` ✅, `create_expense_usecase.dart` ✅, `update_expense_usecase.dart` ✅, `delete_expense_usecase.dart` ✅ | ✅ Done |
| categories | `category.dart` ✅ | 🔴 Not created | 🔴 Not created | Partial |
| receipt_scanner | 🔴 Not created | 🔴 Not created | 🔴 Not created | Empty |
| dashboard | 🔴 Not created | 🔴 Not created | 🔴 Not created | Empty |
| analytics | 🔴 Not created | 🔴 Not created | 🔴 Not created | Empty |
| reports | 🔴 Not created | 🔴 Not created | 🔴 Not created | Empty |
| subscription | 🔴 Not created | 🔴 Not created | 🔴 Not created | Empty |
| sync | 🔴 Not created | 🔴 Not created | 🔴 Not created | Empty |

---

## 🟢 Phase 3 — Offline Database Integration (IN PROGRESS)

### Drift (SQLite) Setup

| Item | Status |
|---|---|
| `core/database/app_database.dart` — Drift DB class | ✅ Done |
| `users` table (Drift table definition) | ✅ Done |
| `expenses` table | ✅ Done |
| `categories` table | ✅ Done |
| `sync_queue` table | ✅ Done |
| `app_settings` table | ✅ Done |
| `receipts` table | 🔴 Not created |
| Drift DAOs (Data Access Objects) | 🔴 Not created |
| `build_runner` code generation run | ✅ Done |

### Hive / SharedPreferences Setup

| Item | Status |
|---|---|
| Hive initialization in `main.dart` | 🔴 Not done |
| Token storage (flutter_secure_storage) | ✅ Done |
| Onboarding completion flag (Hive/SharedPreferences) | 🔴 Not done |
| Settings persistence | 🔴 Not done |

### Data Layer (Data Models, Local & Remote Data Sources)

| Feature | Data Model | Local DataSource | Remote DataSource | Repository Impl |
|---|---|---|---|---|
| auth | `user_model.dart` ✅ | `auth_local_data_source.dart` ✅ | `auth_remote_data_source.dart` ✅ | `auth_repository_impl.dart` ✅ |
| expenses | `expense_model.dart` ✅ | `expense_local_data_source.dart` ✅ | `expense_remote_data_source.dart` ✅ | `expense_repository_impl.dart` ✅ |
| categories | 🔴 Not created | 🔴 Not created | 🔴 Not created | 🔴 Not created |
| receipt_scanner | 🔴 Not created | 🔴 Not created | 🔴 Not created | 🔴 Not created |
| sync | 🔴 Not created | 🔴 Not created | 🔴 Not created | 🔴 Not created |
| subscription | 🔴 Not created | 🔴 Not created | 🔴 Not created | 🔴 Not created |

---

## 🟡 Phase 4 — Receipt Scanner + OCR + AI Flow (IN PROGRESS)

| Item | Status |
|---|---|
| Live camera preview using `camera` plugin | ✅ Done |
| Gallery image picker using `image_picker` | ✅ Done |
| Receipt image cropping using `image_cropper` | 🔴 Not done (UI only mockup) |
| Image compression using `flutter_image_compress` | 🔴 Not done |
| OCR API integration (remote call) | 🔴 Not done |
| AI categorization API call (OpenAI/Gemini/Claude) | 🔴 Not done |
| Offline fallback: save image locally, mark as pending | 🔴 Not done |
| ReceiptProcessingBloc wiring with AI result | 🔴 Not done |
| Receipt result auto-population from AI | 🔴 Not done |

---

## 🔴 Phase 5 — PHP/MySQL Backend (NOT STARTED)

### Backend Structure

| Folder/File | Status |
|---|---|
| `backend/config/database.php` | 🔴 Not created |
| `backend/config/jwt.php` | 🔴 Not created |
| `backend/config/app.php` | 🔴 Not created |
| `backend/middleware/auth_middleware.php` | 🔴 Not created |
| `backend/middleware/cors_middleware.php` | 🔴 Not created |
| `backend/controllers/AuthController.php` | 🔴 Not created |
| `backend/controllers/UserController.php` | 🔴 Not created |
| `backend/controllers/ExpenseController.php` | 🔴 Not created |
| `backend/controllers/CategoryController.php` | 🔴 Not created |
| `backend/controllers/ReceiptController.php` | 🔴 Not created |
| `backend/controllers/SyncController.php` | 🔴 Not created |
| `backend/controllers/AiController.php` | 🔴 Not created |
| `backend/controllers/SubscriptionController.php` | 🔴 Not created |
| `backend/models/User.php` | 🔴 Not created |
| `backend/models/Expense.php` | 🔴 Not created |
| `backend/models/Category.php` | 🔴 Not created |
| `backend/models/Receipt.php` | 🔴 Not created |
| `backend/models/Subscription.php` | 🔴 Not created |
| `backend/services/JwtService.php` | 🔴 Not created |
| `backend/services/OcrService.php` | 🔴 Not created |
| `backend/services/AiService.php` | 🔴 Not created |
| `backend/services/UploadService.php` | 🔴 Not created |
| MySQL schema / migration files | 🔴 Not created |

### API Endpoints

| Endpoint | Method | Status |
|---|---|---|
| `/api/register` | POST | 🔴 Not built |
| `/api/login` | POST | 🔴 Not built |
| `/api/logout` | POST | 🔴 Not built |
| `/api/reset-password` | POST | 🔴 Not built |
| `/api/verify-otp` | POST | 🔴 Not built |
| `/api/profile` | GET / PUT | 🔴 Not built |
| `/api/delete-account` | DELETE | 🔴 Not built |
| `/api/expenses` | GET / POST | 🔴 Not built |
| `/api/expenses/{id}` | GET / PUT / DELETE | 🔴 Not built |
| `/api/categories` | GET / POST | 🔴 Not built |
| `/api/categories/{id}` | PUT / DELETE | 🔴 Not built |
| `/api/upload-receipt` | POST | 🔴 Not built |
| `/api/ai/process-receipt` | POST | 🔴 Not built |
| `/api/sync/upload` | POST | 🔴 Not built |
| `/api/sync/download` | GET | 🔴 Not built |
| `/api/plans` | GET | 🔴 Not built |
| `/api/subscribe` | POST | 🔴 Not built |
| `/api/payment/verify` | POST | 🔴 Not built |
| `/api/subscription/status` | GET | 🔴 Not built |

---

## 🔴 Phase 6 — Sync System (NOT STARTED)

| Item | Status |
|---|---|
| `connectivity_plus` integration to detect network | 🔴 Not done |
| Sync queue local database table | 🔴 Not done |
| Auto-sync trigger when internet returns | 🔴 Not done |
| Manual sync (Sync Now button wiring) | 🔴 Not done |
| Retry failed sync items | 🔴 Not done |
| Conflict resolution strategy | 🔴 Not done |
| `SyncBloc` implementation | 🔴 Not done |
| Sync status badge in Dashboard | 🔴 UI only, not wired |

---

## 🔴 Phase 7 — Ads + Subscription (NOT STARTED)

| Item | Status |
|---|---|
| Google AdMob initialization | 🔴 Not done |
| Banner Ad on Dashboard (free users only) | 🔴 UI placeholder only |
| Native Ad in Expense List (every 5 items) | 🔴 Not done |
| Banner/Native Ad in Analytics | 🔴 Not done |
| Rewarded Ad in AI Insights | 🔴 Not done |
| `AdsBloc` wiring | 🔴 Not done |
| `SubscriptionBloc` wiring with backend | 🔴 Not done |
| Premium user detection → hide ads | 🔴 Not done |
| In-app purchase / payment gateway integration | 🔴 Not done |

---

## 🔴 Phase 8 — Testing + Release (NOT STARTED)

| Item | Status |
|---|---|
| Unit tests for BLoCs | 🔴 Not written |
| Unit tests for repositories | 🔴 Not written |
| Widget tests for key screens | 🔴 Not written |
| Integration tests | 🔴 Not written |
| Offline mode end-to-end test | 🔴 Not written |
| Sync end-to-end test | 🔴 Not written |
| Android release build config | 🔴 Not done |
| iOS release build config | 🔴 Not done |
| App signing / keystore setup | 🔴 Not done |
| ProGuard / R8 rules | 🔴 Not done |
| Firebase setup (FCM) | 🔴 Not done |
| Play Store / App Store listing | 🔴 Not done |

---

## ⚠️ Known Issues & Technical Debt

| Issue | File | Severity |
|---|---|---|
| All navigation uses static/dummy data — no real auth state | All pages | High |
| `withOpacity()` deprecated — should use `.withValues(alpha:)` | All files | Low (info only) |
| Receipt Crop is UI-only — no actual image_cropper integration | `receipt_crop_page.dart` | High |
| AI Processing is animated placeholder — no real OCR/AI calls | `ai_processing_page.dart` | High |
| No authentication guard in router — any route is accessible | `app_router.dart` | High |
| No error handling layer (Failure classes, Either<>) | `core/errors/` | ✅ Fixed |
| No Dio client or API interceptor set up | `core/network/` | ✅ Fixed |
| Help & Support screen (screen 25) missing from router | `app_router.dart` | Medium |
| Reports export (PDF/CSV) is UI-only — no actual file generation | `reports_page.dart` | High |
| Share/Export in Expense Details is not wired | `expense_details_page.dart` | Medium |
| Forgot Password flow not wired (taps do nothing) | `login_page.dart` | Medium |
| Google/Apple sign-in shows "Coming soon" snackbar | `welcome_page.dart` | Medium |

---

## 📋 Immediate Next Steps (Suggested Order)

### Step 1 — Core Infrastructure
1. ~~Set up `core/errors/` — `Failure` class + `Either<Failure, T>` using dartz~~ ✅
2. ~~Set up `core/network/` — Dio client + auth interceptor + error interceptor~~ ✅
3. ~~Set up `core/di/` — GetIt service locator + Injectable configuration~~ ✅

### Step 2 — Database Layer
4. ~~Set up `core/database/` — Drift DB with all 6 tables~~ ✅
5. ~~Run `build_runner` to generate Drift code~~ ✅
6. Initialize Hive + SecureStorage in `main.dart` (SecureStorage Done)

### Step 3 — Auth BLoC + Data Layer
7. ~~Create `AuthLocalDataSource` + `AuthRemoteDataSource`~~ ✅
8. ~~Create `AuthRepositoryImpl`~~ ✅
9. ~~Create `AuthBloc` (login, register, logout, token management)~~ ✅
10. ~~Wire `AuthBloc` into Login, Register, OTP screens~~ ✅ (Splash, Login, Register, Profile wired)
11. Add auth guard to router (redirect unauthenticated users)

### Step 4 — Expense BLoC + Data Layer
12. ~~Create `ExpenseLocalDataSource` + `ExpenseRemoteDataSource`~~ ✅
13. ~~Create `ExpenseRepositoryImpl`~~ ✅
14. ~~Create `ExpenseBloc` + `ExpenseFormBloc` + `ExpenseDetailsBloc`~~ ✅
15. ~~Wire into Expense List, Add/Edit, Details screens~~ ✅

### Step 5 — Receipt + AI Flow
16. Integrate real `camera` plugin into Scanner
17. Integrate `image_cropper` into Crop screen
18. Build `ReceiptProcessingBloc` with OCR + AI API calls

### Step 6 — Backend
19. Build PHP REST API (all endpoints above)
20. Set up MySQL tables

### Step 7 — Sync
21. Implement `SyncBloc` + `SyncRepository`
22. Wire `connectivity_plus` for auto-sync

### Step 8 — Ads + Subscription
23. Initialize AdMob
24. Wire `AdsBloc` (show/hide based on subscription)

---

## 📁 Complete File Inventory

### ✅ Files That Exist

```
lib/
├── main.dart                                          ✅
├── app.dart                                           ✅
├── core/
│   ├── constants/app_constants.dart                   ✅
│   ├── database/                                      ✅
│   │   ├── app_database.dart                          ✅
│   │   └── tables.dart                                ✅
│   ├── di/                                            ✅
│   │   ├── injection.dart                             ✅
│   │   ├── local_module.dart                          ✅
│   │   └── network_module.dart                        ✅
│   ├── errors/                                        ✅
│   │   ├── exceptions.dart                            ✅
│   │   └── failures.dart                              ✅
│   ├── network/                                       ✅
│   │   ├── auth_interceptor.dart                      ✅
│   │   └── dio_client.dart                            ✅
│   ├── router/app_router.dart                         ✅
│   ├── router/app_routes.dart                         ✅
│   ├── theme/app_colors.dart                          ✅
│   ├── theme/app_text_styles.dart                     ✅
│   ├── theme/app_theme.dart                           ✅
│   ├── utils/app_utils.dart                           ✅
│   └── widgets/app_widgets.dart                       ✅
└── features/
    ├── auth/
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   ├── auth_local_data_source.dart         ✅
    │   │   │   └── auth_remote_data_source.dart        ✅
    │   │   ├── models/
    │   │   │   └── user_model.dart                     ✅
    │   │   └── repositories/
    │   │       └── auth_repository_impl.dart           ✅
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   └── user_entity.dart                    ✅
    │   │   ├── repositories/
    │   │   │   └── auth_repository.dart                ✅
    │   │   └── usecases/
    │   │       ├── check_auth_status_usecase.dart      ✅
    │   │       ├── login_usecase.dart                  ✅
    │   │       ├── logout_usecase.dart                 ✅
    │   │       └── register_usecase.dart               ✅
    │   └── presentation/
    │       ├── bloc/
    │       │   ├── auth_bloc.dart                      ✅
    │       │   ├── auth_event.dart                     ✅
    │       │   └── auth_state.dart                     ✅
    │       └── pages/
    │           ├── welcome_page.dart                   ✅
    │           ├── login_page.dart                     ✅
    │           ├── register_page.dart                  ✅
    │           └── otp_page.dart                       ✅
    ├── splash/
    │   └── presentation/pages/splash_page.dart         ✅
    ├── onboarding/
    │   └── presentation/pages/onboarding_page.dart     ✅
    ├── dashboard/
    │   └── presentation/pages/dashboard_page.dart      ✅
    ├── expenses/
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   ├── expense_local_data_source.dart      ✅
    │   │   │   └── expense_remote_data_source.dart     ✅
    │   │   ├── models/
    │   │   │   └── expense_model.dart                  ✅
    │   │   └── repositories/
    │   │       └── expense_repository_impl.dart        ✅
    │   ├── domain/
    │   │   ├── entities/expense.dart                   ✅
    │   │   ├── repositories/expense_repository.dart    ✅
    │   │   └── usecases/                               ✅
    │   │       ├── get_expenses_usecase.dart           ✅
    │   │       ├── get_expense_by_id_usecase.dart      ✅
    │   │       ├── search_expenses_usecase.dart        ✅
    │   │       ├── create_expense_usecase.dart         ✅
    │   │       ├── update_expense_usecase.dart         ✅
    │   │       └── delete_expense_usecase.dart         ✅
    │   └── presentation/
    │       ├── bloc/                                   ✅
    │       ├── helpers/                                ✅ (expense_ui_helper.dart)
    │       └── pages/
    │           ├── expense_list_page.dart              ✅
    │           ├── expense_details_page.dart           ✅
    │           └── add_expense_page.dart               ✅
    ├── receipt_scanner/
    │   └── presentation/pages/
    │       ├── receipt_scanner_page.dart               ✅
    │       ├── receipt_crop_page.dart                  ✅
    │       ├── ai_processing_page.dart                 ✅
    │       └── receipt_result_page.dart                ✅
    ├── categories/
    │   ├── domain/entities/category.dart               ✅
    │   └── presentation/pages/categories_page.dart     ✅
    ├── analytics/
    │   └── presentation/pages/analytics_page.dart      ✅
    ├── reports/
    │   └── presentation/pages/reports_page.dart        ✅
    ├── subscription/
    │   └── presentation/pages/subscription_page.dart   ✅
    ├── profile/
    │   └── presentation/pages/profile_page.dart        ✅
    ├── settings/
    │   └── presentation/pages/settings_page.dart       ✅
    └── sync/
        └── presentation/pages/sync_status_page.dart    ✅
```

### 🔴 Folders That Are Empty (Need Files)

```
core/
├── errors/                                            ✅
├── network/                                           ✅
└── di/                                                ✅

features/
├── auth/                                              ✅
├── expenses/                                          ✅
│   └── presentation/widgets/
├── dashboard/
│   ├── data/                ← full data layer
│   ├── domain/              ← full domain layer
│   ├── presentation/bloc/   ← DashboardBloc
│   └── presentation/widgets/
├── categories/
│   ├── data/                ← full data layer
│   ├── domain/repositories/ + usecases/
│   ├── presentation/bloc/   ← CategoryBloc
│   └── presentation/widgets/
├── receipt_scanner/
│   ├── data/                ← full data layer
│   ├── domain/              ← full domain layer
│   ├── presentation/bloc/   ← ReceiptScannerBloc, ReceiptProcessingBloc
│   └── presentation/widgets/
├── analytics/
│   ├── (no data/ or domain/ folders) ← need creation
│   ├── presentation/bloc/   ← AnalyticsBloc
│   └── presentation/widgets/
├── reports/
│   ├── presentation/bloc/   ← ReportsBloc
│   └── presentation/widgets/
├── subscription/
│   ├── presentation/bloc/   ← SubscriptionBloc
│   └── presentation/widgets/
├── profile/
│   ├── presentation/bloc/   ← ProfileBloc
│   └── presentation/widgets/ (missing)
├── settings/
│   ├── presentation/bloc/   ← SettingsBloc
│   └── presentation/widgets/ (missing)
├── sync/
│   ├── (no data/ or domain/ folders) ← need creation
│   ├── presentation/bloc/   ← SyncBloc
│   └── presentation/widgets/
└── ads/
    ├── (no data/ or domain/ folders) ← need creation
    ├── presentation/bloc/   ← AdsBloc
    └── presentation/widgets/
```

---

## 🏗️ Backend (Entirely Not Started)

```
backend/               ← Does NOT exist yet
├── api/
├── config/
├── controllers/
├── models/
├── services/
├── middleware/
├── helpers/
├── uploads/
├── database/
└── logs/
```

---

*Last updated: July 9, 2026*
