import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Visual metadata (icon + color) for a category name.
class CategoryMeta {
  final IconData icon;
  final Color color;

  const CategoryMeta(this.icon, this.color);
}

const Map<String, CategoryMeta> _categoryMeta = {
  'Client Meeting': CategoryMeta(Icons.handshake_rounded, Color(0xFF2563EB)),
  'Travel': CategoryMeta(Icons.flight_rounded, Color(0xFF8B5CF6)),
  'Office Supplies': CategoryMeta(Icons.inventory_2_rounded, Color(0xFFEF4444)),
  'Software': CategoryMeta(Icons.computer_rounded, Color(0xFF06B6D4)),
  'Meals': CategoryMeta(Icons.restaurant_rounded, Color(0xFF10B981)),
  'Accommodation': CategoryMeta(Icons.hotel_rounded, Color(0xFF8B5CF6)),
  'Marketing': CategoryMeta(Icons.campaign_rounded, Color(0xFFEC4899)),
  'Utilities': CategoryMeta(Icons.bolt_rounded, Color(0xFFF59E0B)),
  'Shipping': CategoryMeta(Icons.local_shipping_rounded, Color(0xFFFF6B35)),
  'Other': CategoryMeta(Icons.more_horiz_rounded, Color(0xFF64748B)),
};

CategoryMeta categoryMeta(String? name) {
  return _categoryMeta[name] ??
      const CategoryMeta(Icons.receipt_long_rounded, Color(0xFF64748B));
}

String syncStatusLabel(String status) {
  switch (status) {
    case 'synced':
      return 'Synced';
    case 'pending':
      return 'Pending Sync';
    case 'failed':
      return 'Sync Failed';
    case 'conflict':
      return 'Conflict';
    default:
      return status.isNotEmpty ? status : 'Unknown';
  }
}

Color syncStatusColor(String status) {
  switch (status) {
    case 'synced':
      return AppColors.syncSynced;
    case 'pending':
      return AppColors.syncPending;
    case 'failed':
      return AppColors.syncFailed;
    case 'conflict':
      return AppColors.syncConflict;
    default:
      return AppColors.textSecondaryDark;
  }
}

String formatExpenseDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
}

bool isWithinRange(DateTime date, String filter) {
  final now = DateTime.now();
  switch (filter) {
    case 'Today':
      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    case 'This Week':
      return date
          .isAfter(now.subtract(const Duration(days: 7, hours: 1)));
    case 'This Month':
      return date
          .isAfter(now.subtract(const Duration(days: 30, hours: 1)));
    default:
      return true;
  }
}
