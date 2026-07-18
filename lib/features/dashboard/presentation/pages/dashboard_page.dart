import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:billlens/core/theme/app_colors.dart';
import 'package:billlens/core/router/app_routes.dart';
import 'package:billlens/core/utils/app_utils.dart';
import 'package:billlens/core/local/currency_service.dart';
import 'package:billlens/core/di/injection.dart';
import 'package:dio/dio.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../../../expenses/presentation/helpers/expense_ui_helper.dart'
    show categoryMeta;
import '../../../expenses/data/datasources/expense_local_data_source.dart';

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
                        const SizedBox(height: 16),
                        _buildAnimatedSlideUp(_buildUsageBanner(context), 2),
                        const SizedBox(height: 20),
                        _buildAnimatedSlideUp(_buildQuickActions(context), 3),
                        const SizedBox(height: 28),
                        _buildAnimatedSlideUp(
                            _buildRecentExpensesHeader(context, textPrimary),
                            4),
                        const SizedBox(height: 8),
                        if (state is DashboardLoaded) ...[
                          if (state.recentExpenses.isEmpty)
                            _buildAnimatedSlideUp(
                                _buildEmptyState(textSecondary), 5)
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
                                    5 + entry.key,
                                  ),
                                ),
                        ] else if (state is DashboardLoading)
                          ...List.generate(
                              3,
                              (index) => _buildAnimatedSlideUp(
                                  _buildSkeletonCard(surfaceColor, borderColor),
                                  5 + index)),
                        const SizedBox(height: 24),
                        _buildAnimatedSlideUp(
                            _buildAdBanner(isDark, textSecondary), 10),
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
      height: 190,
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.primaryShadow,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 50,
            bottom: -40,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Total spent this month',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        monthStr,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ValueListenableBuilder<String>(
                  valueListenable: CurrencyService.notifier,
                  builder: (context, cur, _) => Text(
                    AppUtils.formatCurrency(total, currency: cur),
                    style: GoogleFonts.outfit(
                      fontSize: 38,
                      height: 1,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    _SummaryStat(
                      icon: Icons.receipt_long_rounded,
                      value: '$count',
                      label: count == 1 ? 'expense' : 'expenses',
                      color: Colors.white,
                    ),
                    const SizedBox(width: 24),
                    ValueListenableBuilder<String>(
                      valueListenable: CurrencyService.notifier,
                      builder: (context, cur, _) => _SummaryStat(
                        icon: Icons.analytics_rounded,
                        value: AppUtils.formatCurrency(average, currency: cur),
                        label: 'avg',
                        color: Colors.white,
                      ),
                    ),
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
        _PrimaryActionButton(
          onTap: () => context.push(AppRoutes.receiptScanner),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _ActionItem(
                assetPath: 'assets/icons/manual.svg',
                label: 'Manual',
                onTap: () => context.push(AppRoutes.addExpense),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ActionItem(
                assetPath: 'assets/icons/upload.svg',
                label: 'Upload',
                onTap: () => context.push(AppRoutes.receiptScanner),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ActionItem(
                assetPath: 'assets/icons/reports.svg',
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


  Widget _buildUsageBanner(BuildContext context) {
    // Fetch backend usage (source of truth) + local pending, show max to prevent bypass
    // Premium: 300 scans/month fixed, manual unlimited (no AI)
    // Free: 10 scans + 20 manual fixed
    return FutureBuilder<Map<String, dynamic>>(
      future: () async {
        int backendScans = 0;
        int backendManual = 0;
        bool isPremium = false;
        String resetsAt = '';
        int scansLimit = 10;
        int manualLimit = 20;
        // 1. Try backend
        try {
          final dio = getIt<Dio>(instanceName: 'dio');
          final resp = await dio.get('/api/subscription/usage');
          if (resp.statusCode == 200) {
            final data = resp.data['data'] as Map<String, dynamic>?;
            if (data != null) {
              isPremium = data['is_premium'] as bool? ?? false;
              backendScans = (data['scans']?['used'] as int?) ?? (data['scans_used'] as int? ?? 0);
              backendManual = (data['manual_expenses']?['used'] as int?) ?? (data['manual_used'] as int? ?? 0);
              scansLimit = (data['scans']?['limit'] as int?) ?? (data['scans_limit'] as int? ?? (isPremium ? 300 : 10));
              manualLimit = (data['manual_expenses']?['limit'] as int?) ?? (data['manual_limit'] as int? ?? (isPremium ? 999999 : 20));
              resetsAt = data['resets_at'] as String? ?? '';
            }
          }
        } catch (_) {}
        // 2. Get local counts (includes pending not yet synced)
        int localScans = 0;
        int localManual = 0;
        try {
          final local = getIt<ExpenseLocalDataSource>();
          final usage = await local.getMonthlyUsage();
          localScans = usage['scanned'] ?? 0;
          localManual = usage['manual'] ?? 0;
        } catch (_) {}
        // 3. Take max to prevent bypass via offline
        final scansUsed = backendScans > localScans ? backendScans : localScans;
        final manualUsed = backendManual > localManual ? backendManual : localManual;
        // For premium, manual is unlimited, but we still track used for info
        final effectiveManualLimit = isPremium ? 999999 : manualLimit;
        final effectiveScansLimit = isPremium ? 300 : scansLimit;
        return {
          'is_premium': isPremium,
          'scans_used': scansUsed,
          'manual_used': manualUsed,
          'scans_limit': effectiveScansLimit,
          'manual_limit': effectiveManualLimit,
          'scans': {'used': scansUsed, 'limit': effectiveScansLimit, 'remaining': (effectiveScansLimit - scansUsed).clamp(0, effectiveScansLimit)},
          'manual_expenses': {'used': manualUsed, 'limit': effectiveManualLimit, 'remaining': isPremium ? 999999 : (effectiveManualLimit - manualUsed).clamp(0, effectiveManualLimit)},
          'resets_at': resetsAt.isNotEmpty ? resetsAt : DateTime(DateTime.now().year, DateTime.now().month + 1, 1).toIso8601String(),
        };
      }(),
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) {
          // Loading — show placeholder
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                const SizedBox(width: 10),
                Text('Loading usage...', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          );
        }
        final isPremiumBanner = data['is_premium'] == true;

        final scansUsed = (data['scans']?['used'] as int?) ?? (data['scans_used'] as int? ?? 0);
        final manualUsed = (data['manual_expenses']?['used'] as int?) ?? (data['manual_used'] as int? ?? 0);
        final scansLimit = (data['scans']?['limit'] as int?) ?? (data['scans_limit'] as int? ?? 10);
        final manualLimit = (data['manual_expenses']?['limit'] as int?) ?? (data['manual_limit'] as int? ?? 20);
        final scansRemaining = (data['scans']?['remaining'] as int?) ?? (scansLimit - scansUsed).clamp(0, scansLimit);
        final manualRemaining = (data['manual_expenses']?['remaining'] as int?) ?? (manualLimit - manualUsed).clamp(0, manualLimit);
        final resetsAt = data['resets_at'] as String? ?? '';
        final isNearLimit = manualUsed >= (manualLimit * 0.8) || scansUsed >= (scansLimit * 0.8);
        final isExhausted = manualRemaining == 0 || scansRemaining == 0;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isExhausted ? AppColors.error.withValues(alpha: 0.3) : (isNearLimit ? AppColors.warning.withValues(alpha: 0.3) : const Color(0xFFE2E8F0))),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: isPremiumBanner
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(5)),
                    child: Text(
                      isPremiumBanner ? 'PREMIUM — FIXED LIMITS' : 'FREE — FIXED LIMITS',
                      style: GoogleFonts.outfit(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: isPremiumBanner ? AppColors.primary : AppColors.warning,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (isExhausted)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(5)),
                      child: Text('LIMIT REACHED', style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.error)),
                    ),
                  if (resetsAt.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text('Resets: ${resetsAt.substring(0, 10)}', style: GoogleFonts.outfit(fontSize: 9, color: Colors.grey[600])),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.document_scanner_rounded, size: 14, color: scansUsed >= scansLimit ? AppColors.error : AppColors.primary),
                  const SizedBox(width: 4),
                  Text('Scans: $scansUsed/$scansLimit', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 4),
                  Text('• $scansRemaining left', style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey[600])),
                  const Spacer(),
                  Icon(Icons.edit_note_rounded, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  if (isPremiumBanner || manualLimit >= 999999)
                    Text('Manual: Unlimited', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary))
                  else ...[
                    Text('Manual: $manualUsed/$manualLimit', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 4),
                    Text('• $manualRemaining left', style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey[600])),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: (scansUsed / scansLimit).clamp(0.0, 1.0),
                        minHeight: 4,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation(scansUsed >= scansLimit ? AppColors.error : AppColors.primary),
                      ),
                    ),
                  ),
                  if (!(isPremiumBanner || manualLimit >= 999999)) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: (manualUsed / manualLimit).clamp(0.0, 1.0),
                          minHeight: 4,
                          backgroundColor: const Color(0xFFE2E8F0),
                          valueColor: AlwaysStoppedAnimation(manualUsed >= manualLimit ? AppColors.error : AppColors.primary),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (!isPremiumBanner && (isExhausted || isNearLimit)) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.push(AppRoutes.subscription),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      minimumSize: const Size(0, 36),
                    ),
                    child: Text(
                      isExhausted ? 'Limit Reached — Upgrade to Premium' : 'Upgrade to Premium — 300 scans + Unlimited manual',
                      style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
              if (isPremiumBanner && isExhausted) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 16, color: AppColors.warning),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Premium limit reached (300 scans/month). Resets on ${resetsAt.isNotEmpty ? resetsAt.substring(0, 10) : 'next month'}. Manual entries unlimited (no AI).',
                          style: GoogleFonts.outfit(fontSize: 11, color: Colors.black87, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
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
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 14),
        ),
        const SizedBox(width: 8),
        Text(
          '$value $label',
          style: GoogleFonts.outfit(
              fontSize: 13, fontWeight: FontWeight.w500, color: color),
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
      height: 52,
      child: FilledButton.icon(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.primary.withValues(alpha: 0.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: const Icon(Icons.document_scanner_rounded, size: 24),
        label: Text(
          'Scan new receipt',
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ─── Action Item ─────────────────────────────────────────────────────────────
class _ActionItem extends StatefulWidget {
  final String assetPath;
  final String label;
  final VoidCallback onTap;

  const _ActionItem(
      {required this.assetPath, required this.label, required this.onTap});

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
          height: 84,
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                widget.assetPath,
                width: 24,
                height: 24,
                colorFilter:
                    const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  widget.label,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
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
