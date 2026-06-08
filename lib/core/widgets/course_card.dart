import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax/iconsax.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_animations.dart';
import '../../data/models/course_model.dart';
import '../../data/models/progress_model.dart';
import 'ecodi_progress_bar.dart';

class CourseCard extends StatefulWidget {
  final CourseModel course;
  final double progression;
  final VoidCallback? onTap;
  final bool isHorizontal;

  const CourseCard({
    super.key,
    required this.course,
    this.progression = 0.0, 
    this.onTap,
    this.isHorizontal = false,
  });

  // Variante horizontale compacte (pour "Continuer")
  const CourseCard.horizontal({
    super.key,
    required this.course,
    this.progression = 0.0,
    this.onTap,
  }) : isHorizontal = true;

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.fast,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: widget.isHorizontal
            ? _buildHorizontal()
            : _buildVertical(),
      ),
    );
  }

  // ─── Card verticale (grille principale) ──────────────
  Widget _buildVertical() {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final progression = widget.progression;

  return Container(
    decoration: BoxDecoration(
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.3 : 0.07),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image — hauteur fixe
        _buildImage(),

        // Infos — flexible
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Titre
                Text(
                  widget.course.titre,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.textDarkPrimary
                        : AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // Méta + progression
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Leçons
                    Row(
                      children: [
                        Icon(
                          Iconsax.book,
                          size: 11,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            '${widget.course.nombreLecons} leçons',
                            style: AppTextStyles.bodySmall
                                .copyWith(fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 2),

                    // Durée
                    Row(
                      children: [
                        Icon(
                          Iconsax.clock,
                          size: 11,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            widget.course.dureeFormatee,
                            style: AppTextStyles.bodySmall
                                .copyWith(fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    // Progression si commencé
                    if (widget.progression > 0) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: EcodiProgressBar.thin(
                              value: progression,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${(progression * 100).toInt()}%',
                            style: AppTextStyles.labelSmall
                                .copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

  // ─── Card horizontale (section "Continuer") ──────────
  Widget _buildHorizontal() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progression = widget.progression;

    return Container(
      height: AppDimensions.cardHeightSmall,
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image carrée
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppDimensions.radiusLg),
              bottomLeft: Radius.circular(AppDimensions.radiusLg),
            ),
            child: CachedNetworkImage(
              imageUrl: widget.course.imageUrl,
              width: AppDimensions.cardHeightSmall,
              height: AppDimensions.cardHeightSmall,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                color: Colors.white.withOpacity(0.1),
                child: const Icon(
                  Iconsax.book,
                  color: Colors.white54,
                ),
              ),
            ),
          ),

          // Infos
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Continuer',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white60,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.course.titre,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  EcodiProgressBar.thin(
                    value: progression,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                  ),
                ],
              ),
            ),
          ),

          // Bouton play
          Padding(
            padding: const EdgeInsets.only(right: AppDimensions.md),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.play5,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Image avec shimmer ───────────────────────────────
  Widget _buildImage() {
  return ClipRRect(
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(AppDimensions.radiusLg),
      topRight: Radius.circular(AppDimensions.radiusLg),
    ),
    child: CachedNetworkImage(
      imageUrl: widget.course.imageUrl,
      height: 110, // réduit de 140 à 110
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (_, __) => _buildShimmer(),
      errorWidget: (_, __, ___) => Container(
        height: 110,
        color: AppColors.primary.withOpacity(0.1),
        child: const Center(
          child: Icon(
            Iconsax.book,
            color: AppColors.primary,
            size: 32,
          ),
        ),
      ),
    ),
  );
}

Widget _buildShimmer() {
  return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.4, end: 0.8),
    duration: const Duration(milliseconds: 800),
    curve: Curves.easeInOut,
    builder: (context, value, child) {
      return Container(
        height: 110,
        color: AppColors.textTertiary.withOpacity(value),
      );
    },
  );
}
}

// ─── Widget interne : badge méta ─────────────────────────
class _MetaBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }
}