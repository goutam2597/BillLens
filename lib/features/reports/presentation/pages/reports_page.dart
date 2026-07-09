import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final surfaceColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor =
        isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        title: Text(
          'Reports',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateRangeSelector(surfaceColor, textColor, isDark),
            const SizedBox(height: 20),
            Text(
              'Select Report Type',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildReportGrid(surfaceColor, textColor),
            const SizedBox(height: 24),
            Text(
              'Export Reports',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildExportButton(
              label: 'Export as PDF',
              icon: Icons.picture_as_pdf,
              color: const Color(0xFFEF4444),
            ),
            const SizedBox(height: 10),
            _buildExportButton(
              label: 'Export as CSV',
              icon: Icons.table_chart,
              color: const Color(0xFF10B981),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          const Icon(Icons.date_range, color: Color(0xFF2563EB), size: 20),
          const SizedBox(width: 8),
          Text(
            'Period: ',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedMonth,
                isDense: true,
                dropdownColor: surfaceColor,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2563EB),
                ),
                items: List.generate(12, (i) => i + 1).map((m) {
                  return DropdownMenuItem(
                    value: m,
                    child: Text(_months[m - 1]),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedMonth = val);
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
                color: const Color(0xFF2563EB),
              ),
              items: [2023, 2024, 2025, 2026].map((y) {
                return DropdownMenuItem(value: y, child: Text('$y'));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedYear = val);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportGrid(Color surfaceColor, Color textColor) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: _reportTypes.length,
      itemBuilder: (context, index) {
        final report = _reportTypes[index];
        return _buildReportCard(
          title: report['title'] as String,
          icon: report['icon'] as IconData,
          color: report['color'] as Color,
          bgColor: report['bgColor'] as Color,
          surfaceColor: surfaceColor,
          textColor: textColor,
        );
      },
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _showGeneratingSnackBar,
              style: TextButton.styleFrom(
                backgroundColor: color.withValues(alpha: 0.1),
                foregroundColor: color,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Generate',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _showGeneratingSnackBar,
        icon: Icon(icon, color: color, size: 20),
        label: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: color, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
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
