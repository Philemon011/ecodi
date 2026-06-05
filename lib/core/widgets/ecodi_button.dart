import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_animations.dart';

class EcodiButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final Widget? icon;
  final EcodiButtonStyle style;
  final bool isLoading;
  final bool fullWidth;
  final double? width;

  const EcodiButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.style = EcodiButtonStyle.primary,
    this.isLoading = false,
    this.fullWidth = false,
    this.width,
  });

  // Constructeurs nommés pour les variantes
  const EcodiButton.primary({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.width,
  }) : style = EcodiButtonStyle.primary;

  const EcodiButton.secondary({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.width,
  }) : style = EcodiButtonStyle.secondary;

  const EcodiButton.ghost({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.width,
  }) : style = EcodiButtonStyle.ghost;

  @override
  State<EcodiButton> createState() => _EcodiButtonState();
}

class _EcodiButtonState extends State<EcodiButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.fast,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    if (widget.onTap == null || widget.isLoading) return;
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(_) {
    _controller.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: AppAnimations.fast,
          width: widget.fullWidth ? double.infinity : widget.width,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.lg,
            vertical: 14,
          ),
          decoration: _buildDecoration(),
          child: _buildContent(),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    switch (widget.style) {
      case EcodiButtonStyle.primary:
        return BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          boxShadow: widget.onTap != null
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        );
      case EcodiButtonStyle.secondary:
        return BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 1.5,
          ),
        );
      case EcodiButtonStyle.ghost:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        );
    }
  }

  Widget _buildContent() {
    final textColor = switch (widget.style) {
      EcodiButtonStyle.primary => Colors.white,
      EcodiButtonStyle.secondary => AppColors.primary,
      EcodiButtonStyle.ghost => AppColors.textSecondary,
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: textColor,
            ),
          )
        else ...[
          if (widget.icon != null) ...[
            widget.icon!,
            const SizedBox(width: AppDimensions.sm),
          ],
          Text(
            widget.label,
            style: AppTextStyles.labelLarge.copyWith(color: textColor),
          ),
        ],
      ],
    );
  }
}

enum EcodiButtonStyle { primary, secondary, ghost }