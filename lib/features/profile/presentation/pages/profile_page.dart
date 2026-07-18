import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:billlens/core/theme/app_colors.dart';
import 'package:billlens/core/router/app_routes.dart';
import 'package:billlens/core/widgets/app_widgets.dart';
import 'package:billlens/core/utils/app_logger.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/domain/entities/user_entity.dart';
import 'package:billlens/core/di/injection.dart';
import '../../../../core/local/local_storage_service.dart';
import '../../../auth/data/repositories/user_repository.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/delete_account_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthBloc>().add(CheckAuthStatus());
        try {
          context.read<ProfileBloc>().add(LoadDeletionStatus());
        } catch (_) {}
      }
    });
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Theme.of(ctx).colorScheme.surface,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded,
                    color: AppColors.primary, size: 32),
              ),
              const SizedBox(height: 20),
              Text(
                'Log Out',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(ctx).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to log out? You will need to sign in again to access your expenses.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(
                            color: Theme.of(ctx).colorScheme.outlineVariant),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.outfit(
                          color: Theme.of(ctx).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        context.read<AuthBloc>().add(LogoutEvent());
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Log Out',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog({Map<String, dynamic>? existingRequest}) {
    // Use new premium dialog widget
    showDeleteAccountDialog(
      context,
      deletionData: existingRequest,
      onRequest: (reason) async {
        AppLogger.i('Requesting account deletion: $reason');
        if (!mounted) return;
        context.read<ProfileBloc>().add(RequestDeleteAccount(reason: reason));
      },
      onCancelRequest: () async {
        AppLogger.i('Cancelling deletion request');
        if (!mounted) return;
        context.read<ProfileBloc>().add(CancelDeleteRequest());
      },
    );
  }

  void _showCurrencySelector(UserEntity? user) {
    // Single source of truth: server user currency > local storage
    final current = user?.currency.isNotEmpty == true
        ? user!.currency
        : getIt<LocalStorageService>().currency;
    showDialog(
      context: context,
      builder: (ctx) => _CurrencyPickerDialog(
        currentCurrency: current,
        onCurrencySelected: (code) async {
          if (code == current) return;
          // Show loading
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Text('Updating currency to $code...'),
                ]),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }

          try {
            if (user != null) {
              final repo = getIt<UserRepository>();
              final result =
                  await repo.updateProfile(userId: user.id, currency: code);
              result.fold(
                (failure) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Failed to update currency: ${failure.message}'),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  }
                },
                (updatedUser) async {
                  // Success — AuthRepository already synced local prefs via updateProfile.
                  // Force refresh AuthBloc to rebuild all listeners with new currency.
                  if (mounted) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Currency changed to $code (${updatedUser.currency})'),
                        backgroundColor: AppColors.accent,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                    context.read<AuthBloc>().add(CheckAuthStatus());
                    // Also reload profile to reflect new currency immediately
                    context.read<ProfileBloc>().add(LoadProfile());
                  }
                },
              );
            } else {
              // No user (offline) — save locally only, will sync on next login
              final storage = getIt<LocalStorageService>();
              await storage.setCurrency(code);
              if (mounted) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Currency saved locally as $code. Will sync on login.'),
                    backgroundColor: AppColors.warning,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                // Reload auth to propagate
                context.read<AuthBloc>().add(CheckAuthStatus());
              }
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to update currency: ${e.toString()}'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is Unauthenticated) {
              context.go(AppRoutes.login);
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error),
              );
            }
          },
        ),
        BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is DeletionRequested) {
              final scheduled = state.data['scheduled_deletion_at'] ?? '';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Delete request sent. Scheduled deletion: ${scheduled.toString().substring(0, 10)} (30 days). Admin will review.'),
                  backgroundColor: AppColors.warning,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 4),
                ),
              );
            } else if (state is DeletionCancelled) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'Deletion request cancelled. Account is now active.'),
                    backgroundColor: AppColors.accent,
                    behavior: SnackBarBehavior.floating),
              );
            } else if (state is DeletionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating),
              );
            } else if (state is ProfileSessionInvalid) {
              // The backend rejected the session (user deleted/blocked/token
              // revoked). Force a local logout so go_router redirects to login.
              context.read<AuthBloc>().add(ForceLogoutEvent());
            } else if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error),
              );
            }
          },
        ),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final user = authState is Authenticated ? authState.user : null;
          return FutureBuilder<bool>(
            future: () async {
              try {
                final dio = getIt<Dio>(instanceName: 'dio');
                final resp = await dio.get('/api/subscription/usage');
                if (resp.statusCode == 200) {
                  final data = resp.data['data'] as Map<String, dynamic>?;
                  if (data != null) {
                    return data['is_premium'] as bool? ?? false;
                  }
                }
              } catch (_) {}
              return user?.isPremium ?? false;
            }(),
            builder: (context, snapshot) {
              final isPremium = snapshot.data ?? (user?.isPremium ?? false);

              return Scaffold(
                backgroundColor: colorScheme.surfaceContainerLowest,
                body: RefreshIndicator(
                  onRefresh: () async {
                    context.read<AuthBloc>().add(CheckAuthStatus());
                    context.read<ProfileBloc>().add(LoadProfile());
                    context.read<ProfileBloc>().add(LoadDeletionStatus());
                    await Future.delayed(const Duration(milliseconds: 600));
                  },
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      const AppRootSliverBar(title: 'Profile'),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
                          child: Column(
                            children: [
                              _buildBody(context,
                                  isPremium: isPremium, user: user),
                              const SizedBox(height: 16),
                              BlocBuilder<ProfileBloc, ProfileState>(
                                builder: (context, profileState) {
                                  Map<String, dynamic>? deletionData;
                                  if (profileState is ProfileLoaded) {
                                    deletionData = profileState.deletionStatus;
                                  } else if (profileState
                                      is DeletionStatusLoaded) {
                                    deletionData = profileState.data;
                                  } else if (profileState
                                      is DeletionRequested) {
                                    deletionData = profileState.data;
                                  }

                                  final hasPending = deletionData != null &&
                                      deletionData['has_request'] == true;
                                  if (!hasPending) {
                                    return const SizedBox.shrink();
                                  }

                                  final request = deletionData['request']
                                      as Map<String, dynamic>?;
                                  final rawDays = request?['days_remaining'] ??
                                      deletionData['days_remaining'];
                                  int daysRemaining = 30;
                                  if (rawDays is int) daysRemaining = rawDays;
                                  if (rawDays is String) {
                                    daysRemaining = int.tryParse(rawDays) ?? 30;
                                  }
                                  if (rawDays is double) {
                                    daysRemaining = rawDays.toInt();
                                  }

                                  final scheduled = request?[
                                          'scheduled_deletion_at'] ??
                                      deletionData['scheduled_deletion_at'] ??
                                      '';
                                  final requestedAtRaw =
                                      request?['requested_at'] ??
                                          deletionData['requested_at'] ??
                                          '';

                                  int daysPassed = 0;
                                  final rawPassed =
                                      request?['days_passed'] ?? 0;
                                  if (rawPassed is int) daysPassed = rawPassed;
                                  if (rawPassed is String) {
                                    daysPassed = int.tryParse(rawPassed) ?? 0;
                                  }
                                  if (daysPassed == 0 &&
                                      requestedAtRaw.toString().isNotEmpty) {
                                    try {
                                      final rd = DateTime.parse(
                                          requestedAtRaw.toString());
                                      daysPassed = DateTime.now()
                                          .difference(rd)
                                          .inDays
                                          .clamp(0, 30);
                                    } catch (_) {}
                                  }

                                  String fmtDate(String? raw) {
                                    if (raw == null || raw.isEmpty) return '--';
                                    try {
                                      final dt = DateTime.parse(raw);
                                      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
                                    } catch (_) {
                                      return raw.length > 10
                                          ? raw.substring(0, 10)
                                          : raw;
                                    }
                                  }

                                  final progress =
                                      (daysPassed / 30.0).clamp(0.0, 1.0);
                                  final cs = Theme.of(context).colorScheme;

                                  return Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: cs.surface,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                          color: AppColors.warning
                                              .withValues(alpha: 0.28),
                                          width: 1.2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.warning
                                              .withValues(alpha: 0.1),
                                          blurRadius: 20,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                AppColors.warning
                                                    .withValues(alpha: 0.16),
                                                AppColors.warning
                                                    .withValues(alpha: 0.04),
                                              ],
                                            ),
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                    top: Radius.circular(17)),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(7),
                                                decoration: BoxDecoration(
                                                  color: AppColors.warning
                                                      .withValues(alpha: 0.18),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: const Icon(
                                                    Icons.warning_amber_rounded,
                                                    size: 16,
                                                    color: AppColors.warning),
                                              ),
                                              const SizedBox(width: 10),
                                              Text('Deletion Requested',
                                                  style: GoogleFonts.outfit(
                                                      fontSize: 13.5,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color:
                                                          AppColors.warning)),
                                              const Spacer(),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                decoration: BoxDecoration(
                                                  color: (daysRemaining <= 3
                                                          ? AppColors.error
                                                          : AppColors.warning)
                                                      .withValues(alpha: 0.14),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                        Icons
                                                            .hourglass_bottom_rounded,
                                                        size: 12,
                                                        color: daysRemaining <=
                                                                3
                                                            ? AppColors.error
                                                            : AppColors
                                                                .warning),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                        '$daysRemaining days left',
                                                        style: GoogleFonts.outfit(
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            color: daysRemaining <=
                                                                    3
                                                                ? AppColors
                                                                    .error
                                                                : AppColors
                                                                    .warning)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              16, 14, 16, 14),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: _DeletionMiniChip(
                                                      icon: Icons
                                                          .calendar_today_rounded,
                                                      label: 'Requested',
                                                      value: fmtDate(
                                                          requestedAtRaw
                                                              .toString()),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: _DeletionMiniChip(
                                                      icon: Icons.event_rounded,
                                                      label: 'Scheduled',
                                                      value: fmtDate(
                                                          scheduled.toString()),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: _DeletionMiniChip(
                                                      icon: Icons
                                                          .timelapse_rounded,
                                                      label: 'Passed',
                                                      value: '$daysPassed days',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 14),
                                              Row(
                                                children: [
                                                  Text('Progress',
                                                      style: GoogleFonts.outfit(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: cs
                                                              .onSurfaceVariant)),
                                                  const Spacer(),
                                                  Text('Day $daysPassed of 30',
                                                      style: GoogleFonts.outfit(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: cs
                                                              .onSurfaceVariant)),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                                child: LinearProgressIndicator(
                                                  value: progress,
                                                  minHeight: 6,
                                                  backgroundColor: Colors.black
                                                      .withValues(alpha: 0.06),
                                                  valueColor:
                                                      AlwaysStoppedAnimation(
                                                          daysRemaining <= 3
                                                              ? AppColors.error
                                                              : AppColors
                                                                  .warning),
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                  'Admin will review your account. If no action within $daysRemaining days, your account will be automatically deleted. All expenses and receipts will be permanently erased.',
                                                  style: GoogleFonts.outfit(
                                                      fontSize: 12,
                                                      height: 1.45,
                                                      color:
                                                          cs.onSurfaceVariant)),
                                              const SizedBox(height: 14),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: FilledButton.icon(
                                                      onPressed: () =>
                                                          _showDeleteDialog(
                                                              existingRequest:
                                                                  deletionData),
                                                      icon: const Icon(
                                                          Icons
                                                              .visibility_outlined,
                                                          size: 16),
                                                      label: Text('Details',
                                                          style: GoogleFonts
                                                              .outfit(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize:
                                                                      12.5)),
                                                      style: FilledButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.white,
                                                        foregroundColor:
                                                            cs.onSurface,
                                                        side: BorderSide(
                                                            color: cs
                                                                .outlineVariant),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 16),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: FilledButton.icon(
                                                      onPressed: () => context
                                                          .read<ProfileBloc>()
                                                          .add(
                                                              CancelDeleteRequest()),
                                                      icon: const Icon(
                                                          Icons.undo_rounded,
                                                          size: 16),
                                                      label: Text(
                                                          'Keep Account',
                                                          style: GoogleFonts
                                                              .outfit(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  fontSize:
                                                                      12.5)),
                                                      style: FilledButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            AppColors.primary,
                                                        foregroundColor:
                                                            Colors.white,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 16),
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
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context, {
    required bool isPremium,
    required UserEntity? user,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIdentityPanel(context, user, isPremium),
        const SizedBox(height: 20),
        const AppSectionHeader(title: 'Account'),
        const SizedBox(height: 8),
        _buildSectionCard(
          context: context,
          children: [
            _buildProfileTile(
              context: context,
              icon: Icons.person_outline,
              title: 'Edit Profile',
              iconColor: const Color(0xFF2563EB),
              onTap: () => context.push(AppRoutes.editProfile),
            ),
            _buildDivider(colorScheme.outlineVariant),
            _buildProfileTile(
              context: context,
              icon: Icons.lock_outline,
              title: 'Change Password',
              iconColor: const Color(0xFF7C3AED),
              onTap: () => context.push(AppRoutes.changePassword),
            ),
            _buildDivider(colorScheme.outlineVariant),
            _buildProfileTile(
              context: context,
              icon: Icons.attach_money,
              title: 'Currency',
              trailing: (user?.currency.isNotEmpty == true
                  ? user!.currency
                  : getIt<LocalStorageService>().currency),
              iconColor: const Color(0xFF10B981),
              onTap: () => _showCurrencySelector(user),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const AppSectionHeader(title: 'Subscription'),
        const SizedBox(height: 8),
        _buildSectionCard(
          context: context,
          children: [
            _buildProfileTile(
              context: context,
              icon: Icons.star_outline,
              title: 'My Plan',
              trailing: isPremium ? 'Premium' : 'Free',
              iconColor: const Color(0xFFF59E0B),
              onTap: () => context.push(AppRoutes.subscription),
            ),
            if (!isPremium) ...[
              _buildDivider(colorScheme.outlineVariant),
              _buildProfileTile(
                context: context,
                icon: Icons.upgrade,
                title: 'Upgrade to Premium',
                iconColor: const Color(0xFF2563EB),
                onTap: () => context.push(AppRoutes.subscription),
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),
        const AppSectionHeader(title: 'Data'),
        const SizedBox(height: 8),
        _buildSectionCard(
          context: context,
          children: [
            _buildProfileTile(
              context: context,
              icon: Icons.download_outlined,
              title: 'Export Data',
              iconColor: const Color(0xFF10B981),
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 20),
        const AppSectionHeader(title: 'Support'),
        const SizedBox(height: 8),
        _buildSectionCard(
          context: context,
          children: [
            _buildProfileTile(
              context: context,
              icon: Icons.help_outline,
              title: 'Help & Support',
              iconColor: const Color(0xFF2563EB),
              onTap: () => context.push(AppRoutes.helpSupport),
            ),
            _buildDivider(colorScheme.outlineVariant),
            _buildProfileTile(
              context: context,
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              iconColor: const Color(0xFF7C3AED),
              onTap: () {},
            ),
            _buildDivider(colorScheme.outlineVariant),
            _buildProfileTile(
              context: context,
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              iconColor: const Color(0xFF64748B),
              onTap: () {},
            ),
            _buildDivider(colorScheme.outlineVariant),
            _buildProfileTile(
              context: context,
              icon: Icons.info_outline,
              title: 'App Version',
              trailing: '1.0.0',
              iconColor: const Color(0xFF94A3B8),
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 20),
        AppSectionHeader(
          title: 'Danger Zone',
          key: ValueKey(colorScheme.error),
        ),
        const SizedBox(height: 8),
        _buildSectionCard(
          context: context,
          borderColor: colorScheme.error.withValues(alpha: 0.3),
          children: [
            ListTile(
              leading:
                  const Icon(Icons.logout, color: Color(0xFFEF4444), size: 22),
              title: Text(
                'Log Out',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFEF4444),
                ),
              ),
              trailing:
                  const Icon(Icons.chevron_right, color: Color(0xFFEF4444)),
              onTap: _showLogoutDialog,
            ),
            _buildDivider(const Color(0xFFEF4444).withValues(alpha: 0.15)),
            ListTile(
              leading: const Icon(Icons.delete_forever_outlined,
                  color: Color(0xFFEF4444), size: 22),
              title: Text(
                'Delete Account',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFEF4444),
                ),
              ),
              trailing:
                  const Icon(Icons.chevron_right, color: Color(0xFFEF4444)),
              onTap: _showDeleteDialog,
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildIdentityPanel(
    BuildContext context,
    UserEntity? user,
    bool isPremium,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppGroupedSurface(
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              image: user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(user.avatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
                ? null
                : Text(
                    user?.initials ?? 'U',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'User',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  user?.email ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: (isPremium ? const Color(0xFFF59E0B) : AppColors.primary)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              isPremium ? 'Premium' : 'Free',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isPremium ? const Color(0xFFF59E0B) : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required List<Widget> children,
    Color? borderColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: borderColor ?? colorScheme.outlineVariant,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildProfileTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color iconColor,
    required VoidCallback onTap,
    String? trailing,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),
      trailing: trailing != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  trailing,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                  size: 18,
                ),
              ],
            )
          : Icon(
              Icons.chevron_right,
              color: colorScheme.onSurfaceVariant,
              size: 18,
            ),
      onTap: onTap,
    );
  }

  Widget _buildDivider(Color color) {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: color,
    );
  }
}

class _DeletionMiniChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DeletionMiniChip(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 13, color: cs.onSurfaceVariant),
          const SizedBox(height: 3),
          Text(label,
              style: GoogleFonts.outfit(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurfaceVariant,
                  letterSpacing: 0.3)),
          const SizedBox(height: 2),
          Text(value,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ─── Currency Picker Dialog ────────────────────────────────────────────────────

class _CurrencyPickerDialog extends StatefulWidget {
  final String currentCurrency;
  final Future<void> Function(String code) onCurrencySelected;

  const _CurrencyPickerDialog({
    required this.currentCurrency,
    required this.onCurrencySelected,
  });

  @override
  State<_CurrencyPickerDialog> createState() => _CurrencyPickerDialogState();
}

class _CurrencyPickerDialogState extends State<_CurrencyPickerDialog> {
  static const _allCurrencies = [
    {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar'},
    {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
    {'code': 'GBP', 'symbol': '£', 'name': 'British Pound'},
    {'code': 'INR', 'symbol': '₹', 'name': 'Indian Rupee'},
    {'code': 'JPY', 'symbol': '¥', 'name': 'Japanese Yen'},
    {'code': 'CAD', 'symbol': 'C\$', 'name': 'Canadian Dollar'},
    {'code': 'AUD', 'symbol': 'A\$', 'name': 'Australian Dollar'},
    {'code': 'BDT', 'symbol': '৳', 'name': 'Bangladeshi Taka'},
    {'code': 'CHF', 'symbol': 'Fr', 'name': 'Swiss Franc'},
    {'code': 'CNY', 'symbol': '¥', 'name': 'Chinese Yuan'},
    {'code': 'BRL', 'symbol': 'R\$', 'name': 'Brazilian Real'},
    {'code': 'RUB', 'symbol': '₽', 'name': 'Russian Ruble'},
    {'code': 'KRW', 'symbol': '₩', 'name': 'South Korean Won'},
    {'code': 'SGD', 'symbol': 'S\$', 'name': 'Singapore Dollar'},
    {'code': 'NZD', 'symbol': 'NZ\$', 'name': 'New Zealand Dollar'},
    {'code': 'MXN', 'symbol': 'MX\$', 'name': 'Mexican Peso'},
    {'code': 'HKD', 'symbol': 'HK\$', 'name': 'Hong Kong Dollar'},
    {'code': 'TRY', 'symbol': '₺', 'name': 'Turkish Lira'},
    {'code': 'ZAR', 'symbol': 'R', 'name': 'South African Rand'},
    {'code': 'SEK', 'symbol': 'kr', 'name': 'Swedish Krona'},
    {'code': 'NOK', 'symbol': 'kr', 'name': 'Norwegian Krone'},
    {'code': 'DKK', 'symbol': 'kr', 'name': 'Danish Krone'},
    {'code': 'IDR', 'symbol': 'Rp', 'name': 'Indonesian Rupiah'},
    {'code': 'MYR', 'symbol': 'RM', 'name': 'Malaysian Ringgit'},
    {'code': 'PHP', 'symbol': '₱', 'name': 'Philippine Peso'},
    {'code': 'THB', 'symbol': '฿', 'name': 'Thai Baht'},
    {'code': 'VND', 'symbol': '₫', 'name': 'Vietnamese Dong'},
    {'code': 'AED', 'symbol': 'د.إ', 'name': 'UAE Dirham'},
    {'code': 'SAR', 'symbol': '﷼', 'name': 'Saudi Riyal'},
    {'code': 'EGP', 'symbol': 'E£', 'name': 'Egyptian Pound'},
    {'code': 'PKR', 'symbol': '₨', 'name': 'Pakistani Rupee'},
    {'code': 'LKR', 'symbol': '₨', 'name': 'Sri Lankan Rupee'},
    {'code': 'NPR', 'symbol': '₨', 'name': 'Nepalese Rupee'},
    {'code': 'MMK', 'symbol': 'K', 'name': 'Myanmar Kyat'},
    {'code': 'KZT', 'symbol': '₸', 'name': 'Kazakhstani Tenge'},
    {'code': 'UAH', 'symbol': '₴', 'name': 'Ukrainian Hryvnia'},
    {'code': 'PLN', 'symbol': 'zł', 'name': 'Polish Złoty'},
    {'code': 'CZK', 'symbol': 'Kč', 'name': 'Czech Koruna'},
    {'code': 'HUF', 'symbol': 'Ft', 'name': 'Hungarian Forint'},
    {'code': 'RON', 'symbol': 'lei', 'name': 'Romanian Leu'},
    {'code': 'BGN', 'symbol': 'лв', 'name': 'Bulgarian Lev'},
    {'code': 'HRK', 'symbol': 'kn', 'name': 'Croatian Kuna'},
    {'code': 'ISK', 'symbol': 'kr', 'name': 'Icelandic Króna'},
    {'code': 'GEL', 'symbol': '₾', 'name': 'Georgian Lari'},
    {'code': 'AMD', 'symbol': '֏', 'name': 'Armenian Dram'},
    {'code': 'AZN', 'symbol': '₼', 'name': 'Azerbaijani Manat'},
    {'code': 'NGN', 'symbol': '₦', 'name': 'Nigerian Naira'},
    {'code': 'GHS', 'symbol': '₵', 'name': 'Ghanaian Cedi'},
    {'code': 'KES', 'symbol': 'KSh', 'name': 'Kenyan Shilling'},
    {'code': 'TZS', 'symbol': 'TSh', 'name': 'Tanzanian Shilling'},
    {'code': 'MAD', 'symbol': 'د.م.', 'name': 'Moroccan Dirham'},
    {'code': 'TND', 'symbol': 'د.ت', 'name': 'Tunisian Dinar'},
    {'code': 'DZD', 'symbol': 'دج', 'name': 'Algerian Dinar'},
    {'code': 'LYD', 'symbol': 'ل.د', 'name': 'Libyan Dinar'},
    {'code': 'QAR', 'symbol': 'ر.ق', 'name': 'Qatari Riyal'},
    {'code': 'KWD', 'symbol': 'د.ك', 'name': 'Kuwaiti Dinar'},
    {'code': 'BHD', 'symbol': 'BD', 'name': 'Bahraini Dinar'},
    {'code': 'OMR', 'symbol': 'ر.ع.', 'name': 'Omani Rial'},
    {'code': 'JOD', 'symbol': 'JD', 'name': 'Jordanian Dinar'},
    {'code': 'IQD', 'symbol': 'ع.د', 'name': 'Iraqi Dinar'},
    {'code': 'IRR', 'symbol': '﷼', 'name': 'Iranian Rial'},
    {'code': 'ILS', 'symbol': '₪', 'name': 'Israeli Shekel'},
    {'code': 'TWD', 'symbol': 'NT\$', 'name': 'Taiwan Dollar'},
    {'code': 'CLP', 'symbol': 'CLP\$', 'name': 'Chilean Peso'},
    {'code': 'COP', 'symbol': 'COL\$', 'name': 'Colombian Peso'},
    {'code': 'ARS', 'symbol': 'AR\$', 'name': 'Argentine Peso'},
    {'code': 'PEN', 'symbol': 'S/.', 'name': 'Peruvian Sol'},
    {'code': 'BOB', 'symbol': 'Bs.', 'name': 'Bolivian Boliviano'},
    {'code': 'PYG', 'symbol': '₲', 'name': 'Paraguayan Guaraní'},
    {'code': 'UYU', 'symbol': '\$U', 'name': 'Uruguayan Peso'},
    {'code': 'VEF', 'symbol': 'Bs.F', 'name': 'Venezuelan Bolívar'},
  ];

  final _searchController = TextEditingController();
  List<Map<String, String>> _filtered = List.from(_allCurrencies);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearch);
    // Bubble current currency to top
    _filtered = _sortWithCurrentFirst(_allCurrencies);
  }

  List<Map<String, String>> _sortWithCurrentFirst(
      List<Map<String, String>> list) {
    final sorted = List<Map<String, String>>.from(list);
    sorted.sort((a, b) {
      if (a['code'] == widget.currentCurrency) return -1;
      if (b['code'] == widget.currentCurrency) return 1;
      return a['name']!.compareTo(b['name']!);
    });
    return sorted;
  }

  void _onSearch() {
    final q = _searchController.text.toLowerCase().trim();
    setState(() {
      if (q.isEmpty) {
        _filtered = _sortWithCurrentFirst(_allCurrencies);
      } else {
        _filtered = _allCurrencies
            .where((c) =>
                c['name']!.toLowerCase().contains(q) ||
                c['code']!.toLowerCase().contains(q) ||
                c['symbol']!.toLowerCase().contains(q))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: cs.surface,
      elevation: 8,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: SizedBox(
        width: double.maxFinite,
        height: 620,
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 12, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.currency_exchange_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Select Currency',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: cs.onSurfaceVariant),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          cs.surfaceContainerHighest.withValues(alpha: 0.6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      minimumSize: const Size(38, 38),
                    ),
                  ),
                ],
              ),
            ),

            // ── Search Field ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: TextField(
                controller: _searchController,
                autofocus: false,
                style: GoogleFonts.outfit(fontSize: 15, color: cs.onSurface),
                decoration: InputDecoration(
                  hintText: 'Search by name or code…',
                  hintStyle: GoogleFonts.outfit(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(Icons.search_rounded,
                      color: cs.onSurfaceVariant, size: 22),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded,
                              color: cs.onSurfaceVariant, size: 20),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark
                      ? cs.surfaceContainerHighest.withValues(alpha: 0.5)
                      : cs.surfaceContainerHighest.withValues(alpha: 0.4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),

            Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.5)),

            // ── Results count ─────────────────────────────────────────────────
            if (_searchController.text.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Row(
                  children: [
                    Text(
                      '${_filtered.length} result${_filtered.length == 1 ? '' : 's'}',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            // ── List ──────────────────────────────────────────────────────────
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off_rounded,
                              size: 48,
                              color:
                                  cs.onSurfaceVariant.withValues(alpha: 0.4)),
                          const SizedBox(height: 12),
                          Text(
                            'No currencies found',
                            style: GoogleFonts.outfit(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Try a different search term',
                            style: GoogleFonts.outfit(
                              color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      itemCount: _filtered.length,
                      itemBuilder: (ctx, index) {
                        final currency = _filtered[index];
                        final isSelected =
                            currency['code'] == widget.currentCurrency;

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () async {
                              final code = currency['code']!;
                              Navigator.pop(context);
                              if (code == widget.currentCurrency) return;
                              await widget.onCurrencySelected(code);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                          .withValues(alpha: 0.08)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(14),
                                  border: isSelected
                                      ? Border.all(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.3),
                                          width: 1.5)
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    // Symbol badge
                                    Container(
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.primary
                                            : cs.surfaceContainerHighest
                                                .withValues(alpha: 0.6),
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        currency['symbol']!,
                                        style: GoogleFonts.outfit(
                                          color: isSelected
                                              ? Colors.white
                                              : cs.onSurfaceVariant,
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                              currency['symbol']!.length > 2
                                                  ? 11
                                                  : 16,
                                        ),
                                        maxLines: 1,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    // Name & code
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            currency['name']!,
                                            style: GoogleFonts.outfit(
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.w500,
                                              fontSize: 15,
                                              color: isSelected
                                                  ? AppColors.primary
                                                  : cs.onSurface,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            currency['code']!,
                                            style: GoogleFonts.outfit(
                                              fontSize: 13,
                                              color: cs.onSurfaceVariant,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Check mark
                                    if (isSelected)
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check_rounded,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
