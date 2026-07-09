import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Appearance
  int _themeIndex = 0; // 0=Light, 1=Dark, 2=System
  String _language = 'English';

  // Preferences
  String _currency = 'USD';
  String _dateFormat = 'DD/MM/YYYY';

  // Notifications
  bool _expenseReminders = true;
  bool _syncAlerts = false;
  bool _weeklyReports = true;

  // Privacy
  bool _biometricLock = false;

  // Sync
  bool _autoSync = true;
  String _syncInterval = 'Every 15 min';

  final List<String> _languages = ['English', 'Spanish', 'French'];
  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'INR', 'JPY', 'CAD'];
  final List<String> _dateFormats = ['DD/MM/YYYY', 'MM/DD/YYYY'];
  final List<String> _syncIntervals = [
    'Every 15 min',
    'Every 30 min',
    'Every 1 hour'
  ];

  void _showSavedSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Settings saved',
          style: GoogleFonts.outfit(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Clear Local Data',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            color: const Color(0xFFEF4444),
          ),
        ),
        content: Text(
          'This will delete all locally cached data. Cloud data will not be affected.',
          style: GoogleFonts.outfit(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel',
                style: GoogleFonts.outfit(color: const Color(0xFF64748B))),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Local data cleared',
                      style: GoogleFonts.outfit(color: Colors.white)),
                  backgroundColor: const Color(0xFFEF4444),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            child: Text(
              'Clear',
              style: GoogleFonts.outfit(
                color: const Color(0xFFEF4444),
                fontWeight: FontWeight.w600,
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
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final surfaceColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor =
        isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final subTextColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        title: Text(
          'Settings',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _showSavedSnackBar,
            child: Text(
              'Save',
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2563EB),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appearance Section
            _buildSectionLabel('Appearance', textColor),
            _buildCard(
              surfaceColor: surfaceColor,
              borderColor: borderColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                    child: Text(
                      'Theme',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return ToggleButtons(
                          isSelected: [
                            _themeIndex == 0,
                            _themeIndex == 1,
                            _themeIndex == 2,
                          ],
                          onPressed: (index) =>
                              setState(() => _themeIndex = index),
                          borderRadius: BorderRadius.circular(10),
                          selectedColor: Colors.white,
                          fillColor: const Color(0xFF2563EB),
                          color: subTextColor,
                          borderColor: borderColor,
                          selectedBorderColor: const Color(0xFF2563EB),
                          constraints: BoxConstraints(
                            minWidth: (constraints.maxWidth - 2) / 3,
                            minHeight: 40,
                          ),
                          children: ['Light', 'Dark', 'System'].map((label) {
                            return Text(
                              label,
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                  _buildDivider(borderColor),
                  _buildDropdownTile(
                    label: 'Language',
                    value: _language,
                    items: _languages,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    surfaceColor: surfaceColor,
                    onChanged: (val) => setState(() => _language = val!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Preferences Section
            _buildSectionLabel('Preferences', textColor),
            _buildCard(
              surfaceColor: surfaceColor,
              borderColor: borderColor,
              child: Column(
                children: [
                  _buildDropdownTile(
                    label: 'Default Currency',
                    value: _currency,
                    items: _currencies,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    surfaceColor: surfaceColor,
                    onChanged: (val) => setState(() => _currency = val!),
                  ),
                  _buildDivider(borderColor),
                  _buildDropdownTile(
                    label: 'Date Format',
                    value: _dateFormat,
                    items: _dateFormats,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    surfaceColor: surfaceColor,
                    onChanged: (val) => setState(() => _dateFormat = val!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Notifications Section
            _buildSectionLabel('Notifications', textColor),
            _buildCard(
              surfaceColor: surfaceColor,
              borderColor: borderColor,
              child: Column(
                children: [
                  _buildSwitchTile(
                    label: 'Expense Reminders',
                    subtitle: 'Get reminded to log expenses',
                    value: _expenseReminders,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onChanged: (val) => setState(() => _expenseReminders = val),
                  ),
                  _buildDivider(borderColor),
                  _buildSwitchTile(
                    label: 'Sync Alerts',
                    subtitle: 'Notifications when sync completes',
                    value: _syncAlerts,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onChanged: (val) => setState(() => _syncAlerts = val),
                  ),
                  _buildDivider(borderColor),
                  _buildSwitchTile(
                    label: 'Weekly Reports',
                    subtitle: 'Receive weekly expense summary',
                    value: _weeklyReports,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onChanged: (val) => setState(() => _weeklyReports = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Privacy Section
            _buildSectionLabel('Privacy', textColor),
            _buildCard(
              surfaceColor: surfaceColor,
              borderColor: borderColor,
              child: Column(
                children: [
                  _buildSwitchTile(
                    label: 'Biometric Lock',
                    subtitle: 'Use fingerprint / face ID to unlock',
                    value: _biometricLock,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onChanged: (val) => setState(() => _biometricLock = val),
                  ),
                  _buildDivider(borderColor),
                  ListTile(
                    title: Text(
                      'Clear Local Data',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                    subtitle: Text(
                      'Delete all cached data from this device',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: subTextColor,
                      ),
                    ),
                    trailing: const Icon(Icons.delete_outline,
                        color: Color(0xFFEF4444)),
                    onTap: _showClearDataDialog,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Sync Section
            _buildSectionLabel('Sync', textColor),
            _buildCard(
              surfaceColor: surfaceColor,
              borderColor: borderColor,
              child: Column(
                children: [
                  _buildSwitchTile(
                    label: 'Auto Sync',
                    subtitle: 'Automatically sync data in background',
                    value: _autoSync,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onChanged: (val) => setState(() => _autoSync = val),
                  ),
                  _buildDivider(borderColor),
                  _buildDropdownTile(
                    label: 'Sync Interval',
                    value: _syncInterval,
                    items: _syncIntervals,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    surfaceColor: surfaceColor,
                    onChanged: _autoSync
                        ? (val) => setState(() => _syncInterval = val!)
                        : null,
                  ),
                  _buildDivider(borderColor),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Syncing...',
                                style: GoogleFonts.outfit(color: Colors.white),
                              ),
                              backgroundColor: const Color(0xFF2563EB),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                        },
                        icon: const Icon(Icons.sync, color: Colors.white),
                        label: Text(
                          'Sync Now',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textColor.withValues(alpha: 0.5),
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildCard({
    required Color surfaceColor,
    required Color borderColor,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSwitchTile({
    required String label,
    required String subtitle,
    required bool value,
    required Color textColor,
    required Color subTextColor,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile.adaptive(
      title: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.outfit(fontSize: 12, color: subTextColor),
      ),
      value: value,
      activeThumbColor: const Color(0xFF2563EB),
      onChanged: onChanged,
    );
  }

  Widget _buildDropdownTile({
    required String label,
    required String value,
    required List<String> items,
    required Color textColor,
    required Color subTextColor,
    required Color surfaceColor,
    required ValueChanged<String?>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isDense: true,
              dropdownColor: surfaceColor,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2563EB),
              ),
              onChanged: onChanged,
              items: items.map((item) {
                return DropdownMenuItem(value: item, child: Text(item));
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(Color color) {
    return Divider(height: 1, indent: 16, endIndent: 16, color: color);
  }
}
