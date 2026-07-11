import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:billlens/core/di/injection.dart';
import 'package:billlens/core/local/local_storage_service.dart';
import 'package:billlens/core/router/app_routes.dart';
import 'package:billlens/core/router/context_ext.dart';
import 'package:billlens/core/utils/app_utils.dart';
import 'package:billlens/core/widgets/app_widgets.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../../../expenses/presentation/bloc/expense_form_bloc.dart';
import '../../../expenses/presentation/bloc/expense_bloc.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../../dashboard/presentation/bloc/dashboard_event.dart';
import '../../../analytics/presentation/bloc/analytics_bloc.dart';
import '../../../analytics/presentation/bloc/analytics_event.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/data/repositories/user_repository.dart';
import '../bloc/receipt_processing_state.dart';

class ReceiptResultPage extends StatelessWidget {
  final dynamic processingResult;
  const ReceiptResultPage({super.key, this.processingResult});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ExpenseFormBloc>(
      create: (_) => getIt<ExpenseFormBloc>(),
      child: _ReceiptResultView(processingResult: processingResult),
    );
  }
}

class _ReceiptResultView extends StatefulWidget {
  final dynamic processingResult;
  const _ReceiptResultView({this.processingResult});

  @override
  State<_ReceiptResultView> createState() => _ReceiptResultPageState();
}

class _ReceiptResultPageState extends State<_ReceiptResultView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _cardController;
  late final Animation<double> _cardAnimation;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _cardAnimation = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutCubic,
    );
    // Auto-set currency after frame is ready so context is valid
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoCurrencySet());
  }

  /// If the scanned bill has a detected currency different from the stored one,
  /// silently update local storage and backend and show a small toast.
  Future<void> _autoCurrencySet() async {
    final detectedCurrency = _getProp('currency') as String?;
    if (detectedCurrency == null || detectedCurrency.isEmpty) return;

    final storage = getIt<LocalStorageService>();
    final currentCurrency = storage.currency;
    // Nothing to do if already the same
    if (detectedCurrency.toUpperCase() == currentCurrency.toUpperCase()) return;

    try {
      // 1. Update local pref
      await storage.setCurrency(detectedCurrency.toUpperCase());

      // 2. Sync to backend if logged in
      if (!mounted) return;
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        final repo = getIt<UserRepository>();
        await repo.updateProfile(
          userId: authState.user.id,
          currency: detectedCurrency.toUpperCase(),
        );
        if (mounted) {
          context.read<AuthBloc>().add(CheckAuthStatus());
        }
      }

      // 3. Show subtle toast
      if (!mounted) return;
      final symbol = AppUtils.getCurrencySymbol(detectedCurrency.toUpperCase());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.currency_exchange_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Currency auto-set to $symbol ${detectedCurrency.toUpperCase()}',
                  style: GoogleFonts.outfit(
                      color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        ),
      );
    } catch (_) {
      // Auto-set is best-effort; never block the user
    }
  }

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  String get vendor => _getProp('vendor') ?? 'Unknown';
  double get amount => (_getProp('amount') as num?)?.toDouble() ?? 0;
  String get date =>
      _getProp('date') ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
  String get category => _getProp('category') ?? 'Other';
  String get categoryType => _getProp('categoryType') ?? 'business';
  String get explanation => _getProp('explanation') ?? '';
  double get confidence => (_getProp('confidence') as num?)?.toDouble() ?? 0.5;

  bool get isDuplicate => _getProp('isDuplicate') as bool? ?? false;
  String? get duplicateReason => _getProp('duplicateReason') as String?;
  String get documentType => _getProp('documentType') ?? 'receipt';
  String? get receiptNumber => _getProp('receiptNumber') as String?;

  Color get _confidenceColor {
    if (confidence >= 0.8) return const Color(0xFF15803D);
    if (confidence >= 0.65) return const Color(0xFFB45309);
    return Theme.of(context).colorScheme.error;
  }

  IconData get _confidenceIcon =>
      confidence >= 0.65 ? Icons.verified_rounded : Icons.error_outline_rounded;

  /// Returns the AI-detected payment method normalised to one of the known
  /// dropdown values, or null if it cannot be mapped.
  String? get paymentMethod {
    final raw = _getProp('paymentMethod') as String?;
    if (raw == null || raw == '-') return null;
    return _normalisePaymentMethod(raw);
  }

  String get currency {
    final detected = _getProp('currency') as String?;
    if (detected != null && detected.isNotEmpty) return detected;
    try {
      if (getIt.isRegistered<LocalStorageService>()) {
        return getIt<LocalStorageService>().currency;
      }
    } catch (_) {}
    return 'USD';
  }

  dynamic _getProp(String key) {
    final r = widget.processingResult;
    if (r == null) return null;
    // Prefer typed access for ProcessingSuccess
    if (r is ProcessingSuccess) {
      switch (key) {
        case 'vendor':
          return r.vendor;
        case 'amount':
          return r.amount;
        case 'date':
          return r.date;
        case 'category':
          return r.category;
        case 'categoryType':
          return r.categoryType;
        case 'explanation':
          return r.explanation;
        case 'confidence':
          return r.confidence;
        case 'paymentMethod':
          return r.paymentMethod;
        case 'currency':
          return r.currency;
        case 'isDuplicate':
          return r.isDuplicate;
        case 'duplicateReason':
          return r.duplicateReason;
        case 'documentType':
          return r.documentType;
        case 'receiptNumber':
          return r.receiptNumber;
        default:
          return null;
      }
    }
    if (r is Map) {
      final v = r[key];
      return v;
    }
    return null;
  }

  /// Valid values that match the DropdownButtonFormField items in AddExpensePage.
  static const _knownMethods = [
    'Corporate Card',
    'Personal Card',
    'Cash',
    'Bank Transfer',
    'PayPal',
    'Other',
  ];

  /// Map common AI-returned strings to known dropdown values.
  static String? _normalisePaymentMethod(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('visa') ||
        lower.contains('mastercard') ||
        lower.contains('amex') ||
        lower.contains('credit') ||
        lower.contains('debit') ||
        lower.contains('card')) {
      return 'Personal Card';
    }
    if (lower.contains('cash')) return 'Cash';
    if (lower.contains('transfer') || lower.contains('bank')) {
      return 'Bank Transfer';
    }
    if (lower.contains('paypal')) return 'PayPal';
    // Check for exact match (case-insensitive)
    for (final m in _knownMethods) {
      if (m.toLowerCase() == lower) return m;
    }
    return 'Other';
  }

  List<MapEntry<String, String>> get _fields {
    final list = [
      MapEntry('Vendor', vendor),
      MapEntry('Amount', AppUtils.formatCurrency(amount, currency: currency)),
      MapEntry(
          'Date',
          DateFormat('dd MMM yyyy')
              .format(DateTime.tryParse(date) ?? DateTime.now())),
      MapEntry('Category', category),
      MapEntry('Payment', paymentMethod ?? 'N/A'),
      MapEntry('Type', categoryType == 'business' ? 'Business' : 'Personal'),
      MapEntry('Doc Type', documentType.toUpperCase()),
    ];
    if (receiptNumber != null && receiptNumber!.isNotEmpty) {
      list.add(MapEntry('Receipt No', receiptNumber!));
    }
    return list;
  }

  void _saveExpense() {
    if (_isSaving) return;
    final expense = _buildExpense();
    final bloc = context.read<ExpenseFormBloc>();
    bloc.add(ExpenseDraftUpdated(expense));
    bloc.add(const SubmitExpenseForm());
  }

  void _editDetails() {
    final expense = _buildExpense();
    context.push('/expenses/add', extra: expense);
  }

  String? get _receiptUrl {
    final r = widget.processingResult;
    if (r is ProcessingSuccess) return r.receiptUrl;
    return null;
  }

  Expense _buildExpense() {
    final now = DateTime.now();
    return Expense(
      id: '',
      userId: '',
      vendor: vendor,
      amount: amount,
      currency: currency,
      categoryName: category,
      date: DateTime.tryParse(date) ?? now,
      paymentMethod: paymentMethod,
      receiptImageRemoteUrl: _receiptUrl,
      aiConfidence: confidence,
      aiExplanation: explanation,
      syncStatus: 'pending',
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<ExpenseFormBloc, ExpenseFormState>(
      listener: (context, state) {
        if (state.isSubmitting) {
          setState(() => _isSaving = true);
        } else if (state.isSuccess) {
          setState(() => _isSaving = false);
          // Refresh dashboard, expenses, and analytics so it shows the new expense
          context.read<DashboardBloc>().add(LoadDashboardData());
          context.read<ExpenseBloc>().add(const LoadExpensesRequested());
          context.read<AnalyticsBloc>().add(LoadAnalytics());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Expense saved successfully!'),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
          context.go(AppRoutes.dashboard);
        } else if (state.errorMessage != null) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surfaceContainerLowest,
        appBar: AppPageBar(
          title: 'Receipt Extracted',
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => context.safePop(AppRoutes.dashboard),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share_outlined, size: 22),
              tooltip: 'Share receipt',
              onPressed: () {},
            ),
          ],
        ),
        body: FadeTransition(
          opacity: _cardAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(_cardAnimation),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppGroupedSurface(
                    padding: const EdgeInsets.all(20),
                    borderColor: colorScheme.primary.withValues(alpha: 0.28),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.receipt_long_rounded,
                            color: colorScheme.onPrimaryContainer,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vendor,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                AppUtils.formatCurrency(amount, currency: currency),
                                style: GoogleFonts.outfit(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: _confidenceColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _confidenceIcon,
                                size: 14,
                                color: _confidenceColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${(confidence * 100).round()}%',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _confidenceColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isDuplicate) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF59E0B)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: Color(0xFFD97706), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Possible Duplicate',
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF92400E),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  duplicateReason ??
                                      'You already have an expense similar to this one.',
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    color: const Color(0xFFB45309),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Text(
                    'Extracted details',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AppGroupedSurface(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (var index = 0;
                            index < _fields.length;
                            index++) ...[
                          _FieldRow(
                            label: _fields[index].key,
                            value: _fields[index].value,
                          ),
                          if (index < _fields.length - 1)
                            Divider(
                              height: 1,
                              indent: 16,
                              endIndent: 16,
                              color: colorScheme.outlineVariant,
                            ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppGroupedSurface(
                    borderColor: colorScheme.primary.withValues(alpha: 0.25),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            confidence < 0.65
                                ? Icons.rate_review_outlined
                                : Icons.auto_awesome_rounded,
                            size: 18,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                confidence < 0.65
                                    ? 'Please review carefully'
                                    : 'Ready for review',
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                explanation.isEmpty
                                    ? 'Check the extracted details before saving this expense.'
                                    : explanation,
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: colorScheme.onSurfaceVariant,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                top: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        text: 'Edit',
                        height: 52,
                        onPressed: _editDetails,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: PrimaryButton(
                        text: _isSaving ? 'Saving...' : 'Save Expense',
                        height: 52,
                        isLoading: _isSaving,
                        icon: const Icon(Icons.save_rounded, size: 18),
                        onPressed: _isSaving ? null : _saveExpense,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                TextButton.icon(
                  onPressed: () => context.go(AppRoutes.receiptScanner),
                  icon: Icon(
                    Icons.camera_alt_outlined,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  label: Text(
                    'Retake',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  final String label;
  final String value;

  const _FieldRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
