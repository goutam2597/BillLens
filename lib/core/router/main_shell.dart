import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:billlens/core/router/app_routes.dart';
import 'package:billlens/core/theme/app_colors.dart';

/// Persistent bottom navigation shell for the four main tabs:
/// Home, Expenses, Analytics, Profile.
class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentIndex = navigationShell.currentIndex;

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: _FloatingNavBar(
        currentIndex: currentIndex,
        isDark: isDark,
        onTap: (index) {
          if (index == 2) {
            context.push(AppRoutes.receiptScanner);
            return;
          }
          final branchIndex = index > 2 ? index - 1 : index;
          navigationShell.goBranch(branchIndex);
        },
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final bool isDark;
  final ValueChanged<int> onTap;

  const _FloatingNavBar({
    required this.currentIndex,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine visual active index accounting for the center scan button
    // 0 -> 0, 1 -> 1, 2 -> 3, 3 -> 4
    final activeIndex = currentIndex >= 2 ? currentIndex + 1 : currentIndex;

    final bgColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;
    final shadowColor1 = isDark
        ? Colors.black.withValues(alpha: 0.3)
        : AppColors.primary.withValues(alpha: 0.15);
    final shadowColor2 = isDark
        ? Colors.black.withValues(alpha: 0.2)
        : AppColors.primary.withValues(alpha: 0.05);

    return Container(
      // Transparent backing so we can see through the margin gap
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.surfaceDark : AppColors.borderLight,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: shadowColor1,
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: shadowColor2,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _NavTile(
                  assetPath: 'assets/icons/home.svg',
                  label: 'Home',
                  isActive: activeIndex == 0,
                  isDark: isDark,
                  onTap: () => onTap(0),
                ),
              ),
              Expanded(
                child: _NavTile(
                  assetPath: 'assets/icons/expenses.svg',
                  label: 'Expenses',
                  isActive: activeIndex == 1,
                  isDark: isDark,
                  onTap: () => onTap(1),
                ),
              ),
              Expanded(
                child: Transform.translate(
                  offset: const Offset(0, 0),
                  child: _NavTile(
                    assetPath: 'assets/icons/scan.svg',
                    label: 'Scan',
                    isActive: false, // Scan doesn't stay active
                    isDark: isDark,
                    isScanButton: true,
                    onTap: () => onTap(2),
                  ),
                ),
              ),
              Expanded(
                child: _NavTile(
                  assetPath: 'assets/icons/analytics.svg',
                  label: 'Analytics',
                  isActive: activeIndex == 3,
                  isDark: isDark,
                  onTap: () => onTap(3),
                ),
              ),
              Expanded(
                child: _NavTile(
                  assetPath: 'assets/icons/profile.svg',
                  label: 'Profile',
                  isActive: activeIndex == 4,
                  isDark: isDark,
                  onTap: () => onTap(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final String assetPath;
  final String label;
  final bool isActive;
  final bool isDark;
  final bool isScanButton;
  final VoidCallback onTap;

  const _NavTile({
    required this.assetPath,
    required this.label,
    required this.isActive,
    required this.isDark,
    required this.onTap,
    this.isScanButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.primary;
    final inactiveColor = isDark ? Colors.grey.shade500 : Colors.grey.shade400;

    // For scan button, the icon itself will be white
    final iconColor =
        isScanButton ? Colors.white : (isActive ? activeColor : inactiveColor);

    // Text color logic
    final textColor =
        isScanButton ? activeColor : (isActive ? activeColor : inactiveColor);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                padding: isScanButton
                    ? const EdgeInsets.all(16)
                    : const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  gradient: isScanButton ? AppColors.primaryGradient : null,
                  color: isScanButton
                      ? null
                      : (isActive
                          ? activeColor.withValues(alpha: 0.10)
                          : Colors.transparent),
                  shape: isScanButton ? BoxShape.circle : BoxShape.rectangle,
                  borderRadius: isScanButton ? null : BorderRadius.circular(14),
                  boxShadow: isScanButton
                      ? [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          )
                        ]
                      : null,
                ),
                child: SizedBox(
                  width: isScanButton ? 30 : 22,
                  height: isScanButton ? 30 : 22,
                  child: SvgPicture.asset(
                    assetPath,
                    colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  ),
                ),
              ),
            ],
          ),
          if (!isScanButton) ...[
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: textColor,
                letterSpacing: isActive ? 0.1 : 0,
              ),
              child: Text(label),
            ),
          ],
        ],
      ),
    );
  }
}
