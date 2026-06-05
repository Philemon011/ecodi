import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_animations.dart';

class EcodiProgressBar extends StatelessWidget {
  final double value; // 0.0 → 1.0
  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool animated;
  final bool showGlow;

  const EcodiProgressBar({
    super.key,
    required this.value,
    this.height = 4,
    this.backgroundColor,
    this.foregroundColor,
    this.animated = true,
    this.showGlow = false,
  });

  // Variante fine pour les cartes
  const EcodiProgressBar.thin({
    super.key,
    required this.value,
    this.backgroundColor,
    this.foregroundColor,
    this.animated = true,
  })  : height = 3,
        showGlow = false;

  // Variante épaisse pour le lecteur
  const EcodiProgressBar.player({
    super.key,
    required this.value,
    this.backgroundColor,
    this.foregroundColor,
    this.animated = true,
  })  : height = 5,
        showGlow = true;

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ??
        AppColors.primary.withOpacity(0.15);
    final fgColor = foregroundColor ?? AppColors.primary;
    final clamped = value.clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: Container(
        height: height,
        color: bgColor,
        child: animated
            ? TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: clamped),
                duration: AppAnimations.normal,
                curve: AppAnimations.smooth,
                builder: (context, val, _) =>
                    _buildFill(val, fgColor),
              )
            : _buildFill(clamped, fgColor),
      ),
    );
  }

  Widget _buildFill(double val, Color fgColor) {
    return FractionallySizedBox(
      widthFactor: val,
      alignment: Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          color: fgColor,
          boxShadow: showGlow
              ? [
                  BoxShadow(
                    color: fgColor.withOpacity(0.5),
                    blurRadius: 6,
                    offset: const Offset(0, 0),
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}