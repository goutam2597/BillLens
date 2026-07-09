import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billlens/core/theme/app_colors.dart';
import 'package:billlens/core/router/app_routes.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final bool _isPremium = true;

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
              style: GoogleFonts.outfit(color: const Color(0xFF64748B)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
              style: GoogleFonts.outfit(color: const Color(0xFF64748B)),
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
      body: BlocListener<AuthBloc, AuthState>(
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
        child: CustomScrollView(
          slivers: [
            // Gradient Header
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: const Color(0xFF2563EB),
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF1D4ED8),
                        Color(0xFF2563EB),
                        Color(0xFF3B82F6)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF2563EB)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'GK',
                            style: GoogleFonts.outfit(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Goutam Sharma',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'goutam@example.com',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: _isPremium
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFFF59E0B),
                                    Color(0xFFEF4444)
                                  ],
                                )
                              : null,
                          color: _isPremium ? null : Colors.white24,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _isPremium ? '⭐ Premium Member' : 'Free Plan',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Body Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Account Section
                    _buildSectionTitle('Account', textColor),
                    _buildSectionCard(
                      surfaceColor: surfaceColor,
                      borderColor: borderColor,
                      children: [
                        _buildProfileTile(
                          icon: Icons.person_outline,
                          title: 'Edit Profile',
                          iconColor: const Color(0xFF2563EB),
                          textColor: textColor,
                          subTextColor: subTextColor,
                          onTap: () {},
                        ),
                        _buildDivider(borderColor),
                        _buildProfileTile(
                          icon: Icons.lock_outline,
                          title: 'Change Password',
                          iconColor: const Color(0xFF7C3AED),
                          textColor: textColor,
                          subTextColor: subTextColor,
                          onTap: () {},
                        ),
                        _buildDivider(borderColor),
                        _buildProfileTile(
                          icon: Icons.attach_money,
                          title: 'Currency',
                          trailing: 'USD',
                          iconColor: const Color(0xFF10B981),
                          textColor: textColor,
                          subTextColor: subTextColor,
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Subscription Section
                    _buildSectionTitle('Subscription', textColor),
                    _buildSectionCard(
                      surfaceColor: surfaceColor,
                      borderColor: borderColor,
                      children: [
                        _buildProfileTile(
                          icon: Icons.star_outline,
                          title: 'My Plan',
                          trailing: _isPremium ? 'Premium' : 'Free',
                          iconColor: const Color(0xFFF59E0B),
                          textColor: textColor,
                          subTextColor: subTextColor,
                          onTap: () => context.push(AppRoutes.subscription),
                        ),
                        if (!_isPremium) ...[
                          _buildDivider(borderColor),
                          _buildProfileTile(
                            icon: Icons.upgrade,
                            title: 'Upgrade to Premium',
                            iconColor: const Color(0xFF2563EB),
                            textColor: textColor,
                            subTextColor: subTextColor,
                            onTap: () => Navigator.of(context)
                                .pushNamed(AppRoutes.subscription),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Data Section
                    _buildSectionTitle('Data', textColor),
                    _buildSectionCard(
                      surfaceColor: surfaceColor,
                      borderColor: borderColor,
                      children: [
                        _buildProfileTile(
                          icon: Icons.sync,
                          title: 'Sync Status',
                          iconColor: const Color(0xFF2563EB),
                          textColor: textColor,
                          subTextColor: subTextColor,
                          onTap: () => context.push(AppRoutes.syncStatus),
                        ),
                        _buildDivider(borderColor),
                        _buildProfileTile(
                          icon: Icons.download_outlined,
                          title: 'Export Data',
                          iconColor: const Color(0xFF10B981),
                          textColor: textColor,
                          subTextColor: subTextColor,
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Support Section
                    _buildSectionTitle('Support', textColor),
                    _buildSectionCard(
                      surfaceColor: surfaceColor,
                      borderColor: borderColor,
                      children: [
                        _buildProfileTile(
                          icon: Icons.help_outline,
                          title: 'Help & Support',
                          iconColor: const Color(0xFF2563EB),
                          textColor: textColor,
                          subTextColor: subTextColor,
                          onTap: () {},
                        ),
                        _buildDivider(borderColor),
                        _buildProfileTile(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy Policy',
                          iconColor: const Color(0xFF7C3AED),
                          textColor: textColor,
                          subTextColor: subTextColor,
                          onTap: () {},
                        ),
                        _buildDivider(borderColor),
                        _buildProfileTile(
                          icon: Icons.description_outlined,
                          title: 'Terms of Service',
                          iconColor: const Color(0xFF64748B),
                          textColor: textColor,
                          subTextColor: subTextColor,
                          onTap: () {},
                        ),
                        _buildDivider(borderColor),
                        _buildProfileTile(
                          icon: Icons.info_outline,
                          title: 'App Version',
                          trailing: '1.0.0',
                          iconColor: const Color(0xFF94A3B8),
                          textColor: textColor,
                          subTextColor: subTextColor,
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Danger Zone
                    _buildSectionTitle('Danger Zone', const Color(0xFFEF4444)),
                    _buildSectionCard(
                      surfaceColor: surfaceColor,
                      borderColor:
                          const Color(0xFFEF4444).withValues(alpha: 0.2),
                      children: [
                        ListTile(
                          leading: const Icon(Icons.logout,
                              color: Color(0xFFEF4444), size: 22),
                          title: Text(
                            'Log Out',
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFEF4444),
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right,
                              color: Color(0xFFEF4444)),
                          onTap: _showLogoutDialog,
                        ),
                        _buildDivider(
                            const Color(0xFFEF4444).withValues(alpha: 0.15)),
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
                          trailing: const Icon(Icons.chevron_right,
                              color: Color(0xFFEF4444)),
                          onTap: _showDeleteDialog,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required Color surfaceColor,
    required Color borderColor,
    required List<Widget> children,
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
      child: Column(children: children),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required Color iconColor,
    required Color textColor,
    required Color subTextColor,
    required VoidCallback onTap,
    String? trailing,
  }) {
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
          color: textColor,
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
                    color: subTextColor,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, color: subTextColor, size: 18),
              ],
            )
          : Icon(Icons.chevron_right, color: subTextColor, size: 18),
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
