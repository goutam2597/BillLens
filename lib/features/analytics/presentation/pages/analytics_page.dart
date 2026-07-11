import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:billlens/core/theme/app_colors.dart';
import 'package:billlens/core/utils/app_utils.dart';
import 'package:billlens/core/widgets/app_widgets.dart';
import '../bloc/analytics_bloc.dart';
import '../bloc/analytics_event.dart';
import '../bloc/analytics_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data Models
// ─────────────────────────────────────────────────────────────────────────────
class _CategoryStat {
  final String name;
  final double percentage;
  final double amount;
  final Color color;

  const _CategoryStat({
    required this.name,
    required this.percentage,
    required this.amount,
    required this.color,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Analytics Page
// ─────────────────────────────────────────────────────────────────────────────
class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage>
    with SingleTickerProviderStateMixin {
  int _selectedRange = 0;
  static const _ranges = [
    'All',
    'Today',
    'This Week',
    'This Month',
    'Last 3 Months',
    'This Year'
  ];

  int _touchedBarIndex = -1;

  late final AnimationController _entryController;
  late final Animation<double> _entryAnimation;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _entryAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  (DateTime, DateTime) _dateRange(int index) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (index) {
      case 0:
        return (DateTime.fromMillisecondsSinceEpoch(0), today);
      case 1:
        return (today, today);
      case 2:
        return (
          today.subtract(Duration(days: today.weekday - 1)),
          today,
        );
      case 4:
        return (DateTime(now.year, now.month - 2, 1), today);
      case 5:
        return (DateTime(now.year, 1, 1), today);
      default:
        return (DateTime(now.year, now.month, 1), today);
    }
  }

  void _selectRange(int index) {
    final range = _dateRange(index);
    setState(() => _selectedRange = index);
    context.read<AnalyticsBloc>().add(
          ChangeAnalyticsDateRange(start: range.$1, end: range.$2),
        );
  }

  String _money(double amount, {int decimals = 0}) {
    return AppUtils.formatCurrency(amount, decimals: decimals);
  }

  Color _colorFromHex(String value) {
    final hex = value.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final analyticsState = context.watch<AnalyticsBloc>().state;
    final data = analyticsState is AnalyticsLoaded ? analyticsState : null;
    final weeklyValues = data?.weeklyValues ?? List<double>.filled(7, 0);
    final weekDays = data?.chartLabels ?? List<String>.filled(7, '');
    final categoryStats = data?.categoryDistribution
            .map(
              (category) => _CategoryStat(
                name: category.name,
                percentage: category.percentage,
                amount: category.amount,
                color: _colorFromHex(category.color),
              ),
            )
            .toList() ??
        const <_CategoryStat>[];
    final maxValue =
        weeklyValues.fold<double>(0, (max, value) => value > max ? value : max);
    final chartMax = maxValue <= 0 ? 100.0 : (maxValue * 1.2).ceilToDouble();
    final chartInterval = chartMax <= 100 ? 25.0 : chartMax / 4;
    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: FadeTransition(
        opacity: _entryAnimation,
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<AnalyticsBloc>().add(const LoadAnalytics());
            await context.read<AnalyticsBloc>().stream.firstWhere(
                  (state) =>
                      state is AnalyticsLoaded || state is AnalyticsError,
                );
          },
          child: CustomScrollView(
            slivers: [
              AppRootSliverBar(
                title: 'Analytics',
                actions: [
                  IconButton(
                    icon: const Icon(Icons.file_download_outlined, size: 22),
                    tooltip: 'Export analytics',
                    onPressed: () {},
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
                sliver: SliverList.list(
                  children: [
                    // ── Date range chips ──────────────────────────────────────────
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _ranges.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final selected = _selectedRange == index;
                          return GestureDetector(
                            onTap: () => _selectRange(index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.primary
                                    : colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: selected
                                      ? AppColors.primary
                                      : colorScheme.outlineVariant,
                                ),
                              ),
                              child: Text(
                                _ranges[index],
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? Colors.white
                                      : colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Summary cards ─────────────────────────────────────────────
                    SizedBox(
                      height: 120,
                      child: ListView(
                        clipBehavior: Clip.none,
                        scrollDirection: Axis.horizontal,
                        children: [
                          _SummaryCard(
                            label: 'Total Spent',
                            value: _money(data?.totalSpending ?? 0),
                            icon: Icons.account_balance_wallet_outlined,
                            color: Color(0xFF2563EB),
                          ),
                          const SizedBox(width: 12),
                          _SummaryCard(
                            label: 'Avg / Day',
                            value: _money(data?.avgDaily ?? 0),
                            icon: Icons.trending_up_rounded,
                            color: Color(0xFF10B981),
                          ),
                          const SizedBox(width: 12),
                          _SummaryCard(
                            label: 'Top Category',
                            value: data?.topCategory ?? 'None',
                            icon: Icons.flight_takeoff_rounded,
                            color: Color(0xFF7C3AED),
                          ),
                          const SizedBox(width: 12),
                          _SummaryCard(
                            label: 'Receipts',
                            value: '${data?.receiptCount ?? 0}',
                            icon: Icons.receipt_long_rounded,
                            color: Color(0xFFF59E0B),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Bar chart ─────────────────────────────────────────────────
                    AppGroupedSurface(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Spending Trend',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  _ranges[_selectedRange],
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 200,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: chartMax,
                                barTouchData: BarTouchData(
                                  touchTooltipData: BarTouchTooltipData(
                                    getTooltipColor: (_) =>
                                        const Color(0xFF0F172A),
                                    getTooltipItem:
                                        (group, groupIndex, rod, rodIndex) {
                                      return BarTooltipItem(
                                        _money(rod.toY),
                                        GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      );
                                    },
                                  ),
                                  touchCallback: (event, response) {
                                    setState(() {
                                      if (response == null ||
                                          response.spot == null) {
                                        _touchedBarIndex = -1;
                                      } else {
                                        _touchedBarIndex =
                                            response.spot!.touchedBarGroupIndex;
                                      }
                                    });
                                  },
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  rightTitles: const AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                  topTitles: const AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      getTitlesWidget: (value, meta) {
                                        if (value % 100 != 0) {
                                          return const SizedBox.shrink();
                                        }
                                        return Text(
                                          '\$${value.toInt()}',
                                          style: GoogleFonts.outfit(
                                            fontSize: 10,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        final index = value.toInt();
                                        if (index < 0 ||
                                            index >= weekDays.length) {
                                          return const SizedBox.shrink();
                                        }
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(top: 6),
                                          child: Text(
                                            weekDays[index],
                                            style: GoogleFonts.outfit(
                                              fontSize: 11,
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  horizontalInterval: chartInterval,
                                  getDrawingHorizontalLine: (_) => FlLine(
                                    color: colorScheme.outlineVariant,
                                    strokeWidth: 1,
                                    dashArray: [4, 4],
                                  ),
                                ),
                                barGroups: List.generate(
                                  weeklyValues.length,
                                  (index) {
                                    final isTouched = _touchedBarIndex == index;
                                    return BarChartGroupData(
                                      x: index,
                                      barRods: [
                                        BarChartRodData(
                                          toY: weeklyValues[index],
                                          gradient: LinearGradient(
                                            colors: isTouched
                                                ? [
                                                    const Color(0xFF10B981),
                                                    const Color(0xFF10B981)
                                                        .withValues(alpha: 0.7),
                                                  ]
                                                : [
                                                    AppColors.primary,
                                                    AppColors.primary
                                                        .withValues(alpha: 0.6),
                                                  ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                          width: 18,
                                          borderRadius:
                                              const BorderRadius.vertical(
                                            top: Radius.circular(6),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Category distribution ──────────────────────────────────────
                    AppGroupedSurface(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'By Category',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (categoryStats.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                analyticsState is AnalyticsError
                                    ? analyticsState.message
                                    : 'No expenses in this date range.',
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  color: analyticsState is AnalyticsError
                                      ? colorScheme.error
                                      : colorScheme.onSurfaceVariant,
                                ),
                              ),
                            )
                          else
                            ...categoryStats.map(
                              (stat) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _CategoryBar(stat: stat),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (analyticsState is AnalyticsLoading)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: LinearProgressIndicator(minHeight: 2),
                      ),

                    // ── Ad placeholder ────────────────────────────────────────────
                    AppGroupedSurface(
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2563EB), Color(0xFF10B981)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.star_rounded,
                                color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Upgrade to Pro',
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  'Get detailed reports, export to CSV & more',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(
                              'Try',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary Card
// ─────────────────────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category Bar Row
// ─────────────────────────────────────────────────────────────────────────────
class _CategoryBar extends StatelessWidget {
  final _CategoryStat stat;

  const _CategoryBar({required this.stat});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        // Colored dot
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: stat.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        // Name
        SizedBox(
          width: 70,
          child: Text(
            stat.name,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Progress bar
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: stat.percentage,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(stat.color),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Percentage
        SizedBox(
          width: 36,
          child: Text(
            '${(stat.percentage * 100).toInt()}%',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 8),
        // Amount
        SizedBox(
          width: 48,
          child: Text(
            AppUtils.formatCurrency(stat.amount, decimals: 0),
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
