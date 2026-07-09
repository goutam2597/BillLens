import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:billlens/core/theme/app_colors.dart';
import 'package:billlens/core/router/app_routes.dart';

// ---------------------------------------------------------------------------
// Model used only within the dashboard (no external dependency)
// ---------------------------------------------------------------------------
class ExpenseItem {
  final String vendor;
  final String category;
  final String amount;
  final String date;
  final IconData icon;
  final Color iconColor;

  const ExpenseItem({
    required this.vendor,
    required this.category,
    required this.amount,
    required this.date,
    required this.icon,
    required this.iconColor,
  });
}

// ---------------------------------------------------------------------------
// Dummy data
// ---------------------------------------------------------------------------
const List<ExpenseItem> _recentExpenses = [
  ExpenseItem(
    vendor: 'Starbucks',
    category: 'Client Meeting',
    amount: '\$12.50',
    date: '09 Jul 2026',
    icon: Icons.local_cafe_rounded,
    iconColor: Color(0xFF6F4E37),
  ),
  ExpenseItem(
    vendor: 'Uber',
    category: 'Travel',
    amount: '\$25.00',
    date: '08 Jul 2026',
    icon: Icons.directions_car_rounded,
    iconColor: Color(0xFF1E293B),
  ),
  ExpenseItem(
    vendor: 'Staples',
    category: 'Office Supplies',
    amount: '\$75.00',
    date: '07 Jul 2026',
    icon: Icons.inventory_2_rounded,
    iconColor: Color(0xFFEF4444),
  ),
  ExpenseItem(
    vendor: 'Amazon',
    category: 'Software',
    amount: '\$49.99',
    date: '06 Jul 2026',
    icon: Icons.shopping_bag_rounded,
    iconColor: Color(0xFFF59E0B),
  ),
];

// ---------------------------------------------------------------------------
// Dashboard Page
// ---------------------------------------------------------------------------
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

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
      body: _HomeTab(
        isDark: isDark,
        bgColor: bgColor,
        surfaceColor: surfaceColor,
        textPrimary: textPrimary,
        textSecondary: textSecondary,
        borderColor: borderColor,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Home Tab
// ---------------------------------------------------------------------------
class _HomeTab extends StatelessWidget {
  final bool isDark;
  final Color bgColor;
  final Color surfaceColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color borderColor;

  const _HomeTab({
    required this.isDark,
    required this.bgColor,
    required this.surfaceColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildMonthlySummaryCard(),
                  const SizedBox(height: 20),
                  _buildQuickActions(context),
                  const SizedBox(height: 24),
                  _buildRecentExpensesHeader(context),
                  const SizedBox(height: 12),
                  ..._recentExpenses.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ExpenseCard(
                        expense: e,
                        isDark: isDark,
                        surfaceColor: surfaceColor,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        borderColor: borderColor,
                        onTap: () => context.go('/expenses/1'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSyncChip(),
                  const SizedBox(height: 12),
                  _buildAdBanner(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: surfaceColor,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, Goutam 👋',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Wednesday, 9 July 2026',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.surfaceVariantLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.notifications_rounded,
                  color: textPrimary,
                  size: 22,
                ),
                Positioned(
                  top: 9,
                  right: 9,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlySummaryCard() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.primaryShadow,
      ),
      child: Stack(
        children: [
          // Background decorative icons
          const Positioned(
            right: -20,
            top: -20,
            child: Opacity(
              opacity: 0.06,
              child: Icon(
                Icons.receipt_long_rounded,
                size: 160,
                color: Colors.white,
              ),
            ),
          ),
          const Positioned(
            right: 60,
            bottom: -30,
            child: Opacity(
              opacity: 0.04,
              child: Icon(
                Icons.bar_chart_rounded,
                size: 120,
                color: Colors.white,
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly Expenses',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white60,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$2,450.00',
                  style: GoogleFonts.outfit(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                Text(
                  'July 2026',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                  ),
                ),
                const Spacer(),
                const Row(
                  children: [
                    _MiniStat(label: 'Income', value: '\$5,200'),
                    SizedBox(width: 10),
                    _MiniStat(label: 'Balance', value: '\$2,750'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.document_scanner_rounded,
                label: 'Scan Receipt',
                gradient: AppColors.cardGradient,
                onTap: () => context.go(AppRoutes.receiptScanner),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.upload_rounded,
                label: 'Upload',
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () {},
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.edit_rounded,
                label: 'Add Manual',
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () => context.go(AppRoutes.addExpense),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentExpensesHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Recent Expenses',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        TextButton(
          onPressed: () => context.go(AppRoutes.expenseList),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'See All',
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSyncChip() {
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
            'Synced',
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

  Widget _buildAdBanner() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceVariantDark
            : AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        'Advertisement',
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mini Stat Widget (inside Monthly Summary Card)
// ---------------------------------------------------------------------------
class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x26FFFFFF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label ',
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: Colors.white70,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quick Action Card
// ---------------------------------------------------------------------------
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 88,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000).withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(gradient: gradient),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 26),
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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

// ---------------------------------------------------------------------------
// Expense Card (exported for use in other pages)
// ---------------------------------------------------------------------------
class ExpenseCard extends StatelessWidget {
  final ExpenseItem expense;
  final bool isDark;
  final Color surfaceColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color borderColor;
  final VoidCallback onTap;

  const ExpenseCard({
    super.key,
    required this.expense,
    required this.isDark,
    required this.surfaceColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
          boxShadow:
              isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
        ),
        child: Row(
          children: [
            // Icon circle
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: expense.iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(expense.icon, color: expense.iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            // Vendor + category
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.vendor,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    expense.category,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Amount + date
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  expense.amount,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  expense.date,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
