import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:billlens/core/widgets/limit_widgets.dart';
import 'package:billlens/core/di/injection.dart';
import 'package:go_router/go_router.dart';
import 'package:billlens/core/router/app_routes.dart';
import 'package:billlens/core/router/context_ext.dart';
import 'package:billlens/core/theme/app_colors.dart';
import 'package:billlens/core/widgets/app_widgets.dart';
import 'package:billlens/features/expenses/domain/entities/expense.dart';
import 'package:billlens/features/expenses/presentation/bloc/expense_form_bloc.dart';
import 'package:billlens/features/expenses/presentation/bloc/expense_bloc.dart';
import 'package:billlens/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:billlens/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:billlens/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:billlens/features/analytics/presentation/bloc/analytics_event.dart';
import 'package:billlens/core/local/currency_service.dart';
import 'package:billlens/core/utils/app_utils.dart';
import 'package:image_picker/image_picker.dart';

// ---------------------------------------------------------------------------
// Category model
// ---------------------------------------------------------------------------
class _Category {
  final String name;
  final IconData icon;
  final Color color;

  const _Category({
    required this.name,
    required this.icon,
    required this.color,
  });
}

const List<_Category> _categories = [
  _Category(
      name: 'Client Meeting',
      icon: Icons.handshake_rounded,
      color: Color(0xFF2563EB)),
  _Category(
      name: 'Travel', icon: Icons.flight_rounded, color: Color(0xFF8B5CF6)),
  _Category(
      name: 'Office Supplies',
      icon: Icons.inventory_2_rounded,
      color: Color(0xFFEF4444)),
  _Category(
      name: 'Software', icon: Icons.computer_rounded, color: Color(0xFF06B6D4)),
  _Category(
      name: 'Meals', icon: Icons.restaurant_rounded, color: Color(0xFF10B981)),
  _Category(
      name: 'Accommodation',
      icon: Icons.hotel_rounded,
      color: Color(0xFF8B5CF6)),
  _Category(
      name: 'Marketing',
      icon: Icons.campaign_rounded,
      color: Color(0xFFEC4899)),
  _Category(
      name: 'Utilities', icon: Icons.bolt_rounded, color: Color(0xFFF59E0B)),
  _Category(
      name: 'Other', icon: Icons.more_horiz_rounded, color: Color(0xFF64748B)),
];

const List<String> _paymentMethods = [
  'Corporate Card',
  'Personal Card',
  'Cash',
  'Bank Transfer',
  'PayPal',
  'Other',
];

// ---------------------------------------------------------------------------
// Add / Edit Expense Page
// ---------------------------------------------------------------------------
class AddExpensePage extends StatelessWidget {
  final Expense? expense;

  const AddExpensePage({super.key, this.expense});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ExpenseFormBloc>(
      create: (_) => getIt<ExpenseFormBloc>()
        ..add(InitializeExpenseForm(expense: expense)),
      child: BlocConsumer<ExpenseFormBloc, ExpenseFormState>(
        listener: (context, state) {
          if (state.isSuccess) {
            // Refresh dashboard, expenses list, and analytics so new expense appears immediately
            context.read<DashboardBloc>().add(LoadDashboardData());
            context.read<ExpenseBloc>().add(const LoadExpensesRequested());
            context.read<AnalyticsBloc>().add(LoadAnalytics());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      expense == null
                          ? 'Expense saved successfully!'
                          : 'Expense updated successfully!',
                      style: GoogleFonts.outfit(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            );
            context.safePop(AppRoutes.expenseList);
          } else if (state.isLimitExceeded) {
            // ── FIXED LIMITS: Show upgrade dialog for manual limit ──
            LimitExceededDialog.show(
              context,
              message: state.errorMessage ??
                  'Monthly manual expense limit reached (20/month for free). Upgrade to premium for unlimited.',
              code: state.limitCode ?? 'MANUAL_LIMIT_EXCEEDED',
              usage: state.limitUsage,
              used: state.limitUsage?['used'] as int?,
              limit: state.limitUsage?['limit'] as int?,
            );
          } else if (state.isDuplicate) {
            // ── DUPLICATE: Show understandable dialog from backend ──
            final existing = state.duplicateExpense;
            final vendor = existing?['vendor'] as String? ?? 'this vendor';
            final amount = existing?['amount']?.toString() ?? '';
            final date = existing?['date'] as String? ?? '';
            final existingId = existing?['id']?.toString();
            final receiptNo = existing?['receipt_number'] as String?;

            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.15), shape: BoxShape.circle),
                      child: const Icon(Icons.content_copy_rounded, color: AppColors.warning, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Duplicate Expense', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 18))),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.errorMessage ?? 'This expense already exists in your account.',
                      style: GoogleFonts.outfit(fontSize: 14, height: 1.4, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (existing != null) ...[
                            Text('Existing expense:', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                            const SizedBox(height: 6),
                            Row(children: [const Icon(Icons.store_rounded, size: 14, color: Colors.grey), const SizedBox(width: 6), Expanded(child: Text(vendor, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600)))]),
                            const SizedBox(height: 4),
                            Row(children: [const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey), const SizedBox(width: 6), Text(date, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[700]))]),
                            const SizedBox(height: 4),
                            Row(children: [const Icon(Icons.attach_money_rounded, size: 14, color: Colors.grey), const SizedBox(width: 6), Text('\$$amount', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600))]),
                            if (receiptNo != null && receiptNo.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(children: [const Icon(Icons.receipt_rounded, size: 14, color: Colors.grey), const SizedBox(width: 6), Text('Receipt #$receiptNo', style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey[600]))]),
                            ],
                          ] else
                            Text('An expense with same vendor, date and amount already exists.', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Suggestion: View existing expense or edit it instead of creating duplicate.',
                        style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey[600], fontStyle: FontStyle.italic)),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text('Dismiss', style: GoogleFonts.outfit(color: Colors.grey[600])),
                  ),
                  if (existingId != null)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        context.push('/expenses/$existingId');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('View Existing', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
            );
          } else if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                content: Text(
                  state.errorMessage!,
                  style: GoogleFonts.outfit(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return _AddExpenseForm(
              isSaving: state.isSubmitting, expense: expense);
        },
      ),
    );
  }
}

class _AddExpenseForm extends StatefulWidget {
  final bool isSaving;
  final Expense? expense;

  const _AddExpenseForm({required this.isSaving, this.expense});

  @override
  State<_AddExpenseForm> createState() => _AddExpenseFormState();
}

class _AddExpenseFormState extends State<_AddExpenseForm> {
  final _formKey = GlobalKey<FormState>();

  final _vendorCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _clientCtrl = TextEditingController();
  final _projectCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DateTime? _selectedDate;
  _Category? _selectedCategory;
  String? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    final now = DateTime.now();
    _selectedDate = e?.date ?? now;
    _dateCtrl.text = _formatDate(_selectedDate!);
    _vendorCtrl.text = e?.vendor ?? '';
    _amountCtrl.text = e != null ? e.amount.toStringAsFixed(2) : '';
    _clientCtrl.text = e?.clientName ?? '';
    _projectCtrl.text = e?.projectName ?? '';
    _notesCtrl.text = e?.notes ?? '';
    _selectedPaymentMethod = e?.paymentMethod;
    // Guard: if the value isn't in the dropdown list, clear it so the
    // DropdownButtonFormField assertion doesn't fire.
    if (_selectedPaymentMethod != null &&
        !_paymentMethods.contains(_selectedPaymentMethod)) {
      _selectedPaymentMethod = null;
    }
    if (e?.categoryName != null) {
      _selectedCategory = _categories.firstWhere(
        (c) => c.name == e!.categoryName,
        orElse: () => _categories.last,
      );
    }
  }

  @override
  void dispose() {
    _vendorCtrl.dispose();
    _amountCtrl.dispose();
    _dateCtrl.dispose();
    _clientCtrl.dispose();
    _projectCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Theme.of(ctx).brightness == Brightness.dark
                  ? AppColors.surfaceDark
                  : AppColors.surfaceLight,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateCtrl.text = _formatDate(picked);
      });
    }
  }

  Expense _buildExpense() {
    final parsed = double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0.0;
    final now = DateTime.now();
    final base = widget.expense ??
        Expense(
          id: '',
          userId: '',
          vendor: '',
          amount: 0.0,
          currency: CurrencyService.resolveSync(),
          date: now,
          syncStatus: 'pending',
          createdAt: now,
          updatedAt: now,
        );
    return base.copyWith(
      vendor: _vendorCtrl.text.trim(),
      amount: parsed,
      date: _selectedDate ?? now,
      categoryName: _selectedCategory?.name,
      paymentMethod: _selectedPaymentMethod,
      clientName: _clientCtrl.text.trim(),
      projectName: _projectCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
      updatedAt: now,
    );
  }

  bool _isSubmittingLocally = false;

  void _save() {
    if (_isSubmittingLocally || widget.isSaving) return;
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmittingLocally = true);
    
    final bloc = context.read<ExpenseFormBloc>();
    bloc.add(ExpenseDraftUpdated(_buildExpense()));
    bloc.add(const SubmitExpenseForm());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppPageBar(
        title: widget.expense == null ? 'Add Expense' : 'Edit Expense',
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: textPrimary, size: 22),
          onPressed: () => context.safePop(AppRoutes.expenseList),
          tooltip: 'Close',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          children: [
            const AppSectionHeader(title: 'Expense information'),
            const SizedBox(height: 8),
            AppGroupedSurface(
              child: Column(
                children: [
                  _InputField(
                    controller: _vendorCtrl,
                    hintText: 'Vendor *',
                    prefixIcon: Icons.store_rounded,
                    isDark: isDark,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    surfaceColor: surfaceColor,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Vendor is required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  _AmountField(
                    controller: _amountCtrl,
                    isDark: isDark,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    surfaceColor: surfaceColor,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Amount is required';
                      }
                      final parsed = double.tryParse(v.replaceAll(',', ''));
                      return parsed == null || parsed <= 0
                          ? 'Enter a valid amount'
                          : null;
                    },
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _pickDate,
                    child: AbsorbPointer(
                      child: _InputField(
                        controller: _dateCtrl,
                        hintText: 'Date *',
                        prefixIcon: Icons.calendar_today_rounded,
                        isDark: isDark,
                        borderColor: borderColor,
                        textPrimary: textPrimary,
                        surfaceColor: surfaceColor,
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Date is required'
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _CategoryDropdown(
                    selected: _selectedCategory,
                    isDark: isDark,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    surfaceColor: surfaceColor,
                    onChanged: (c) => setState(() => _selectedCategory = c),
                    validator: (_) => _selectedCategory == null
                        ? 'Please select a category'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  _PaymentMethodDropdown(
                    selected: _selectedPaymentMethod,
                    isDark: isDark,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    surfaceColor: surfaceColor,
                    onChanged: (v) =>
                        setState(() => _selectedPaymentMethod = v),
                    validator: (_) => _selectedPaymentMethod == null
                        ? 'Please select a payment method'
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const AppSectionHeader(title: 'Business context'),
            const SizedBox(height: 8),
            AppGroupedSurface(
              child: Column(
                children: [
                  _InputField(
                    controller: _clientCtrl,
                    hintText: 'Client name (optional)',
                    prefixIcon: Icons.person_outline_rounded,
                    isDark: isDark,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    surfaceColor: surfaceColor,
                  ),
                  const SizedBox(height: 12),
                  _InputField(
                    controller: _projectCtrl,
                    hintText: 'Project name (optional)',
                    prefixIcon: Icons.folder_outlined,
                    isDark: isDark,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    surfaceColor: surfaceColor,
                  ),
                  const SizedBox(height: 12),
                  _NotesField(
                    controller: _notesCtrl,
                    isDark: isDark,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    surfaceColor: surfaceColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const AppSectionHeader(title: 'Receipt'),
            const SizedBox(height: 8),
            AppGroupedSurface(
              child: _ReceiptPhotoArea(
                isDark: isDark,
                borderColor: borderColor,
                textSecondary: textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: widget.expense == null ? 'Save Expense' : 'Update Expense',
              onPressed: _save,
              isLoading: widget.isSaving,
              icon: const Icon(Icons.check_rounded, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Generic input field
// ---------------------------------------------------------------------------
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool isDark;
  final Color borderColor;
  final Color textPrimary;
  final Color surfaceColor;
  final String? Function(String?)? validator;

  const _InputField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    required this.isDark,
    required this.borderColor,
    required this.textPrimary,
    required this.surfaceColor,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      decoration: _inputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
        isDark: isDark,
        borderColor: borderColor,
        surfaceColor: surfaceColor,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Amount field with $ prefix
// ---------------------------------------------------------------------------
class _AmountField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final Color borderColor;
  final Color textPrimary;
  final Color surfaceColor;
  final String? Function(String?)? validator;

  const _AmountField({
    required this.controller,
    required this.isDark,
    required this.borderColor,
    required this.textPrimary,
    required this.surfaceColor,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
      ],
      style: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      decoration: _inputDecoration(
        hintText: '0.00',
        prefixIcon: Icons.attach_money_rounded,
        isDark: isDark,
        borderColor: borderColor,
        surfaceColor: surfaceColor,
        prefix: Text(
          '${AppUtils.getCurrencySymbol(CurrencyService.resolveSync())} ',
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Category dropdown
// ---------------------------------------------------------------------------
class _CategoryDropdown extends StatelessWidget {
  final _Category? selected;
  final bool isDark;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color surfaceColor;
  final ValueChanged<_Category?> onChanged;
  final String? Function(dynamic)? validator;

  const _CategoryDropdown({
    required this.selected,
    required this.isDark,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.surfaceColor,
    required this.onChanged,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<_Category>(
      initialValue: selected,
      validator: validator,
      isExpanded: true,
      dropdownColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      decoration: _inputDecoration(
        hintText: 'Select category',
        prefixIcon: Icons.category_rounded,
        isDark: isDark,
        borderColor: borderColor,
        surfaceColor: surfaceColor,
      ),
      style: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      items: _categories.map((cat) {
        return DropdownMenuItem<_Category>(
          value: cat,
          child: Row(
            children: [
              Icon(cat.icon, color: cat.color, size: 18),
              const SizedBox(width: 10),
              Text(
                cat.name,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textPrimary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

// ---------------------------------------------------------------------------
// Payment method dropdown
// ---------------------------------------------------------------------------
class _PaymentMethodDropdown extends StatelessWidget {
  final String? selected;
  final bool isDark;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color surfaceColor;
  final ValueChanged<String?> onChanged;
  final String? Function(dynamic)? validator;

  const _PaymentMethodDropdown({
    required this.selected,
    required this.isDark,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.surfaceColor,
    required this.onChanged,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selected,
      validator: validator,
      isExpanded: true,
      dropdownColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      decoration: _inputDecoration(
        hintText: 'Select payment method',
        prefixIcon: Icons.credit_card_rounded,
        isDark: isDark,
        borderColor: borderColor,
        surfaceColor: surfaceColor,
      ),
      style: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      items: _paymentMethods.map((method) {
        return DropdownMenuItem<String>(
          value: method,
          child: Text(
            method,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textPrimary,
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

// ---------------------------------------------------------------------------
// Notes field (multiline)
// ---------------------------------------------------------------------------
class _NotesField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final Color borderColor;
  final Color textPrimary;
  final Color surfaceColor;

  const _NotesField({
    required this.controller,
    required this.isDark,
    required this.borderColor,
    required this.textPrimary,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: 3,
      style: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      decoration: InputDecoration(
        hintText: 'Add any notes or description...',
        hintStyle: GoogleFonts.outfit(
          fontSize: 14,
          color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
        ),
        filled: true,
        fillColor: surfaceColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Receipt photo area (dashed border)
// ---------------------------------------------------------------------------
class _ReceiptPhotoArea extends StatelessWidget {
  final bool isDark;
  final Color borderColor;
  final Color textSecondary;

  const _ReceiptPhotoArea({
    required this.isDark,
    required this.borderColor,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor:
              isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (bottomSheetContext) => SafeArea(
            child: Wrap(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Text(
                    'Add Receipt',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_rounded,
                      color: AppColors.primary),
                  title: Text(
                    'Take a Photo',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);
                    final picker = ImagePicker();
                    final picked =
                        await picker.pickImage(source: ImageSource.camera);
                    if (picked != null && context.mounted) {
                      context.push(AppRoutes.receiptCrop, extra: picked.path);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded,
                      color: AppColors.primary),
                  title: Text(
                    'Choose from Gallery',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);
                    final picker = ImagePicker();
                    final picked =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (picked != null && context.mounted) {
                      context.push(AppRoutes.receiptCrop, extra: picked.path);
                    }
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        child: Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceVariantDark.withValues(alpha: 0.5)
                : AppColors.surfaceVariantLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Take Photo or Choose from Gallery',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'JPEG, PNG up to 10MB',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dashed border painter
// ---------------------------------------------------------------------------
class _DashedBorderPainter extends CustomPainter {
  final Color color;

  const _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    const strokeWidth = 1.5;
    const radius = 16.0;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(radius),
    );

    final path = Path()..addRRect(rect);
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}

// ---------------------------------------------------------------------------
// Shared InputDecoration builder
// ---------------------------------------------------------------------------
InputDecoration _inputDecoration({
  required String hintText,
  required IconData prefixIcon,
  required bool isDark,
  required Color borderColor,
  required Color surfaceColor,
  Widget? prefix,
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: GoogleFonts.outfit(
      fontSize: 14,
      color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
    ),
    prefixIcon: Icon(
      prefixIcon,
      color: AppColors.primary,
      size: 20,
    ),
    prefix: prefix,
    filled: true,
    fillColor: surfaceColor,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: borderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    ),
  );
}
