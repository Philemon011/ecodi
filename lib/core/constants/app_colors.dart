import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Brand ───────────────────────────────────────────
  static const Color primary        = Color(0xFF6C63FF); // Violet signature
  static const Color primaryLight   = Color(0xFF9C95FF);
  static const Color primaryDark    = Color(0xFF4B44CC);
  static const Color accent         = Color(0xFFFF6B6B); // Corail pour CTA

  // ─── Backgrounds ─────────────────────────────────────
  static const Color bgLight        = Color(0xFFF7F7FC);
  static const Color bgDark         = Color(0xFF0F0F1A);
  static const Color cardLight      = Color(0xFFFFFFFF);
  static const Color cardDark       = Color(0xFF1A1A2E);
  static const Color cardDark2      = Color(0xFF22223A);

  // ─── Text ────────────────────────────────────────────
  static const Color textPrimary    = Color(0xFF1A1A2E);
  static const Color textSecondary  = Color(0xFF6B7280);
  static const Color textTertiary   = Color(0xFFB0B7C3);
  static const Color textDarkPrimary   = Color(0xFFF1F1F8);
  static const Color textDarkSecondary = Color(0xFF9CA3AF);

  // ─── Status ──────────────────────────────────────────
  static const Color success        = Color(0xFF22C55E);
  static const Color successLight   = Color(0xFFDCFCE7);
  static const Color warning        = Color(0xFFF59E0B);
  static const Color warningLight   = Color(0xFFFEF3C7);
  static const Color error          = Color(0xFFEF4444);

  // ─── Player ──────────────────────────────────────────
  static const Color playerBgDark   = Color(0xFF0D0D1F);
  static const Color playerSurface  = Color(0xFF1E1E35);
  static const Color progressBg     = Color(0xFF2A2A45);
  static const Color progressFill   = Color(0xFF6C63FF);

  // ─── Gradients ───────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF9C95FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF4B44CC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF0F0F1A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}