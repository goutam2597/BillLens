import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

const _categoryStats = [
  _CategoryStat(
      name: 'Travel', percentage: 0.35, amount: 857, color: Color(0xFF7C3AED)),
  _CategoryStat(
      name: 'Office', percentage: 0.25, amount: 612, color: Color(0xFF2563EB)),
  _CategoryStat(
      name: 'Meals', percentage: 0.20, amount: 490, color: Color(0xFF10B981)),
  _CategoryStat(
      name: 'Software',
      percentage: 0.12,
      amount: 294,
      color: Color(0xFFF59E0B)),
  _CategoryStat(
      name: 'Other', percentage: 0.08, amount: 196, color: Color(0xFF64748B)),
];

// Weekly bar data (Mon–Sun)
const _weeklyValues = [85.0, 120.0, 95.0, 200.0, 165.0, 310.0, 280.0];
const _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

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
  int _selectedRange = 1; // index into _ranges
  static const _ranges = [
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
          'Analytics',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined,
                color: Color(0xFF64748B), size: 22),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE2E8F0)),
        ),
      ),
      body: FadeTransition(
        opacity: _entryAnimation,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
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
                    onTap: () => setState(() => _selectedRange = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color:
                            selected ? const Color(0xFF2563EB) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF2563EB)
                              : const Color(0xFFE2E8F0),
                        ),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF2563EB)
                                      .withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Text(
                        _ranges[index],
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color:
                              selected ? Colors.white : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // ── Summary cards ─────────────────────────────────────────────
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  _SummaryCard(
                    label: 'Total Spent',
                    value: '\$2,450',
                    icon: Icons.account_balance_wallet_outlined,
                    color: Color(0xFF2563EB),
                  ),
                  SizedBox(width: 12),
                  _SummaryCard(
                    label: 'Avg / Day',
                    value: '\$82',
                    icon: Icons.trending_up_rounded,
                    color: Color(0xFF10B981),
                  ),
                  SizedBox(width: 12),
                  _SummaryCard(
                    label: 'Top Category',
                    value: 'Travel',
                    icon: Icons.flight_takeoff_rounded,
                    color: Color(0xFF7C3AED),
                  ),
                  SizedBox(width: 12),
                  _SummaryCard(
                    label: 'Receipts',
                    value: '23',
                    icon: Icons.receipt_long_rounded,
                    color: Color(0xFFF59E0B),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Bar chart ─────────────────────────────────────────────────
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Monthly Spending',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Week view',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2563EB),
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
                        maxY: 360,
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (_) => const Color(0xFF0F172A),
                            tooltipRoundedRadius: 8,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                '\$${rod.toY.toInt()}',
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
                              if (response == null || response.spot == null) {
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
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
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
                                    color: const Color(0xFF94A3B8),
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
                                if (index < 0 || index >= _weekDays.length) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    _weekDays[index],
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      color: const Color(0xFF94A3B8),
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
                          horizontalInterval: 100,
                          getDrawingHorizontalLine: (_) => const FlLine(
                            color: Color(0xFFE2E8F0),
                            strokeWidth: 1,
                            dashArray: [4, 4],
                          ),
                        ),
                        barGroups: List.generate(
                          _weeklyValues.length,
                          (index) {
                            final isTouched = _touchedBarIndex == index;
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: _weeklyValues[index],
                                  gradient: LinearGradient(
                                    colors: isTouched
                                        ? [
                                            const Color(0xFF10B981),
                                            const Color(0xFF10B981)
                                                .withValues(alpha: 0.7),
                                          ]
                                        : [
                                            const Color(0xFF2563EB),
                                            const Color(0xFF2563EB)
                                                .withValues(alpha: 0.6),
                                          ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  width: 18,
                                  borderRadius: const BorderRadius.vertical(
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
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'By Category',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ..._categoryStats.map(
                    (stat) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _CategoryBar(stat: stat),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Ad placeholder ────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  style: BorderStyle.solid,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
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
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Get detailed reports, export to CSV & more',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
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
    return Container(
      width: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Card Wrapper
// ─────────────────────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
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
              color: const Color(0xFF0F172A),
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
              backgroundColor: const Color(0xFFF1F5F9),
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
              color: const Color(0xFF64748B),
            ),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 8),
        // Amount
        SizedBox(
          width: 48,
          child: Text(
            '\$${stat.amount.toInt()}',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
