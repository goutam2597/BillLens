import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:billlens/core/router/app_routes.dart';
import 'package:billlens/core/router/context_ext.dart';
import 'package:billlens/core/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Expense Details Page
// ---------------------------------------------------------------------------
class ExpenseDetailsPage extends StatelessWidget {
  final String expenseId;

  const ExpenseDetailsPage({super.key, required this.expenseId});

  // Dummy data resolved by id
  Map<String, String> get _data => {
        'vendor': 'Starbucks',
        'amount': '\$12.50',
        'date': '09 Jul 2026',
        'category': 'Client Meeting',
        'paymentMethod': 'Corporate Card',
        'notes': 'Client coffee meeting with John D. — discussed Q3 roadmap.',
        'confidence': '95',
        'sync': 'Synced',
      };

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
    final d = _data;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Colors.white, size: 20),
          onPressed: () => context.safePop(AppRoutes.expenseList),
        ),
        title: Text(
          d['vendor']!,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded,
                color: Colors.white, size: 22),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Gradient header card ─────────────────────────────────────
            _HeaderCard(
              vendor: d['vendor']!,
              amount: d['amount']!,
              date: d['date']!,
              category: d['category']!,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Receipt Image placeholder ──────────────────────────
                  _ReceiptImagePlaceholder(isDark: isDark),
                  const SizedBox(height: 16),
                  // ── Details card ───────────────────────────────────────
                  _DetailsCard(
                    data: d,
                    isDark: isDark,
                    surfaceColor: surfaceColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    borderColor: borderColor,
                  ),
                  const SizedBox(height: 16),
                  // ── AI Confidence ──────────────────────────────────────
                  _AIConfidenceCard(
                    confidence: double.parse(d['confidence']!),
                    isDark: isDark,
                    surfaceColor: surfaceColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    borderColor: borderColor,
                  ),
                  const SizedBox(height: 16),
                  // ── Sync chip ──────────────────────────────────────────
                  _SyncChip(syncStatus: d['sync']!),
                  const SizedBox(height: 24),
                  // ── Action buttons ─────────────────────────────────────
                  _ActionButtons(
                    isDark: isDark,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    onEdit: () {},
                    onDelete: () => _confirmDelete(context),
                    onShare: () {},
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
              context.safePop(AppRoutes.expenseList);
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
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.cardGradient,
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            vendor,
            style: GoogleFonts.outfit(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: GoogleFonts.outfit(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded,
                  color: Colors.white60, size: 13),
              const SizedBox(width: 4),
              Text(
                date,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.white70,
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

  const _ReceiptImagePlaceholder({required this.isDark});

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_rounded,
            size: 48,
            color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
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
              color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
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
  final Map<String, String> data;
  final bool isDark;
  final Color surfaceColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color borderColor;

  const _DetailsCard({
    required this.data,
    required this.isDark,
    required this.surfaceColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final rows = [
      {'label': 'Vendor', 'value': data['vendor']!},
      {'label': 'Amount', 'value': data['amount']!},
      {'label': 'Date', 'value': data['date']!},
      {'label': 'Category', 'value': data['category']!},
      {'label': 'Payment Method', 'value': data['paymentMethod']!},
      {'label': 'Notes', 'value': data['notes']!},
    ];

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow:
            isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Text(
              'Expense Details',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
          ),
          Divider(height: 1, color: borderColor),
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
  final bool isDark;
  final Color surfaceColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color borderColor;

  const _AIConfidenceCard({
    required this.confidence,
    required this.isDark,
    required this.surfaceColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final pct = confidence / 100;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow:
            isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
      ),
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
            'High confidence — all fields extracted successfully.',
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accentSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x4D10B981)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: AppColors.syncSynced,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            syncStatus,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.accentDark,
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
