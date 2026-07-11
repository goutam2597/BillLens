import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:billlens/core/di/injection.dart';
import 'package:billlens/core/local/local_storage_service.dart';

class AppUtils {
  /// Format currency amount
  static String formatCurrency(double amount, {String? currency, int decimals = 2}) {
    String currencyCode = currency ?? '';
    if (currencyCode.isEmpty) {
      try {
        if (getIt.isRegistered<LocalStorageService>()) {
          currencyCode = getIt<LocalStorageService>().currency;
        }
      } catch (_) {}
      if (currencyCode.isEmpty) currencyCode = 'USD';
    }

    final symbol = getCurrencySymbol(currencyCode);
    final pattern = decimals > 0
        ? '#,##0.${List.filled(decimals, '0').join()}'
        : '#,##0';
    final formatter = NumberFormat(pattern);
    return '$symbol${formatter.format(amount)}';
  }

  /// Get Currency Symbol from Code
  static String getCurrencySymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'USD': return '\$';
      case 'EUR': return '€';
      case 'GBP': return '£';
      case 'JPY': return '¥';
      case 'INR': return '₹';
      case 'AUD': return 'A\$';
      case 'CAD': return 'C\$';
      case 'CHF': return 'Fr';
      case 'CNY': return '¥';
      case 'BRL': return 'R\$';
      case 'RUB': return '₽';
      case 'KRW': return '₩';
      case 'SGD': return 'S\$';
      case 'NZD': return 'NZ\$';
      case 'MXN': return 'MX\$';
      case 'HKD': return 'HK\$';
      case 'TRY': return '₺';
      case 'ZAR': return 'R';
      case 'SEK': return 'kr';
      case 'NOK': return 'kr';
      case 'DKK': return 'kr';
      case 'IDR': return 'Rp';
      case 'MYR': return 'RM';
      case 'PHP': return '₱';
      case 'THB': return '฿';
      case 'VND': return '₫';
      case 'BDT': return '৳';
      case 'AED': return 'د.إ';
      case 'SAR': return '﷼';
      case 'EGP': return 'E£';
      case 'PKR': return '₨';
      case 'LKR': return '₨';
      case 'NPR': return '₨';
      case 'MMK': return 'K';
      case 'KZT': return '₸';
      case 'UAH': return '₴';
      case 'PLN': return 'zł';
      case 'CZK': return 'Kč';
      case 'HUF': return 'Ft';
      case 'RON': return 'lei';
      case 'BGN': return 'лв';
      case 'HRK': return 'kn';
      case 'ISK': return 'kr';
      case 'GEL': return '₾';
      case 'AMD': return '֏';
      case 'AZN': return '₼';
      case 'NGN': return '₦';
      case 'GHS': return '₵';
      case 'KES': return 'KSh';
      case 'TZS': return 'TSh';
      case 'MAD': return 'د.م.';
      case 'TND': return 'د.ت';
      case 'DZD': return 'دج';
      case 'LYD': return 'ل.د';
      case 'QAR': return 'ر.ق';
      case 'KWD': return 'د.ك';
      case 'BHD': return 'BD';
      case 'OMR': return 'ر.ع.';
      case 'JOD': return 'JD';
      case 'IQD': return 'ع.د';
      case 'IRR': return '﷼';
      case 'ILS': return '₪';
      case 'TWD': return 'NT\$';
      case 'CLP': return 'CLP\$';
      case 'COP': return 'COL\$';
      case 'ARS': return 'AR\$';
      case 'PEN': return 'S/.';
      case 'BOB': return 'Bs.';
      case 'PYG': return '₲';
      case 'UYU': return '\$U';
      case 'VEF': return 'Bs.F';
      default: return '$currencyCode ';
    }
  }

  /// Format date for display
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  /// Format date with time
  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  /// Format relative time
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return formatDate(date);
    }
  }

  /// Get month name
  static String getMonthName(int month) {
    const months = [
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
      'December'
    ];
    return months[month - 1];
  }

  /// Get greeting based on time
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  /// Show snackbar
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Show confirm dialog
  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelLabel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: isDestructive
                ? TextButton.styleFrom(foregroundColor: Colors.red)
                : null,
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  /// Validate email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validate password strength
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  /// Get category color by index
  static Color getCategoryColor(int index) {
    const colors = [
      Color(0xFF2563EB),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFFEF4444),
      Color(0xFF8B5CF6),
      Color(0xFFEC4899),
      Color(0xFF06B6D4),
      Color(0xFFFF6B35),
      Color(0xFF84CC16),
      Color(0xFF6366F1),
    ];
    return colors[index % colors.length];
  }

  /// Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  /// Get initials from name
  static String getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}
