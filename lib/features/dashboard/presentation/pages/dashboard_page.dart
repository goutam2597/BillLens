import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:billlens/core/theme/app_colors.dart';
import 'package:billlens/core/router/app_routes.dart';
import 'package:billlens/core/utils/app_utils.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../../../expenses/presentation/helpers/expense_ui_helper.dart'
    show categoryMeta;

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
    context.read<DashboardBloc>().add(LoadDashboardData());
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedSlideUp(Widget child, int index) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final delay = (index * 0.1).clamp(0.0, 1.0);
        final curvedValue = CurvedAnimation(
          parent: _animController,
          curve: Interval(delay, math.min(1.0, delay + 0.5),
              curve: Curves.easeOutCubic),
        ).value;
        return Opacity(
          opacity: curvedValue,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - curvedValue)),
            child: child,
          ),
        );
      },
      child: child,
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

    return Scaffold(
      backgroundColor: bgColor,
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<DashboardBloc>().add(LoadDashboardData());
              _animController.forward(from: 0.0);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildAppBar(context, surfaceColor, textPrimary, textSecondary),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        const SizedBox(height: 12),
                        _buildAnimatedSlideUp(
                            _buildMonthlySummaryCard(state), 1),
                        const SizedBox(height: 20),
                        _buildAnimatedSlideUp(_buildQuickActions(context), 2),
                        const SizedBox(height: 28),
                        _buildAnimatedSlideUp(
                            _buildRecentExpensesHeader(context, textPrimary),
                            3),
                        const SizedBox(height: 8),
                        if (state is DashboardLoaded) ...[
                          if (state.recentExpenses.isEmpty)
                            _buildAnimatedSlideUp(
                                _buildEmptyState(textSecondary), 4)
                          else
                            ...state.recentExpenses.asMap().entries.map(
                                  (entry) => _buildAnimatedSlideUp(
                                    Padding(
                                      padding: EdgeInsets.zero,
                                      child: ExpenseCard(
                                        expense: entry.value,
                                        isDark: isDark,
                                        surfaceColor: surfaceColor,
                                        textPrimary: textPrimary,
                                        textSecondary: textSecondary,
                                        borderColor: borderColor,
                                        onTap: () => context.push(
                                            '/expenses/${entry.value.id}'),
                                      ),
                                    ),
                                    4 + entry.key,
                                  ),
                                ),
                        ] else if (state is DashboardLoading)
                          ...List.generate(
                              3,
                              (index) => _buildAnimatedSlideUp(
                                  _buildSkeletonCard(surfaceColor, borderColor),
                                  4 + index)),
                        const SizedBox(height: 24),
                        _buildAnimatedSlideUp(
                            _buildAdBanner(isDark, textSecondary), 9),
                        const SizedBox(height: 150),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _greetingFor(DateTime dateTime) {
    if (dateTime.hour < 12) return 'Good morning';
    if (dateTime.hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  SliverAppBar _buildAppBar(BuildContext context, Color surfaceColor,
      Color textPrimary, Color textSecondary) {
    return SliverAppBar(
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: surfaceColor,
      foregroundColor: textPrimary,
      surfaceTintColor: surfaceColor,
      elevation: 2,
      scrolledUnderElevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      toolbarHeight: kToolbarHeight,
      titleSpacing: 16,
      title: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final user = authState is Authenticated ? authState.user : null;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _greetingFor(DateTime.now()),
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: textSecondary,
                ),
              ),
              Text(
                user?.displayName ?? 'User',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        IconButton(
          tooltip: 'Notifications',
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildMonthlySummaryCard(DashboardState state) {
    final isLoaded = state is DashboardLoaded;
    final total = isLoaded ? state.monthlyTotal : 0.0;
    final count = isLoaded ? state.expenseCount : 0;
    final average = count == 0 ? 0.0 : total / count;
    final now = DateTime.now();
    final monthStr = DateFormat('MMMM yyyy').format(now);

    return Container(
      width: double.infinity,
      height: 196,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.primaryShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Spent this month',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  monthStr,
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
            AppUtils.formatCurrency(total),
            style: GoogleFonts.outfit(
              fontSize: 38,
              height: 1,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: _SummaryStat(
                  icon: Icons.receipt_long_outlined,
                  value: '$count',
                  label: count == 1 ? 'expense' : 'expenses',
                  color: Colors.white,
                ),
              ),
              Expanded(
                child: _SummaryStat(
                  icon: Icons.analytics_outlined,
                  value: AppUtils.formatCurrency(average),
                  label: 'average',
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PrimaryActionButton(
          onTap: () => context.push(AppRoutes.receiptScanner),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _ActionItem(
                icon: Icons.edit_note_rounded,
                label: 'Manual',
                onTap: () => context.push(AppRoutes.addExpense),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ActionItem(
                icon: Icons.upload_file_rounded,
                label: 'Upload',
                onTap: () => context.push(AppRoutes.receiptScanner),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ActionItem(
                icon: Icons.pie_chart_outline_rounded,
                label: 'Reports',
                onTap: () => context.push(AppRoutes.reports),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentExpensesHeader(BuildContext context, Color textPrimary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'Recent Activity',
          style: GoogleFonts.outfit(
              fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary),
        ),
        GestureDetector(
          onTap: () => context.go(AppRoutes.expenseList),
          child: Text(
            'See All',
            style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildAdBanner(bool isDark, Color textSecondary) {
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    return GestureDetector(
      onTap: () => context.push(AppRoutes.subscription),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            const Icon(Icons.workspace_premium_outlined,
                color: AppColors.primary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BillLens Pro',
                    style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textSecondary),
                  ),
                  Text(
                    'Unlock unlimited AI scans',
                    style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color subTextColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: subTextColor.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.receipt_long_outlined,
                size: 36, color: subTextColor.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 20),
          Text(
            'No recent activity',
            style: GoogleFonts.outfit(
                fontSize: 16, fontWeight: FontWeight.w600, color: subTextColor),
          ),
          const SizedBox(height: 4),
          Text(
            'Scan your first receipt to get started',
            style: GoogleFonts.outfit(
                fontSize: 13, color: subTextColor.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonCard(Color surfaceColor, Color borderColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: surfaceColor,
          border: Border(bottom: BorderSide(color: borderColor)),
        ),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(
          '$value $label',
          style: GoogleFonts.outfit(
              fontSize: 12, fontWeight: FontWeight.w600, color: color),
        ),
      ],
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  final VoidCallback onTap;

  const _PrimaryActionButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton.icon(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        icon: const Icon(Icons.document_scanner_rounded, size: 22),
        label: Text(
          'Scan receipt',
          style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ─── Action Item ─────────────────────────────────────────────────────────────
class _ActionItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionItem(
      {required this.icon, required this.label, required this.onTap});

  @override
  State<_ActionItem> createState() => _ActionItemState();
}

class _ActionItemState extends State<_ActionItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnimation.value, child: child),
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.surfaceDark
                : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.borderDark
                  : AppColors.borderLight,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: AppColors.primary, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  widget.label,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Expense Card ────────────────────────────────────────────────────────────
class ExpenseCard extends StatefulWidget {
  final Expense expense;
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
  State<ExpenseCard> createState() => _ExpenseCardState();
}

class _ExpenseCardState extends State<ExpenseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconData = categoryMeta(widget.expense.categoryName).icon;
    final iconColor = categoryMeta(widget.expense.categoryName).color;
    final dateStr = DateFormat('dd MMM yyyy').format(widget.expense.date);

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnimation.value, child: child),
        child: Container(
          constraints: const BoxConstraints(minHeight: 68),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: widget.surfaceColor,
            border: Border(bottom: BorderSide(color: widget.borderColor)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(iconData, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.expense.vendor,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: widget.textPrimary)),
                    const SizedBox(height: 2),
                    Text(widget.expense.categoryName ?? 'Uncategorized',
                        style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: widget.textSecondary)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                      AppUtils.formatCurrency(widget.expense.amount,
                          currency: widget.expense.currency),
                      style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: widget.textPrimary)),
                  const SizedBox(height: 4),
                  Text(dateStr,
                      style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: widget.textSecondary)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
