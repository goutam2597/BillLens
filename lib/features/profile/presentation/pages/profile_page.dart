import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billlens/core/theme/app_colors.dart';
import 'package:billlens/core/router/app_routes.dart';
import 'package:billlens/core/widgets/app_widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/domain/entities/user_entity.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Log Out',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to log out of BillLens?',
          style: GoogleFonts.outfit(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.outfit(
                color: Theme.of(ctx).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthBloc>().add(LogoutEvent());
            },
            child: Text(
              'Log Out',
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

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Account',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            color: const Color(0xFFEF4444),
          ),
        ),
        content: Text(
          'This action is irreversible. All your data will be permanently deleted.',
          style: GoogleFonts.outfit(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.outfit(
                color: Theme.of(ctx).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Delete',
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

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          context.go(AppRoutes.welcome);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final user = state is Authenticated ? state.user : null;
          final isPremium = user?.isPremium ?? false;

          return Scaffold(
            backgroundColor: colorScheme.surfaceContainerLowest,
            body: CustomScrollView(
              slivers: [
                const AppRootSliverBar(title: 'Profile'),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildBody(
                      context,
                      isPremium: isPremium,
                      user: user,
                    ),
                  ),
                ),
              ],
            ),
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
              trailing: user?.currency ?? 'USD',
              iconColor: const Color(0xFF10B981),
              onTap: () {},
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
            ),
            alignment: Alignment.center,
            child: Text(
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
      child: Column(children: children),
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
