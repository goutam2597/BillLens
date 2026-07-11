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
import 'package:billlens/core/widgets/delete_confirmation_dialog.dart';
import 'package:billlens/features/expenses/domain/entities/expense.dart';
import 'package:billlens/features/expenses/presentation/bloc/expense_bloc.dart';
import 'package:billlens/features/expenses/presentation/bloc/expense_details_bloc.dart';
import 'package:billlens/features/expenses/presentation/helpers/expense_ui_helper.dart';
import 'package:billlens/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:billlens/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:billlens/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:billlens/features/analytics/presentation/bloc/analytics_event.dart';

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
            context.read<ExpenseBloc>().add(const LoadExpensesRequested());
            context.read<DashboardBloc>().add(LoadDashboardData());
            context.read<AnalyticsBloc>().add(LoadAnalytics());
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

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDeleteConfirmationDialog(
      context: context,
      title: 'Delete Expense?',
      message:
          'Are you sure you want to delete this expense? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
    );
    if (confirmed && context.mounted) {
      if (expense != null) {
        context
            .read<ExpenseDetailsBloc>()
            .add(DeleteExpenseDetailsRequested(expense!.id));
      } else {
        context.safePop(AppRoutes.expenseList);
      }
    }
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
            icon: const Icon(Icons.delete_outline_rounded,
                size: 22, color: AppColors.error),
            onPressed: () => _confirmDelete(context),
            tooltip: 'Delete expense',
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
          : Stack(
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
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
                      _ReceiptImageCard(
                        isDark: isDark,
                        localPath: expense!.receiptImageLocalPath,
                        remoteUrl: expense!.receiptImageRemoteUrl,
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
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          bgColor.withValues(alpha: 0.0),
                          bgColor,
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                    child: _ActionButtons(
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
                  ),
                ),
              ],
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
// Receipt Image Card
// ---------------------------------------------------------------------------
class _ReceiptImageCard extends StatelessWidget {
  final bool isDark;
  final String? localPath;
  final String? remoteUrl;

  const _ReceiptImageCard({
    required this.isDark,
    this.localPath,
    this.remoteUrl,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasLocalImage = localPath != null && localPath!.isNotEmpty;
    final fullRemoteUrl = AppUtils.receiptImageUrl(remoteUrl);
    final hasRemoteImage = fullRemoteUrl.isNotEmpty;
    final hasImage = hasLocalImage || hasRemoteImage;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 420),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: !hasImage
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.receipt_long_rounded,
                      size: 28,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No receipt image',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'A receipt photo was not attached to this expense.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              )
            : GestureDetector(
                onTap: () => _openFullScreenImage(context, fullRemoteUrl, localPath),
                child: hasLocalImage
                    ? Image.file(
                        File(localPath!),
                        fit: BoxFit.contain,
                        width: double.infinity,
                      )
                    : Image.network(
                        fullRemoteUrl,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: AppColors.primary,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('Receipt image load error: $error');
                          debugPrint('Receipt image URL: $fullRemoteUrl');
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image_outlined,
                                size: 40,
                                color: colorScheme.error,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Could not load receipt image',
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
      ),
    );
  }

  void _openFullScreenImage(BuildContext context, String remoteUrl, String? localPath) {
    final hasLocalImage = localPath != null && localPath.isNotEmpty;
    final imageWidget = hasLocalImage
        ? Image.file(File(localPath))
        : Image.network(remoteUrl, fit: BoxFit.contain);

    showDialog(
      context: context,
      useSafeArea: false,
      builder: (_) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(child: imageWidget),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
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
    final colorScheme = Theme.of(context).colorScheme;
    final rows = [
      _DetailItem(
        label: 'Vendor',
        value: expense.vendor,
        icon: Icons.storefront_outlined,
        iconColor: colorScheme.primary,
      ),
      _DetailItem(
        label: 'Amount',
        value: AppUtils.formatCurrency(expense.amount, currency: expense.currency),
        icon: Icons.account_balance_wallet_outlined,
        iconColor: const Color(0xFF10B981),
      ),
      _DetailItem(
        label: 'Date',
        value: formatExpenseDate(expense.date),
        icon: Icons.calendar_today_outlined,
        iconColor: const Color(0xFFF59E0B),
      ),
      _DetailItem(
        label: 'Category',
        value: expense.categoryName ?? 'Uncategorized',
        icon: Icons.label_outline_rounded,
        iconColor: const Color(0xFF7C3AED),
      ),
      _DetailItem(
        label: 'Payment Method',
        value: expense.paymentMethod ?? '—',
        icon: Icons.credit_card_outlined,
        iconColor: const Color(0xFF2563EB),
      ),
      _DetailItem(
        label: 'Client',
        value: expense.clientName ?? '—',
        icon: Icons.person_outline_rounded,
        iconColor: const Color(0xFFEC4899),
      ),
      _DetailItem(
        label: 'Project',
        value: expense.projectName ?? '—',
        icon: Icons.folder_open_outlined,
        iconColor: const Color(0xFF6366F1),
      ),
      _DetailItem(
        label: 'Notes',
        value: expense.notes ?? '—',
        icon: Icons.notes_rounded,
        iconColor: const Color(0xFF64748B),
      ),
    ];

    return AppGroupedSurface(
      padding: const EdgeInsets.all(8),
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
                  item: row,
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

class _DetailItem {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _DetailItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });
}

class _DetailRow extends StatelessWidget {
  final _DetailItem item;
  final Color textPrimary;
  final Color textSecondary;

  const _DetailRow({
    required this.item,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: item.iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              item.icon,
              size: 18,
              color: item.iconColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.value,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
              ],
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
    final pct = confidence.clamp(0.0, 1.0);
    final confidencePercent = (pct * 100).round();
    return AppGroupedSurface(
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.accent,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'AI Extraction Confidence',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$confidencePercent%',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 12),
          Text(
            explanation?.isNotEmpty == true
                ? explanation!
                : (confidencePercent >= 80
                    ? 'High confidence — all fields extracted successfully.'
                    : 'Low confidence — please verify the extracted fields.'),
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: textSecondary,
              height: 1.5,
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
