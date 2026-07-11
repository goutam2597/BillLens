import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:billlens/core/di/injection.dart';
import 'package:billlens/core/router/app_routes.dart';
import 'package:billlens/core/router/context_ext.dart';
import 'package:billlens/core/theme/app_colors.dart';
import 'package:billlens/core/utils/app_utils.dart';
import 'package:billlens/core/widgets/app_widgets.dart';
import 'package:billlens/features/expenses/domain/entities/expense.dart';
import 'package:billlens/features/expenses/presentation/bloc/expense_details_bloc.dart';
import 'package:billlens/features/expenses/presentation/helpers/expense_ui_helper.dart';

// ---------------------------------------------------------------------------
// Expense Details Page
// ---------------------------------------------------------------------------
class ExpenseDetailsPage extends StatelessWidget {
  final String expenseId;

  const ExpenseDetailsPage({super.key, required this.expenseId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ExpenseDetailsBloc>(
      create: (_) => getIt<ExpenseDetailsBloc>()
        ..add(LoadExpenseDetailsRequested(expenseId)),
      child: BlocConsumer<ExpenseDetailsBloc, ExpenseDetailsState>(
        listener: (context, state) {
          if (state is ExpenseDetailsDeleted) {
            context.safePop(AppRoutes.expenseList);
          } else if (state is ExpenseDetailsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                content: Text(
                  state.message,
                  style: GoogleFonts.outfit(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ExpenseDetailsLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }
          final expense = state is ExpenseDetailsLoaded ? state.expense : null;
          return _ExpenseDetailsView(expense: expense);
        },
      ),
    );
  }
}

class _ExpenseDetailsView extends StatelessWidget {
  final Expense? expense;

  const _ExpenseDetailsView({required this.expense});

  void _confirmDelete(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Expense',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            color:
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this expense? This action cannot be undone.',
          style: GoogleFonts.outfit(
            fontSize: 14,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (expense != null) {
                context
                    .read<ExpenseDetailsBloc>()
                    .add(DeleteExpenseDetailsRequested(expense!.id));
              } else {
                context.safePop(AppRoutes.expenseList);
              }
            },
            child: Text(
              'Delete',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
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

    final vendor = expense?.vendor ?? 'Expense';
    final categoryName = expense?.categoryName ?? 'Uncategorized';
    final amount = expense != null
        ? AppUtils.formatCurrency(expense!.amount, currency: expense!.currency)
        : AppUtils.formatCurrency(0.0);
    final date = expense != null ? formatExpenseDate(expense!.date) : '';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppPageBar(
        title: vendor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 22),
          onPressed: () => context.safePop(AppRoutes.expenseList),
          tooltip: 'Back',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, size: 22),
            onPressed: () {},
            tooltip: 'More options',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: expense == null
          ? Center(
              child: Text(
                'Expense not found',
                style: GoogleFonts.outfit(color: textSecondary, fontSize: 15),
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderCard(
                    vendor: vendor,
                    amount: amount,
                    date: date,
                    category: categoryName,
                  ),
                  const SizedBox(height: 24),
                  const AppSectionHeader(title: 'Receipt'),
                  const SizedBox(height: 8),
                  _ReceiptImagePlaceholder(
                    isDark: isDark,
                    localPath: expense!.receiptImageLocalPath,
                  ),
                  const SizedBox(height: 24),
                  const AppSectionHeader(title: 'Expense details'),
                  const SizedBox(height: 8),
                  _DetailsCard(
                    expense: expense!,
                    isDark: isDark,
                    surfaceColor: surfaceColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    borderColor: borderColor,
                  ),
                  if (expense!.aiConfidence != null) ...[
                    const SizedBox(height: 24),
                    const AppSectionHeader(title: 'AI extraction'),
                    const SizedBox(height: 8),
                    _AIConfidenceCard(
                      confidence: expense!.aiConfidence!,
                      explanation: expense!.aiExplanation,
                      isDark: isDark,
                      surfaceColor: surfaceColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      borderColor: borderColor,
                    ),
                  ],
                  const SizedBox(height: 16),
                  _SyncChip(syncStatus: expense!.syncStatus),
                  const SizedBox(height: 24),
                  _ActionButtons(
                    isDark: isDark,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    onEdit: () => context.push(
                      '/expenses/${expense!.id}/edit',
                      extra: expense,
                    ),
                    onDelete: () => _confirmDelete(context),
                    onShare: () {},
                  ),
                ],
              ),
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header Card (gradient)
// ---------------------------------------------------------------------------
class _HeaderCard extends StatelessWidget {
  final String vendor;
  final String amount;
  final String date;
  final String category;

  const _HeaderCard({
    required this.vendor,
    required this.amount,
    required this.date,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppGroupedSurface(
      borderColor: AppColors.primary.withValues(alpha: 0.24),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  category,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            vendor,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            amount,
            style: GoogleFonts.outfit(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  color: colorScheme.onSurfaceVariant, size: 13),
              const SizedBox(width: 4),
              Text(
                date,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Receipt Image Placeholder
// ---------------------------------------------------------------------------
class _ReceiptImagePlaceholder extends StatelessWidget {
  final bool isDark;
  final String? localPath;

  const _ReceiptImagePlaceholder({required this.isDark, this.localPath});

  @override
  Widget build(BuildContext context) {
    final hasImage = localPath != null && localPath!.isNotEmpty;
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceVariantDark
            : AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: hasImage
          ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(localPath!),
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt_rounded,
                  size: 48,
                  color:
                      isDark ? AppColors.textHintDark : AppColors.textHintLight,
                ),
                const SizedBox(height: 8),
                Text(
                  'Receipt Photo',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap to view full image',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textHintDark
                        : AppColors.textHintLight,
                  ),
                ),
              ],
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Details Card
// ---------------------------------------------------------------------------
class _DetailsCard extends StatelessWidget {
  final Expense expense;
  final bool isDark;
  final Color surfaceColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color borderColor;

  const _DetailsCard({
    required this.expense,
    required this.isDark,
    required this.surfaceColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final rows = [
      {'label': 'Vendor', 'value': expense.vendor},
      {'label': 'Amount', 'value': AppUtils.formatCurrency(expense.amount, currency: expense.currency)},
      {'label': 'Date', 'value': formatExpenseDate(expense.date)},
      {'label': 'Category', 'value': expense.categoryName ?? 'Uncategorized'},
      {'label': 'Payment Method', 'value': expense.paymentMethod ?? '—'},
      {'label': 'Client', 'value': expense.clientName ?? '—'},
      {'label': 'Project', 'value': expense.projectName ?? '—'},
      {'label': 'Notes', 'value': expense.notes ?? '—'},
    ];

    return AppGroupedSurface(
      padding: EdgeInsets.zero,
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...rows.asMap().entries.map((entry) {
            final i = entry.key;
            final row = entry.value;
            return Column(
              children: [
                _DetailRow(
                  label: row['label']!,
                  value: row['value']!,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
                if (i < rows.length - 1) Divider(height: 1, color: borderColor),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color textPrimary;
  final Color textSecondary;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// AI Confidence Card
// ---------------------------------------------------------------------------
class _AIConfidenceCard extends StatelessWidget {
  final double confidence;
  final String? explanation;
  final bool isDark;
  final Color surfaceColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color borderColor;

  const _AIConfidenceCard({
    required this.confidence,
    required this.explanation,
    required this.isDark,
    required this.surfaceColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final pct = confidence / 100;
    return AppGroupedSurface(
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  color: AppColors.accent, size: 18),
              const SizedBox(width: 8),
              Text(
                'AI Extraction Confidence',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${confidence.toInt()}%',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.surfaceVariantLight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            explanation?.isNotEmpty == true
                ? explanation!
                : (confidence >= 80
                    ? 'High confidence — all fields extracted successfully.'
                    : 'Low confidence — please verify the extracted fields.'),
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sync chip
// ---------------------------------------------------------------------------
class _SyncChip extends StatelessWidget {
  final String syncStatus;

  const _SyncChip({required this.syncStatus});

  @override
  Widget build(BuildContext context) {
    final color = syncStatusColor(syncStatus);
    final label = syncStatusLabel(syncStatus);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action buttons row
// ---------------------------------------------------------------------------
class _ActionButtons extends StatelessWidget {
  final bool isDark;
  final Color borderColor;
  final Color textPrimary;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onShare;

  const _ActionButtons({
    required this.isDark,
    required this.borderColor,
    required this.textPrimary,
    required this.onEdit,
    required this.onDelete,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_rounded, size: 16),
            label: Text(
              'Edit',
              style:
                  GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded, size: 16),
            label: Text(
              'Delete',
              style:
                  GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onShare,
            icon: const Icon(Icons.share_rounded, size: 16),
            label: Text(
              'Share',
              style:
                  GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: textPrimary,
              side: BorderSide(color: borderColor),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
