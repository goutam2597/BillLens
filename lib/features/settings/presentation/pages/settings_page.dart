import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/app_widgets.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppPageBar(
        title: 'Settings',
        actions: [
          TextButton(
            onPressed: _showSavedSnackBar,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppSectionHeader(title: 'Appearance'),
            const SizedBox(height: 8),
            AppGroupedSurface(
              padding: EdgeInsets.zero,
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
                        color: colorScheme.onSurface,
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
                          fillColor: colorScheme.primary,
                          color: colorScheme.onSurfaceVariant,
                          borderColor: colorScheme.outlineVariant,
                          selectedBorderColor: colorScheme.primary,
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
                  _buildDivider(colorScheme.outlineVariant),
                  _buildDropdownTile(
                    label: 'Language',
                    value: _language,
                    items: _languages,
                    onChanged: (val) => setState(() => _language = val!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const AppSectionHeader(title: 'Preferences'),
            const SizedBox(height: 8),
            AppGroupedSurface(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildDropdownTile(
                    label: 'Default Currency',
                    value: _currency,
                    items: _currencies,
                    onChanged: (val) => setState(() => _currency = val!),
                  ),
                  _buildDivider(colorScheme.outlineVariant),
                  _buildDropdownTile(
                    label: 'Date Format',
                    value: _dateFormat,
                    items: _dateFormats,
                    onChanged: (val) => setState(() => _dateFormat = val!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const AppSectionHeader(title: 'Notifications'),
            const SizedBox(height: 8),
            AppGroupedSurface(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildSwitchTile(
                    label: 'Expense Reminders',
                    subtitle: 'Get reminded to log expenses',
                    value: _expenseReminders,
                    onChanged: (val) => setState(() => _expenseReminders = val),
                  ),
                  _buildDivider(colorScheme.outlineVariant),
                  _buildSwitchTile(
                    label: 'Sync Alerts',
                    subtitle: 'Notifications when sync completes',
                    value: _syncAlerts,
                    onChanged: (val) => setState(() => _syncAlerts = val),
                  ),
                  _buildDivider(colorScheme.outlineVariant),
                  _buildSwitchTile(
                    label: 'Weekly Reports',
                    subtitle: 'Receive weekly expense summary',
                    value: _weeklyReports,
                    onChanged: (val) => setState(() => _weeklyReports = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const AppSectionHeader(title: 'Privacy'),
            const SizedBox(height: 8),
            AppGroupedSurface(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildSwitchTile(
                    label: 'Biometric Lock',
                    subtitle: 'Use fingerprint / face ID to unlock',
                    value: _biometricLock,
                    onChanged: (val) => setState(() => _biometricLock = val),
                  ),
                  _buildDivider(colorScheme.outlineVariant),
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
                        color: colorScheme.onSurfaceVariant,
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
            const AppSectionHeader(title: 'Sync'),
            const SizedBox(height: 8),
            AppGroupedSurface(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildSwitchTile(
                    label: 'Auto Sync',
                    subtitle: 'Automatically sync data in background',
                    value: _autoSync,
                    onChanged: (val) => setState(() => _autoSync = val),
                  ),
                  _buildDivider(colorScheme.outlineVariant),
                  _buildDropdownTile(
                    label: 'Sync Interval',
                    value: _syncInterval,
                    items: _syncIntervals,
                    onChanged: _autoSync
                        ? (val) => setState(() => _syncInterval = val!)
                        : null,
                  ),
                  _buildDivider(colorScheme.outlineVariant),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: PrimaryButton(
                      text: 'Sync now',
                      height: 52,
                      icon: const Icon(Icons.sync_rounded, color: Colors.white),
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

  Widget _buildSwitchTile({
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return SwitchListTile.adaptive(
      title: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.outfit(
          fontSize: 12,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      value: value,
      activeThumbColor: colorScheme.primary,
      onChanged: onChanged,
    );
  }

  Widget _buildDropdownTile({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?>? onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
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
              color: colorScheme.onSurface,
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isDense: true,
              dropdownColor: colorScheme.surface,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
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
