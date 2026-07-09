import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Headings - Light
  static TextStyle displayLarge(BuildContext context) => GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface,
        letterSpacing: -0.5,
        height: 1.2,
      );

  static TextStyle displayMedium(BuildContext context) => GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface,
        letterSpacing: -0.3,
        height: 1.25,
      );

  static TextStyle headlineLarge(BuildContext context) => GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface,
        letterSpacing: -0.2,
        height: 1.3,
      );

  static TextStyle headlineMedium(BuildContext context) => GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
        height: 1.35,
      );

  static TextStyle headlineSmall(BuildContext context) => GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
        height: 1.4,
      );

  // Body
  static TextStyle bodyLarge(BuildContext context) => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).colorScheme.onSurface,
        height: 1.5,
      );

  static TextStyle bodyMedium(BuildContext context) => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).colorScheme.onSurface,
        height: 1.5,
      );

  static TextStyle bodySmall(BuildContext context) => GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        height: 1.5,
      );

  // Labels
  static TextStyle labelLarge(BuildContext context) => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
        letterSpacing: 0.1,
      );

  static TextStyle labelMedium(BuildContext context) => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
        letterSpacing: 0.1,
      );

  static TextStyle labelSmall(BuildContext context) => GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        letterSpacing: 0.5,
      );

  // Amount / Financial
  static TextStyle amountLarge(BuildContext context) => GoogleFonts.outfit(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface,
        letterSpacing: -1,
        height: 1.1,
      );

  static TextStyle amountMedium(BuildContext context) => GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface,
        letterSpacing: -0.5,
        height: 1.1,
      );

  // Static styles (color-independent, for use in theme)
  static TextStyle get outfitDisplay => GoogleFonts.outfit(
      fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.5);

  static TextStyle get outfitHeadline => GoogleFonts.outfit(
      fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.2);

  static TextStyle get outfitTitle =>
      GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600);

  static TextStyle get outfitBody =>
      GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w400);

  static TextStyle get outfitLabel => GoogleFonts.outfit(
      fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5);

  // White variants for on-gradient text
  static TextStyle displayWhite = GoogleFonts.outfit(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      letterSpacing: -0.5);

  static TextStyle headlineWhite = GoogleFonts.outfit(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      letterSpacing: -0.2);

  static TextStyle titleWhite = GoogleFonts.outfit(
      fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white);

  static TextStyle bodyWhite = GoogleFonts.outfit(
      fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white70);

  // Primary colored text
  static TextStyle primaryLabel = GoogleFonts.outfit(
      fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary);
}
