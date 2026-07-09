import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:billlens/core/theme/app_colors.dart';

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
// Add Expense Page
// ---------------------------------------------------------------------------
class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _vendorCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _clientCtrl = TextEditingController();
  final _projectCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // State
  DateTime? _selectedDate;
  _Category? _selectedCategory;
  String? _selectedPaymentMethod;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = now;
    _dateCtrl.text = _formatDate(now);
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.accent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              'Expense saved successfully!',
              style: GoogleFonts.outfit(
                  color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
    Navigator.of(context).pop();
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
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: textPrimary, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Add Expense',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: borderColor),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
          children: [
            // ── Vendor ──────────────────────────────────────────────────
            _SectionLabel(label: 'Vendor *', textSecondary: textSecondary),
            const SizedBox(height: 8),
            _InputField(
              controller: _vendorCtrl,
              hintText: 'e.g. Starbucks, Amazon',
              prefixIcon: Icons.store_rounded,
              isDark: isDark,
              borderColor: borderColor,
              textPrimary: textPrimary,
              surfaceColor: surfaceColor,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Vendor is required' : null,
            ),
            const SizedBox(height: 16),

            // ── Amount ──────────────────────────────────────────────────
            _SectionLabel(label: 'Amount *', textSecondary: textSecondary),
            const SizedBox(height: 8),
            _AmountField(
              controller: _amountCtrl,
              isDark: isDark,
              borderColor: borderColor,
              textPrimary: textPrimary,
              surfaceColor: surfaceColor,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Amount is required';
                final parsed = double.tryParse(v.replaceAll(',', ''));
                if (parsed == null || parsed <= 0) {
                  return 'Enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ── Date ────────────────────────────────────────────────────
            _SectionLabel(label: 'Date *', textSecondary: textSecondary),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: AbsorbPointer(
                child: _InputField(
                  controller: _dateCtrl,
                  hintText: 'Select date',
                  prefixIcon: Icons.calendar_today_rounded,
                  isDark: isDark,
                  borderColor: borderColor,
                  textPrimary: textPrimary,
                  surfaceColor: surfaceColor,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Date is required' : null,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Category ────────────────────────────────────────────────
            _SectionLabel(label: 'Category *', textSecondary: textSecondary),
            const SizedBox(height: 8),
            _CategoryDropdown(
              selected: _selectedCategory,
              isDark: isDark,
              borderColor: borderColor,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              surfaceColor: surfaceColor,
              onChanged: (c) => setState(() => _selectedCategory = c),
              validator: (_) =>
                  _selectedCategory == null ? 'Please select a category' : null,
            ),
            const SizedBox(height: 16),

            // ── Payment Method ──────────────────────────────────────────
            _SectionLabel(
                label: 'Payment Method *', textSecondary: textSecondary),
            const SizedBox(height: 8),
            _PaymentMethodDropdown(
              selected: _selectedPaymentMethod,
              isDark: isDark,
              borderColor: borderColor,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              surfaceColor: surfaceColor,
              onChanged: (v) => setState(() => _selectedPaymentMethod = v),
              validator: (_) => _selectedPaymentMethod == null
                  ? 'Please select a payment method'
                  : null,
            ),
            const SizedBox(height: 16),

            // ── Client Name (optional) ──────────────────────────────────
            _SectionLabel(
                label: 'Client Name (optional)', textSecondary: textSecondary),
            const SizedBox(height: 8),
            _InputField(
              controller: _clientCtrl,
              hintText: 'e.g. Acme Corp',
              prefixIcon: Icons.person_outline_rounded,
              isDark: isDark,
              borderColor: borderColor,
              textPrimary: textPrimary,
              surfaceColor: surfaceColor,
            ),
            const SizedBox(height: 16),

            // ── Project Name (optional) ─────────────────────────────────
            _SectionLabel(
                label: 'Project Name (optional)', textSecondary: textSecondary),
            const SizedBox(height: 8),
            _InputField(
              controller: _projectCtrl,
              hintText: 'e.g. Q3 Campaign',
              prefixIcon: Icons.folder_outlined,
              isDark: isDark,
              borderColor: borderColor,
              textPrimary: textPrimary,
              surfaceColor: surfaceColor,
            ),
            const SizedBox(height: 16),

            // ── Notes (optional) ────────────────────────────────────────
            _SectionLabel(
                label: 'Notes (optional)', textSecondary: textSecondary),
            const SizedBox(height: 8),
            _NotesField(
              controller: _notesCtrl,
              isDark: isDark,
              borderColor: borderColor,
              textPrimary: textPrimary,
              surfaceColor: surfaceColor,
            ),
            const SizedBox(height: 20),

            // ── Receipt Photo area ───────────────────────────────────────
            _SectionLabel(label: 'Receipt Photo', textSecondary: textSecondary),
            const SizedBox(height: 8),
            _ReceiptPhotoArea(
              isDark: isDark,
              borderColor: borderColor,
              textSecondary: textSecondary,
            ),
            const SizedBox(height: 32),

            // ── Save button ─────────────────────────────────────────────
            _SaveButton(isSaving: _isSaving, onSave: _save),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section label
// ---------------------------------------------------------------------------
class _SectionLabel extends StatelessWidget {
  final String label;
  final Color textSecondary;

  const _SectionLabel({required this.label, required this.textSecondary});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: textSecondary,
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
          '\$ ',
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
      onTap: () {},
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
// Save button (gradient)
// ---------------------------------------------------------------------------
class _SaveButton extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onSave;

  const _SaveButton({required this.isSaving, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSaving ? null : onSave,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: isSaving
              ? const LinearGradient(
                  colors: [Color(0xFF93C5FD), Color(0xFF6EE7B7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSaving ? [] : AppColors.primaryShadow,
        ),
        child: Center(
          child: isSaving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  'Save Expense',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
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
