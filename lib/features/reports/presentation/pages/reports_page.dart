import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:billlens/core/theme/app_colors.dart';
import 'package:billlens/core/widgets/app_widgets.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  final List<Map<String, dynamic>> _reportTypes = [
    {
      'title': 'Monthly Report',
      'icon': Icons.calendar_month,
      'color': const Color(0xFF2563EB),
      'bgColor': const Color(0xFFEFF6FF),
    },
    {
      'title': 'Tax Report',
      'icon': Icons.account_balance,
      'color': const Color(0xFF10B981),
      'bgColor': const Color(0xFFECFDF5),
    },
    {
      'title': 'Business Expenses',
      'icon': Icons.business_center,
      'color': const Color(0xFF7C3AED),
      'bgColor': const Color(0xFFF5F3FF),
    },
    {
      'title': 'Category Report',
      'icon': Icons.category,
      'color': const Color(0xFFF59E0B),
      'bgColor': const Color(0xFFFFFBEB),
    },
    {
      'title': 'Client Expenses',
      'icon': Icons.people,
      'color': const Color(0xFF0D9488),
      'bgColor': const Color(0xFFF0FDFA),
    },
  ];

  final List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  void _showGeneratingSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Generating report...',
          style: GoogleFonts.outfit(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2563EB),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
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
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: const AppPageBar(title: 'Reports'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppSectionHeader(title: 'Reporting period'),
            const SizedBox(height: 8),
            _buildDateRangeSelector(surfaceColor, textColor, isDark),
            const SizedBox(height: 24),
            const AppSectionHeader(title: 'Report type'),
            const SizedBox(height: 8),
            _buildReportGrid(surfaceColor, textColor),
            const SizedBox(height: 24),
            const AppSectionHeader(title: 'Export'),
            const SizedBox(height: 8),
            AppGroupedSurface(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildExportButton(
                    label: 'Export as PDF',
                    icon: Icons.picture_as_pdf_outlined,
                    color: AppColors.error,
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildExportButton(
                    label: 'Export as CSV',
                    icon: Icons.table_chart_outlined,
                    color: AppColors.accent,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildAdBanner(isDark),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector(
      Color surfaceColor, Color textColor, bool isDark) {
    final borderColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    return AppGroupedSurface(
      borderColor: borderColor,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.date_range_outlined,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedMonth,
                      isExpanded: true,
                      isDense: true,
                      dropdownColor: surfaceColor,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      items: List.generate(12, (i) => i + 1).map((m) {
                        return DropdownMenuItem(
                          value: m,
                          child: Text(_months[m - 1]),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedMonth = val);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedYear,
                    isDense: true,
                    dropdownColor: surfaceColor,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    items: [2023, 2024, 2025, 2026].map((y) {
                      return DropdownMenuItem(value: y, child: Text('$y'));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedYear = val);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportGrid(Color surfaceColor, Color textColor) {
    return AppGroupedSurface(
      padding: EdgeInsets.zero,
      child: Column(
        children: _reportTypes.asMap().entries.map((entry) {
          final report = entry.value;
          return Column(
            children: [
              _buildReportCard(
                title: report['title'] as String,
                icon: report['icon'] as IconData,
                color: report['color'] as Color,
                bgColor: report['bgColor'] as Color,
                surfaceColor: surfaceColor,
                textColor: textColor,
              ),
              if (entry.key < _reportTypes.length - 1)
                const Divider(height: 1, indent: 64),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReportCard({
    required String title,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required Color surfaceColor,
    required Color textColor,
  }) {
    return InkWell(
      onTap: _showGeneratingSnackBar,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 21),
            ),
            const SizedBox(height: 12),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return InkWell(
      onTap: _showGeneratingSnackBar,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            Icon(Icons.download_rounded,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildAdBanner(bool isDark) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
        ),
      ),
      child: Center(
        child: Text(
          '🔔 Ad Banner — Upgrade to remove ads',
          style: GoogleFonts.outfit(
            fontSize: 12,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
