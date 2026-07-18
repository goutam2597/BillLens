import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:billlens/core/theme/app_colors.dart';

String _formatDateTime(String? raw, {bool withTime = false}) {
  if (raw == null || raw.isEmpty || raw == '-' || raw == '—') {
    return 'Not available';
  }
  try {
    final dt = DateTime.parse(raw).toLocal();
    if (withTime) {
      final months = [
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
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      final mm = dt.minute.toString().padLeft(2, '0');
      return '${dt.day} ${months[dt.month - 1]} ${dt.year} • $h:$mm $ampm';
    } else {
      final months = [
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
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    }
  } catch (_) {
    // fallback raw trimmed to 19 chars
    return raw.length > 19 ? raw.substring(0, 19) : raw;
  }
}

/// Shows the premium delete account dialog.
/// Returns:  'request' | 'cancel' | null
Future<String?> showDeleteAccountDialog(
  BuildContext context, {
  Map<String, dynamic>? deletionData,
  required Future<void> Function(String? reason) onRequest,
  required Future<void> Function() onCancelRequest,
}) {
  return showDialog<String>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    barrierDismissible: true,
    builder: (ctx) => _DeleteAccountDialogContent(
      deletionData: deletionData,
      onRequest: onRequest,
      onCancelRequest: onCancelRequest,
    ),
  );
}

class _DeleteAccountDialogContent extends StatefulWidget {
  final Map<String, dynamic>? deletionData;
  final Future<void> Function(String? reason) onRequest;
  final Future<void> Function() onCancelRequest;

  const _DeleteAccountDialogContent({
    required this.deletionData,
    required this.onRequest,
    required this.onCancelRequest,
  });

  @override
  State<_DeleteAccountDialogContent> createState() =>
      _DeleteAccountDialogContentState();
}

class _DeleteAccountDialogContentState
    extends State<_DeleteAccountDialogContent> {
  final _reasonCtrl = TextEditingController();
  bool _understood = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasPending = widget.deletionData != null &&
        widget.deletionData!['has_request'] == true;
    final request = hasPending
        ? widget.deletionData!['request'] as Map<String, dynamic>?
        : null;

    final rawDaysRemaining =
        request?['days_remaining'] ?? widget.deletionData?['days_remaining'];
    int daysRemaining = 30;
    if (rawDaysRemaining is int) daysRemaining = rawDaysRemaining;
    if (rawDaysRemaining is String) {
      daysRemaining = int.tryParse(rawDaysRemaining) ?? 30;
    }
    if (rawDaysRemaining is double) daysRemaining = rawDaysRemaining.toInt();

    final requestedAtRaw =
        request?['requested_at'] ?? widget.deletionData?['requested_at'] ?? '';
    final scheduledRaw = request?['scheduled_deletion_at'] ??
        widget.deletionData?['scheduled_deletion_at'] ??
        '';
    final reasonRaw = request?['reason'] as String? ?? '';

    final daysPassedRaw = request?['days_passed'] ?? 0;
    int daysPassed = 0;
    if (daysPassedRaw is int) daysPassed = daysPassedRaw;
    if (daysPassedRaw is String) daysPassed = int.tryParse(daysPassedRaw) ?? 0;

    if (hasPending) {
      // If daysPassed not provided, calculate from requested date
      if (daysPassed == 0 && requestedAtRaw.toString().isNotEmpty) {
        try {
          final reqDate = DateTime.parse(requestedAtRaw.toString());
          daysPassed = DateTime.now().difference(reqDate).inDays.clamp(0, 30);
        } catch (_) {}
      }
    }

    final progress = hasPending ? (daysPassed / 30.0).clamp(0.0, 1.0) : 0.0;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: cs.surface,
      elevation: 0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Top bar ──
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color:
                            (hasPending ? AppColors.warning : AppColors.error)
                                .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        hasPending
                            ? Icons.hourglass_top_rounded
                            : Icons.delete_forever_rounded,
                        color: hasPending ? AppColors.warning : AppColors.error,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasPending
                                ? 'Deletion Requested'
                                : 'Delete Account?',
                            style: GoogleFonts.outfit(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: cs.onSurface,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            hasPending
                                ? 'Your account is pending deletion'
                                : 'This action requires admin review',
                            style: GoogleFonts.outfit(
                              fontSize: 12.5,
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close_rounded,
                          size: 20, color: cs.onSurfaceVariant),
                      style: IconButton.styleFrom(
                        backgroundColor:
                            cs.surfaceContainerHighest.withValues(alpha: 0.6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        minimumSize: const Size(36, 36),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                if (hasPending) ...[
                  // ── Countdown premium card ──
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.warning.withValues(alpha: 0.14),
                          AppColors.warning.withValues(alpha: 0.06),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.22),
                          width: 1),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Big days number
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.warning
                                        .withValues(alpha: 0.2),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                    color: AppColors.warning
                                        .withValues(alpha: 0.2)),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$daysRemaining',
                                    style: GoogleFonts.outfit(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: daysRemaining <= 3
                                          ? AppColors.error
                                          : AppColors.warning,
                                      height: 1,
                                    ),
                                  ),
                                  Text(
                                    daysRemaining == 1 ? 'day' : 'days',
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.warning,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Auto-deletion in',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: cs.onSurfaceVariant,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$daysRemaining ${daysRemaining == 1 ? 'day' : 'days'} remaining',
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(999),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 6,
                                      backgroundColor:
                                          Colors.black.withValues(alpha: 0.06),
                                      valueColor: AlwaysStoppedAnimation(
                                        daysRemaining <= 3
                                            ? AppColors.error
                                            : AppColors.warning,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Day $daysPassed of 30',
                                        style: GoogleFonts.outfit(
                                            fontSize: 11,
                                            color: cs.onSurfaceVariant,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: (daysRemaining <= 3
                                                  ? AppColors.error
                                                  : AppColors.warning)
                                              .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          daysRemaining <= 3
                                              ? 'Urgent'
                                              : 'Pending',
                                          style: GoogleFonts.outfit(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: daysRemaining <= 3
                                                ? AppColors.error
                                                : AppColors.warning,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Info row
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: cs.surface.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color:
                                    cs.outlineVariant.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                  child: _InfoMini(
                                      label: 'Requested',
                                      value: _formatDateTime(
                                          requestedAtRaw.toString(),
                                          withTime: false),
                                      icon: Icons.calendar_today_rounded)),
                              Container(
                                  width: 1,
                                  height: 36,
                                  color:
                                      cs.outlineVariant.withValues(alpha: 0.6)),
                              Expanded(
                                  child: _InfoMini(
                                      label: 'Scheduled',
                                      value: _formatDateTime(
                                          scheduledRaw.toString(),
                                          withTime: false),
                                      icon: Icons.event_rounded)),
                              Container(
                                  width: 1,
                                  height: 36,
                                  color:
                                      cs.outlineVariant.withValues(alpha: 0.6)),
                              Expanded(
                                  child: _InfoMini(
                                      label: 'Passed',
                                      value: '$daysPassed days',
                                      icon: Icons.timelapse_rounded)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (reasonRaw.isNotEmpty) ...[
                    _ReasonPreview(reason: reasonRaw),
                    const SizedBox(height: 14),
                  ],
                  _ProcessTimeline(isPending: true),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 18, color: cs.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'If you change your mind, you can cancel this request anytime before the scheduled deletion. Admin may approve or reject based on dues and subscription status.',
                            style: GoogleFonts.outfit(
                                fontSize: 12,
                                height: 1.4,
                                color: cs.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: cs.onSurface,
                            side: BorderSide(color: cs.outlineVariant),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text('Close',
                              style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isSubmitting
                              ? null
                              : () async {
                                  final confirmedContext = context;
                                  setState(() => _isSubmitting = true);
                                  try {
                                    await widget.onCancelRequest();
                                    if (!mounted) return;
                                    if (confirmedContext.mounted) {
                                      Navigator.pop(confirmedContext, 'cancel');
                                    }
                                  } finally {
                                    if (mounted) {
                                      setState(() => _isSubmitting = false);
                                    }
                                  }
                                },
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.undo_rounded, size: 18),
                          label: Text('Keep Account',
                              style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w700, fontSize: 14)),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // ── NEW REQUEST FLOW ──
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.12),
                              shape: BoxShape.circle),
                          child: const Icon(Icons.warning_amber_rounded,
                              size: 16, color: AppColors.error),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'This process is irreversible after approval',
                                  style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.error)),
                              const SizedBox(height: 4),
                              Text(
                                  'All your expenses, receipts, categories and account data will be permanently deleted and cannot be recovered.',
                                  style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      height: 1.4,
                                      color: cs.onSurfaceVariant)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('What happens next?',
                      style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface)),
                  const SizedBox(height: 10),
                  _ProcessTimeline(isPending: false),
                  const SizedBox(height: 16),
                  Text('Reason for leaving (optional)',
                      style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _reasonCtrl,
                    maxLines: 3,
                    minLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                    style:
                        GoogleFonts.outfit(fontSize: 14, color: cs.onSurface),
                    decoration: InputDecoration(
                      hintText:
                          'Tell us why you want to delete your account...',
                      hintStyle: GoogleFonts.outfit(
                          fontSize: 13,
                          color: cs.onSurfaceVariant.withValues(alpha: 0.7)),
                      filled: true,
                      fillColor:
                          cs.surfaceContainerHighest.withValues(alpha: 0.5),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            width: 1.2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () => setState(() => _understood = !_understood),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _understood
                            ? AppColors.primary.withValues(alpha: 0.06)
                            : cs.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _understood
                              ? AppColors.primary.withValues(alpha: 0.3)
                              : cs.outlineVariant.withValues(alpha: 0.6),
                          width: _understood ? 1.2 : 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Checkbox(
                              value: _understood,
                              onChanged: (v) =>
                                  setState(() => _understood = v ?? false),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                              activeColor: AppColors.primary,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    height: 1.4,
                                    color: cs.onSurface),
                                children: [
                                  const TextSpan(text: 'I understand that '),
                                  TextSpan(
                                    text:
                                        'all my data will be permanently deleted',
                                    style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.error),
                                  ),
                                  const TextSpan(
                                      text:
                                          ' after admin approval or auto-deletion in 30 days and cannot be recovered.'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: cs.onSurface,
                            side: BorderSide(color: cs.outlineVariant),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text('Cancel',
                              style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: (_understood && !_isSubmitting)
                              ? () async {
                                  final confirmedContext = context;
                                  setState(() => _isSubmitting = true);
                                  try {
                                    final reason = _reasonCtrl.text.trim();
                                    await widget.onRequest(
                                        reason.isEmpty ? null : reason);
                                    if (!mounted) return;
                                    if (confirmedContext.mounted) {
                                      Navigator.pop(
                                          confirmedContext, 'request');
                                    }
                                  } finally {
                                    if (mounted) {
                                      setState(() => _isSubmitting = false);
                                    }
                                  }
                                }
                              : null,
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.delete_forever_rounded,
                                  size: 18),
                          label: Text('Request Deletion',
                              style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w700, fontSize: 14)),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                AppColors.error.withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Admin review • 30-day grace • Permanent deletion',
                      style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoMini extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _InfoMini(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Icon(icon, size: 14, color: cs.onSurfaceVariant),
        const SizedBox(height: 4),
        Text(label,
            style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
                letterSpacing: 0.3)),
        const SizedBox(height: 2),
        Text(value,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: cs.onSurface)),
      ],
    );
  }
}

class _ReasonPreview extends StatelessWidget {
  final String reason;
  const _ReasonPreview({required this.reason});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.chat_bubble_outline_rounded,
                  size: 14, color: cs.onSurfaceVariant),
              const SizedBox(width: 6),
              Text('Your reason',
                  style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurfaceVariant,
                      letterSpacing: 0.3)),
            ],
          ),
          const SizedBox(height: 6),
          Text(reason,
              style: GoogleFonts.outfit(
                  fontSize: 12.5, height: 1.4, color: cs.onSurface)),
        ],
      ),
    );
  }
}

class _ProcessTimeline extends StatelessWidget {
  final bool isPending;
  const _ProcessTimeline({required this.isPending});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final steps = isPending
        ? [
            {
              'icon': Icons.send_rounded,
              'title': 'Request Sent',
              'desc': 'Deletion request created',
              'done': true
            },
            {
              'icon': Icons.admin_panel_settings_outlined,
              'title': 'Admin Review',
              'desc': 'Checking dues & status',
              'done': true,
              'current': true
            },
            {
              'icon': Icons.delete_forever_rounded,
              'title': 'Scheduled Deletion',
              'desc': 'Auto-delete after 30 days if no action',
              'done': false
            },
          ]
        : [
            {
              'icon': Icons.send_rounded,
              'title': 'Request Sent',
              'desc': 'Admin will be notified immediately',
              'done': false,
              'current': true
            },
            {
              'icon': Icons.verified_user_outlined,
              'title': 'Admin Review',
              'desc': 'Dues, subscription & compliance check',
              'done': false
            },
            {
              'icon': Icons.timer_outlined,
              'title': '30-Day Grace',
              'desc': 'Auto-deletion if admin takes no action',
              'done': false
            },
            {
              'icon': Icons.delete_forever_rounded,
              'title': 'Permanent Deletion',
              'desc': 'All data erased permanently',
              'done': false
            },
          ];

    return Column(
      children: steps.asMap().entries.map((entry) {
        final idx = entry.key;
        final step = entry.value;
        final isLast = idx == steps.length - 1;
        final isDone = step['done'] as bool;
        final isCurrent = (step['current'] as bool?) ?? false;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDone
                        ? AppColors.success.withValues(alpha: 0.15)
                        : isCurrent
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : cs.surfaceContainerHighest,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDone
                          ? AppColors.success.withValues(alpha: 0.3)
                          : isCurrent
                              ? AppColors.primary.withValues(alpha: 0.3)
                              : cs.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Icon(
                    isDone ? Icons.check_rounded : step['icon'] as IconData,
                    size: 16,
                    color: isDone
                        ? AppColors.success
                        : isCurrent
                            ? AppColors.primary
                            : cs.onSurfaceVariant,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 20,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: isDone
                        ? AppColors.success.withValues(alpha: 0.3)
                        : cs.outlineVariant.withValues(alpha: 0.4),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(step['title'] as String,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight:
                              isCurrent ? FontWeight.w700 : FontWeight.w600,
                          color: isCurrent ? AppColors.primary : cs.onSurface,
                        )),
                    const SizedBox(height: 2),
                    Text(step['desc'] as String,
                        style: GoogleFonts.outfit(
                            fontSize: 11.5,
                            height: 1.3,
                            color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
