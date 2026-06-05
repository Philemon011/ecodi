import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_animations.dart';
import '../../core/widgets/ecodi_progress_bar.dart';
import 'history_controller.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HistoryController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                child: _buildHeader(
                  context,
                  controller,
                  isDark,
                ),
              ),

              // ── Contenu ─────────────────────────────
              SliverToBoxAdapter(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return _buildSkeleton(isDark);
                  }
                  if (controller.entries.isEmpty) {
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
  Widget _buildHeader(
    BuildContext context,
    HistoryController controller,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.screenPadding,
        AppDimensions.screenPaddingTop,
        AppDimensions.screenPadding,
        AppDimensions.lg,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Historique',
            style: AppTextStyles.h1.copyWith(
              color: isDark
                  ? AppColors.textDarkPrimary
                  : AppColors.textPrimary,
            ),
          ),

          // Bouton effacer
          Obx(() {
            if (controller.entries.isEmpty) {
              return const SizedBox.shrink();
            }
            return GestureDetector(
              onTap: () => _confirmClear(
                context,
                controller,
                isDark,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.md,
                  vertical: AppDimensions.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusFull,
                  ),
                  border: Border.all(
                    color: AppColors.error.withOpacity(0.15),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Iconsax.trash,
                      size: 14,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Effacer',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── Liste ───────────────────────────────────────────
  Widget _buildList(
    BuildContext context,
    HistoryController controller,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPadding,
      ),
      child: Obx(() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          controller.entries.length,
          (index) {
            final entry = controller.entries[index];

            // Séparateur de date
            final showDate = index == 0 ||
                controller.entries[index - 1].dateFormatee !=
                    entry.dateFormatee;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label date si différent
                if (showDate) ...[
                  if (index != 0)
                    const SizedBox(height: AppDimensions.md),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppDimensions.sm,
                    ),
                    child: Text(
                      entry.dateFormatee,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],

                // Item
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(
                    milliseconds: 300 + (index * 50),
                  ),
                  curve: AppAnimations.smooth,
                  builder: (_, value, child) => Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 16 * (1 - value)),
                      child: child,
                    ),
                  ),
                  child: _HistoryItem(
                    entry: entry,
                    isDark: isDark,
                    onTap: () => controller.playEntry(entry),
                    onCourseTap: () =>
                        controller.goToCourse(entry),
                  ),
                ),
              ],
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
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.clock,
                size: 36,
                color: AppColors.primary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
            Text(
              'Aucun historique',
              style: AppTextStyles.h3.copyWith(
                color: isDark
                    ? AppColors.textDarkPrimary
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              'Tes lectures apparaîtront ici\nau fur et à mesure',
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label date skeleton
          _SkeletonBox(
            width: 80,
            height: 12,
            radius: 4,
            isDark: isDark,
          ),
          const SizedBox(height: AppDimensions.sm),
          ...List.generate(
            4,
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
        ],
      ),
    );
  }

  // ─── Dialog effacer ───────────────────────────────────
  void _confirmClear(
    BuildContext context,
    HistoryController controller,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.cardDark : AppColors.cardLight,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppDimensions.radiusLg),
        ),
        title: Text(
          'Effacer l\'historique ?',
          style: AppTextStyles.h3.copyWith(
            color: isDark
                ? AppColors.textDarkPrimary
                : AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Tout l\'historique de lecture sera supprimé.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Annuler',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.clearHistory();
            },
            child: Text(
              'Effacer',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Item historique ──────────────────────────────────────
class _HistoryItem extends StatefulWidget {
  final HistoryEntry entry;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onCourseTap;

  const _HistoryItem({
    required this.entry,
    required this.isDark,
    required this.onTap,
    required this.onCourseTap,
  });

  @override
  State<_HistoryItem> createState() => _HistoryItemState();
}

class _HistoryItemState extends State<_HistoryItem>
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
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
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
              // Image cours
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  AppDimensions.radiusMd,
                ),
                child: CachedNetworkImage(
                  imageUrl: widget.entry.course.imageUrl,
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
                    // Titre audio
                    Text(
                      widget.entry.audio.titre,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: widget.isDark
                            ? AppColors.textDarkPrimary
                            : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 3),

                    // Nom du cours cliquable
                    GestureDetector(
                      onTap: widget.onCourseTap,
                      child: Text(
                        widget.entry.course.titre,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.sm),

                    // Barre de progression
                    EcodiProgressBar.thin(
                      value: widget.entry.progression,
                    ),

                    const SizedBox(height: 3),

                    // Pourcentage
                    Text(
                      '${(widget.entry.progression * 100).toInt()}% écouté',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppDimensions.sm),

              // Bouton play
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.play5,
                  size: 16,
                  color: Colors.white,
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