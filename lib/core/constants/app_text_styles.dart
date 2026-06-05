import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ─── Display ─────────────────────────────────────────
  static TextStyle get display => GoogleFonts.outfit(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static TextStyle get displayDark => GoogleFonts.outfit(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.2,
    color: AppColors.textDarkPrimary,
  );

  // ─── Headings ────────────────────────────────────────
  static TextStyle get h1 => GoogleFonts.outfit(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static TextStyle get h2 => GoogleFonts.outfit(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static TextStyle get h3 => GoogleFonts.outfit(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static TextStyle get h4 => GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  // ─── Body ────────────────────────────────────────────
  static TextStyle get bodyLarge => GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyMedium => GoogleFonts.outfit(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  static TextStyle get bodySmall => GoogleFonts.outfit(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textTertiary,
  );

  // ─── Label ───────────────────────────────────────────
  static TextStyle get labelLarge => GoogleFonts.outfit(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  static TextStyle get labelMedium => GoogleFonts.outfit(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: AppColors.textSecondary,
  );

  static TextStyle get labelSmall => GoogleFonts.outfit(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    color: AppColors.textTertiary,
  );

  // ─── Spéciaux ────────────────────────────────────────
  static TextStyle get caption => GoogleFonts.outfit(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    color: AppColors.textTertiary,
  );

  static TextStyle get overline => GoogleFonts.outfit(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    color: AppColors.textTertiary,
  );

  static TextStyle get playerTimer => GoogleFonts.outfit(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: Colors.white70,
  );

  // ─── Helpers ─────────────────────────────────────────
  static TextStyle withColor(TextStyle style, Color color) =>
      style.copyWith(color: color);

  static TextStyle white(TextStyle style) =>
      style.copyWith(color: Colors.white);

  static TextStyle bold(TextStyle style) =>
      style.copyWith(fontWeight: FontWeight.w700);
}