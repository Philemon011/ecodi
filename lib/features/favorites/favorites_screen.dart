import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_animations.dart';
import '../../data/models/course_model.dart';
import 'favorites_controller.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FavoritesController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Recharger à chaque fois qu'on revient sur cet écran
  WidgetsBinding.instance.addPostFrameCallback((_) {
    controller.loadFavorites();
  });

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.refresh,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [

              // ── Header ──────────────────────────────
              SliverToBoxAdapter(
                child: _buildHeader(isDark),
              ),

              // ── Contenu ─────────────────────────────
              SliverToBoxAdapter(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return _buildSkeleton(isDark);
                  }
                  if (controller.favorites.isEmpty) {
                    return _buildEmpty(isDark);
                  }
                  return _buildList(
                    context,
                    controller,
                    isDark,
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────
  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.screenPadding,
        AppDimensions.screenPaddingTop,
        AppDimensions.screenPadding,
        AppDimensions.lg,
      ),
      child: Text(
        'Favoris',
        style: AppTextStyles.h1.copyWith(
          color: isDark
              ? AppColors.textDarkPrimary
              : AppColors.textPrimary,
        ),
      ),
    );
  }

  // ─── Liste des favoris ────────────────────────────────
  Widget _buildList(
    BuildContext context,
    FavoritesController controller,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPadding,
      ),
      child: Obx(() => Column(
        children: List.generate(
          controller.favorites.length,
          (index) {
            final course = controller.favorites[index];

            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(
                milliseconds: 300 + (index * 60),
              ),
              curve: AppAnimations.smooth,
              builder: (_, value, child) => Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              ),
              child: _FavoriteItem(
                course: course,
                isDark: isDark,
                onTap: () => controller.goToCourse(course),
                onRemove: () => controller.removeFavorite(course),
              ),
            );
          },
        ),
      )),
    );
  }

  // ─── État vide ────────────────────────────────────────
  Widget _buildEmpty(bool isDark) {
    return SizedBox(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.heart,
                size: 36,
                color: AppColors.accent.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
            Text(
              'Aucun favori',
              style: AppTextStyles.h3.copyWith(
                color: isDark
                    ? AppColors.textDarkPrimary
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              'Ajoute des cours à tes favoris\npour les retrouver rapidement',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Skeleton ────────────────────────────────────────
  Widget _buildSkeleton(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPadding,
      ),
      child: Column(
        children: List.generate(
          3,
          (_) => Padding(
            padding: const EdgeInsets.only(
              bottom: AppDimensions.sm,
            ),
            child: _SkeletonBox(
              width: double.infinity,
              height: 88,
              radius: AppDimensions.radiusMd,
              isDark: isDark,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Item favori ──────────────────────────────────────────
class _FavoriteItem extends StatefulWidget {
  final CourseModel course;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _FavoriteItem({
    required this.course,
    required this.isDark,
    required this.onTap,
    required this.onRemove,
  });

  @override
  State<_FavoriteItem> createState() => _FavoriteItemState();
}

class _FavoriteItemState extends State<_FavoriteItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.fast,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
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
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          margin: const EdgeInsets.only(
            bottom: AppDimensions.sm,
          ),
          padding: const EdgeInsets.all(AppDimensions.md),
          decoration: BoxDecoration(
            color: widget.isDark
                ? AppColors.cardDark
                : AppColors.cardLight,
            borderRadius:
                BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(
              color: widget.isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.04),
            ),
          ),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  AppDimensions.radiusMd,
                ),
                child: CachedNetworkImage(
                  imageUrl: widget.course.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    width: 60,
                    height: 60,
                    color: AppColors.primary.withOpacity(0.1),
                    child: const Icon(
                      Iconsax.book,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: AppDimensions.md),

              // Infos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.course.titre,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: widget.isDark
                            ? AppColors.textDarkPrimary
                            : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Iconsax.book,
                          size: 12,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.course.nombreLecons} leçons',
                          style: AppTextStyles.bodySmall,
                        ),
                        const SizedBox(width: AppDimensions.sm),
                        Icon(
                          Iconsax.clock,
                          size: 12,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.course.dureeFormatee,
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Bouton retirer favori
              GestureDetector(
                onTap: widget.onRemove,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Iconsax.heart5,
                    size: 16,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Skeleton ─────────────────────────────────────────────
class _SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;
  final bool isDark;

  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.radius,
    required this.isDark,
  });

  @override
  State<_SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<_SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: (widget.isDark ? Colors.white : Colors.black)
              .withOpacity(_animation.value * 0.12),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}