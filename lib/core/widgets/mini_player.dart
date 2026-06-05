import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_animations.dart';
import '../constants/app_enums.dart';
import '../../features/player/player_controller.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlayerController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      // Cacher si aucun audio en cours
      if (controller.currentAudio.value == null) {
        return const SizedBox.shrink();
      }

      return GestureDetector(
        onTap: () => Get.toNamed('/player'),
        child: AnimatedSlide(
          offset: controller.currentAudio.value == null
              ? const Offset(0, 1)
              : Offset.zero,
          duration: AppAnimations.slow,
          curve: AppAnimations.smooth,
          child: _buildContent(controller, isDark, context),
        ),
      );
    });
  }

  Widget _buildContent(
    PlayerController controller,
    bool isDark,
    BuildContext context,
  ) {
    return Container(
      height: AppDimensions.miniPlayerHeight,
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.sm,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.12),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: Stack(
          children: [
            // ── Barre de progression en fond ─────────
            _buildBackgroundProgress(controller, isDark),

            // ── Contenu principal ─────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.md,
              ),
              child: Row(
                children: [
                  // Image
                  _buildThumbnail(controller),

                  const SizedBox(width: AppDimensions.md),

                  // Titre + cours
                  Expanded(
                    child: _buildInfo(controller, isDark),
                  ),

                  // Contrôles
                  _buildControls(controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Progress en fond ─────────────────────────────────
  Widget _buildBackgroundProgress(
    PlayerController controller,
    bool isDark,
  ) {
    return Obx(() => FractionallySizedBox(
      widthFactor: controller.progressValue,
      alignment: Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(isDark ? 0.12 : 0.07),
        ),
      ),
    ));
  }

  // ─── Thumbnail ────────────────────────────────────────
  Widget _buildThumbnail(PlayerController controller) {
    return Obx(() {
      final imageUrl =
          controller.currentCourse.value?.imageUrl ?? '';

      return Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              color: AppColors.primary.withOpacity(0.2),
              child: const Icon(
                Iconsax.book,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            errorWidget: (_, __, ___) => Container(
              color: AppColors.primary.withOpacity(0.2),
              child: const Icon(
                Iconsax.book,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
        ),
      );
    });
  }

  // ─── Info titre ───────────────────────────────────────
  Widget _buildInfo(PlayerController controller, bool isDark) {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          controller.currentAudio.value?.titre ?? '',
          style: AppTextStyles.labelLarge.copyWith(
            color: isDark
                ? AppColors.textDarkPrimary
                : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          controller.currentCourse.value?.titre ?? '',
          style: AppTextStyles.bodySmall.copyWith(
            color: isDark
                ? AppColors.textDarkSecondary
                : AppColors.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ));
  }

  // ─── Contrôles ────────────────────────────────────────
  Widget _buildControls(PlayerController controller) {
    return Obx(() {
      final isLoading =
          controller.playerState.value == PlayerState.loading;

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Précédent
          _MiniButton(
            icon: Iconsax.previous,
            onTap: controller.hasPrevious
                ? controller.skipToPrevious
                : null,
            opacity: controller.hasPrevious ? 1.0 : 0.3,
          ),

          const SizedBox(width: AppDimensions.xs),

          // Play / Pause
          _MiniPlayButton(
            isPlaying: controller.isPlaying.value,
            isLoading: isLoading,
            onTap: controller.togglePlayPause,
          ),

          const SizedBox(width: AppDimensions.xs),

          // Suivant
          _MiniButton(
            icon: Iconsax.next,
            onTap: controller.hasNext
                ? controller.skipToNext
                : null,
            opacity: controller.hasNext ? 1.0 : 0.3,
          ),
        ],
      );
    });
  }
}

// ─── Bouton mini contrôle ─────────────────────────────────
class _MiniButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double opacity;

  const _MiniButton({
    required this.icon,
    this.onTap,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 18,
            color: isDark
                ? AppColors.textDarkPrimary
                : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

// ─── Bouton Play/Pause mini ───────────────────────────────
class _MiniPlayButton extends StatefulWidget {
  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onTap;

  const _MiniPlayButton({
    required this.isPlaying,
    required this.isLoading,
    required this.onTap,
  });

  @override
  State<_MiniPlayButton> createState() => _MiniPlayButtonState();
}

class _MiniPlayButtonState extends State<_MiniPlayButton>
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
    _scale = Tween<double>(begin: 1.0, end: 0.88).animate(
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
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
          ),
          child: widget.isLoading
              ? const Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                )
              : AnimatedSwitcher(
                  duration: AppAnimations.fast,
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    widget.isPlaying
                        ? Iconsax.pause
                        : Iconsax.play5,
                    key: ValueKey(widget.isPlaying),
                    color: Colors.white,
                    size: 18,
                  ),
                ),
        ),
      ),
    );
  }
}