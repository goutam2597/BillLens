import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../router/app_routes.dart';
import '../../features/subscription/presentation/bloc/subscription_state.dart';

/// Shows usage banner for free users: scans and manual expenses
class UsageBanner extends StatelessWidget {
  final UsageInfo? usage;
  final bool isPremium;

  const UsageBanner({
    super.key,
    this.usage,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isPremium || usage == null) return const SizedBox.shrink();
    if (usage!.isPremium) return const SizedBox.shrink();

    final scansUsed = usage!.scansUsed;
    final scansLimit = usage!.scansLimit;
    final manualUsed = usage!.manualUsed;
    final manualLimit = usage!.manualLimit;

    final isScansNearLimit = scansUsed >= (scansLimit * 0.8);
    final isManualNearLimit = manualUsed >= (manualLimit * 0.8);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isScansNearLimit || isManualNearLimit)
              ? AppColors.warning.withValues(alpha: 0.5)
              : const Color(0xFFE2E8F0),
        ),
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
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'FREE PLAN — FIXED LIMITS',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.warning,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              if (usage!.isAnyExhausted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'LIMIT REACHED',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _buildProgressRow(
            icon: Icons.document_scanner_rounded,
            label: 'AI Scans',
            used: scansUsed,
            limit: scansLimit,
            remaining: usage!.scansRemaining,
            progress: usage!.scansProgress,
            isNearLimit: isScansNearLimit,
            isExhausted: usage!.isScansExhausted,
          ),
          const SizedBox(height: 12),
          _buildProgressRow(
            icon: Icons.edit_note_rounded,
            label: 'Manual Expenses',
            used: manualUsed,
            limit: manualLimit,
            remaining: usage!.manualRemaining,
            progress: usage!.manualProgress,
            isNearLimit: isManualNearLimit,
            isExhausted: usage!.isManualExhausted,
          ),
          if (usage!.resetsAt.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.refresh_rounded, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Resets: ${_formatReset(usage!.resetsAt)}',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push(AppRoutes.subscription),
              icon: const Icon(Icons.workspace_premium_rounded, size: 18),
              label: Text(
                'Upgrade to Premium — Unlimited',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRow({
    required IconData icon,
    required String label,
    required int used,
    required int limit,
    required int remaining,
    required double progress,
    required bool isNearLimit,
    required bool isExhausted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: isExhausted ? AppColors.error : AppColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Text(
              '$used / $limit',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isExhausted ? AppColors.error : (isNearLimit ? AppColors.warning : Colors.black87),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              isExhausted ? '• Exhausted' : '• $remaining left',
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: isExhausted ? AppColors.error : Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: const Color(0xFFE2E8F0),
            valueColor: AlwaysStoppedAnimation(
              isExhausted ? AppColors.error : (isNearLimit ? AppColors.warning : AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  String _formatReset(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }
}

/// Shows upgrade dialog when limit exceeded
class LimitExceededDialog extends StatelessWidget {
  final String message;
  final String code;
  final Map<String, dynamic>? usage;
  final int? used;
  final int? limit;

  const LimitExceededDialog({
    super.key,
    required this.message,
    required this.code,
    this.usage,
    this.used,
    this.limit,
  });

  bool get isScanLimit => code == 'SCAN_LIMIT_EXCEEDED';
  String get limitType => isScanLimit ? 'AI Receipt Scans' : 'Manual Expenses';
  int get displayLimit => limit ?? (isScanLimit ? AppConstants.freeMonthlyScans : AppConstants.freeManualExpensesLimit);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isScanLimit ? Icons.document_scanner_rounded : Icons.edit_note_rounded,
                color: AppColors.error,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Limit Reached',
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$limitType — $displayLimit/month (Free, Fixed)',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.warning,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey[700], height: 1.4),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_rounded, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Fixed limits cannot be overridden',
                        style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Premium = Unlimited scans + unlimited manual expenses',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.push(AppRoutes.subscription);
                },
                icon: const Icon(Icons.workspace_premium_rounded),
                label: Text('Upgrade to Premium', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Maybe Later', style: GoogleFonts.outfit(color: Colors.grey[600])),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> show(
    BuildContext context, {
    required String message,
    required String code,
    Map<String, dynamic>? usage,
    int? used,
    int? limit,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => LimitExceededDialog(
        message: message,
        code: code,
        usage: usage,
        used: used,
        limit: limit,
      ),
    );
  }
}

/// Compact chip showing remaining scans
class RemainingScansChip extends StatelessWidget {
  final int remaining;
  final int limit;

  const RemainingScansChip({super.key, required this.remaining, required this.limit});

  @override
  Widget build(BuildContext context) {
    final isExhausted = remaining <= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isExhausted ? AppColors.error.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isExhausted ? AppColors.error : AppColors.primary, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.document_scanner_rounded,
            size: 14,
            color: isExhausted ? AppColors.error : AppColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            isExhausted ? 'No scans left' : '$remaining/$limit scans left',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isExhausted ? AppColors.error : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
