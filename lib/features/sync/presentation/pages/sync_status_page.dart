import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:billlens/core/theme/app_colors.dart';
import 'package:billlens/core/router/app_routes.dart';
import 'package:billlens/core/router/context_ext.dart';

// ---------------------------------------------------------------------------
// Sync item model
// ---------------------------------------------------------------------------
class _SyncItem {
  final String title;
  final String subtitle;
  final String time;
  final _SyncItemStatus status;
  final IconData icon;

  const _SyncItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.status,
    required this.icon,
  });
}

enum _SyncItemStatus { synced, pending, failed }

// ---------------------------------------------------------------------------
// Dummy data
// ---------------------------------------------------------------------------
const List<_SyncItem> _syncItems = [
  _SyncItem(
    title: 'Starbucks – \$12.50',
    subtitle: 'Expense record synced',
    time: '10:31 AM',
    status: _SyncItemStatus.synced,
    icon: Icons.local_cafe_rounded,
  ),
  _SyncItem(
    title: 'Uber – \$25.00',
    subtitle: 'Expense record synced',
    time: '10:30 AM',
    status: _SyncItemStatus.synced,
    icon: Icons.directions_car_rounded,
  ),
  _SyncItem(
    title: 'Staples – \$75.00',
    subtitle: 'Waiting for network',
    time: '10:15 AM',
    status: _SyncItemStatus.pending,
    icon: Icons.inventory_2_rounded,
  ),
  _SyncItem(
    title: 'Amazon – \$49.99',
    subtitle: 'Waiting for network',
    time: '10:02 AM',
    status: _SyncItemStatus.pending,
    icon: Icons.shopping_bag_rounded,
  ),
  _SyncItem(
    title: 'Delta Airlines – \$340.00',
    subtitle: 'Server error – tap to retry',
    time: '09:45 AM',
    status: _SyncItemStatus.failed,
    icon: Icons.flight_rounded,
  ),
  _SyncItem(
    title: 'Receipt image (receipt_004.jpg)',
    subtitle: 'Upload failed – tap to retry',
    time: '09:30 AM',
    status: _SyncItemStatus.failed,
    icon: Icons.image_rounded,
  ),
];

// ---------------------------------------------------------------------------
// Sync Status Page
// ---------------------------------------------------------------------------
class SyncStatusPage extends StatefulWidget {
  const SyncStatusPage({super.key});

  @override
  State<SyncStatusPage> createState() => _SyncStatusPageState();
}

class _SyncStatusPageState extends State<SyncStatusPage>
    with TickerProviderStateMixin {
  bool _isSyncing = false;
  bool _syncDone = false;
  double _syncProgress = 0.0;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startSync() async {
    setState(() {
      _isSyncing = true;
      _syncDone = false;
      _syncProgress = 0.0;
    });

    // Simulate progress
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 180));
      if (!mounted) return;
      setState(() => _syncProgress = i / 10.0);
    }

    if (!mounted) return;
    setState(() {
      _isSyncing = false;
      _syncDone = true;
    });

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _syncDone = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    const int offlineCount = 125;
    const int pendingCount = 8;
    const int failedCount = 2;
    const String lastSync = 'Today, 10:31 AM';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: textPrimary, size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.safePop(AppRoutes.profile);
            } else {
              context.go(AppRoutes.dashboard);
            }
          },
        ),
        title: Text(
          'Sync Status',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              onPressed: _isSyncing ? null : _startSync,
              icon: _isSyncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    )
                  : Icon(Icons.refresh_rounded, color: textPrimary),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      body: Column(
        children: [
          // Sync progress bar
          if (_isSyncing)
            LinearProgressIndicator(
              value: _syncProgress,
              backgroundColor: AppColors.primarySurface,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 3,
            ),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Sync Hero Card ────────────────────────────────────────
                  _SyncHeroCard(
                    isDark: isDark,
                    isSyncing: _isSyncing,
                    syncDone: _syncDone,
                    syncProgress: _syncProgress,
                    pulseAnimation: _pulseAnimation,
                    pendingCount: pendingCount,
                    failedCount: failedCount,
                    lastSync: lastSync,
                    onSyncNow: _isSyncing ? null : _startSync,
                  ),

                  const SizedBox(height: 20),

                  // ── Statistics Row ────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Offline Records',
                          value: offlineCount.toString(),
                          icon: Icons.storage_rounded,
                          color: AppColors.primary,
                          isDark: isDark,
                          surfaceColor: surfaceColor,
                          borderColor: borderColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          label: 'Pending Sync',
                          value: pendingCount.toString(),
                          icon: Icons.pending_outlined,
                          color: AppColors.warning,
                          isDark: isDark,
                          surfaceColor: surfaceColor,
                          borderColor: borderColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          label: 'Failed',
                          value: failedCount.toString(),
                          icon: Icons.error_outline_rounded,
                          color: AppColors.error,
                          isDark: isDark,
                          surfaceColor: surfaceColor,
                          borderColor: borderColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Recent Sync Activity ──────────────────────────────────
                  Text(
                    'Recent Activity',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ..._syncItems.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _SyncItemCard(
                        item: item,
                        isDark: isDark,
                        surfaceColor: surfaceColor,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        borderColor: borderColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Retry Failed button ───────────────────────────────────
                  if (failedCount > 0)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isSyncing ? null : _startSync,
                        icon: const Icon(Icons.replay_rounded,
                            color: AppColors.error, size: 18),
                        label: Text(
                          'Retry $failedCount Failed Item${failedCount > 1 ? 's' : ''}',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sync Hero Card
// ---------------------------------------------------------------------------
class _SyncHeroCard extends StatelessWidget {
  final bool isDark;
  final bool isSyncing;
  final bool syncDone;
  final double syncProgress;
  final Animation<double> pulseAnimation;
  final int pendingCount;
  final int failedCount;
  final String lastSync;
  final VoidCallback? onSyncNow;

  const _SyncHeroCard({
    required this.isDark,
    required this.isSyncing,
    required this.syncDone,
    required this.syncProgress,
    required this.pulseAnimation,
    required this.pendingCount,
    required this.failedCount,
    required this.lastSync,
    required this.onSyncNow,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    String statusLabel;

    if (syncDone) {
      statusColor = AppColors.success;
      statusIcon = Icons.check_circle_rounded;
      statusLabel = 'All synced!';
    } else if (isSyncing) {
      statusColor = AppColors.primary;
      statusIcon = Icons.sync_rounded;
      statusLabel = 'Syncing...';
    } else if (failedCount > 0) {
      statusColor = AppColors.error;
      statusIcon = Icons.error_rounded;
      statusLabel = '$failedCount item${failedCount > 1 ? 's' : ''} failed';
    } else if (pendingCount > 0) {
      statusColor = AppColors.warning;
      statusIcon = Icons.pending_rounded;
      statusLabel = '$pendingCount item${pendingCount > 1 ? 's' : ''} pending';
    } else {
      statusColor = AppColors.success;
      statusIcon = Icons.cloud_done_rounded;
      statusLabel = 'All up to date';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withValues(alpha: 0.12),
            statusColor.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          // Icon + status
          Row(
            children: [
              AnimatedBuilder(
                animation: pulseAnimation,
                builder: (_, child) => Transform.scale(
                  scale: isSyncing ? pulseAnimation.value : 1.0,
                  child: child,
                ),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 28),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusLabel,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Last sync: $lastSync',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: statusColor.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (isSyncing) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: syncProgress,
                backgroundColor: statusColor.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${(syncProgress * 100).toInt()}%',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
          ],

          if (!isSyncing) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onSyncNow,
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppColors.primaryShadow,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.sync_rounded,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Sync Now',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stat Card
// ---------------------------------------------------------------------------
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;
  final Color surfaceColor;
  final Color borderColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.surfaceColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow:
            isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sync Item Card
// ---------------------------------------------------------------------------
class _SyncItemCard extends StatelessWidget {
  final _SyncItem item;
  final bool isDark;
  final Color surfaceColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color borderColor;

  const _SyncItemCard({
    required this.item,
    required this.isDark,
    required this.surfaceColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.borderColor,
  });

  Color get _statusColor {
    switch (item.status) {
      case _SyncItemStatus.synced:
        return AppColors.success;
      case _SyncItemStatus.pending:
        return AppColors.warning;
      case _SyncItemStatus.failed:
        return AppColors.error;
    }
  }

  IconData get _statusIcon {
    switch (item.status) {
      case _SyncItemStatus.synced:
        return Icons.check_circle_rounded;
      case _SyncItemStatus.pending:
        return Icons.schedule_rounded;
      case _SyncItemStatus.failed:
        return Icons.error_rounded;
    }
  }

  String get _statusLabel {
    switch (item.status) {
      case _SyncItemStatus.synced:
        return 'Synced';
      case _SyncItemStatus.pending:
        return 'Pending';
      case _SyncItemStatus.failed:
        return 'Failed';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow:
            isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: _statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Time + status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_statusIcon, color: _statusColor, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    _statusLabel,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _statusColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                item.time,
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
