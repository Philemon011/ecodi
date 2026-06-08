import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_animations.dart';
import '../../core/constants/app_enums.dart';
import '../../data/models/audio_model.dart';
import '../../data/models/course_model.dart';
import 'player_controller.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late PlayerController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<PlayerController>();
    _startPlayback();
  }

  void _startPlayback() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args == null) return;

    final course = args['course'] as CourseModel?;
    final audio = args['audio'] as AudioModel?;
    final playlist = args['playlist'] as List<AudioModel>?;

    if (course == null || audio == null || playlist == null) return;

    // ── Ne pas relancer si c'est déjà le même audio ──
    final isSameAudio =
        controller.currentAudio.value?.id == audio.id &&
        controller.currentCourse.value?.id == course.id;

    if (isSameAudio) {
      debugPrint('⏯ Même audio — pas de rechargement');
      return;
    }

    controller.playAudio(
      audio: audio,
      course: course,
      playlist: playlist,
    );
  });
}

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.playerBgDark : AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(controller),
            Expanded(
              flex: 4,
              child: _buildArtwork(controller),
            ),
            _buildAudioInfo(controller),
            _buildProgressBar(controller),
            _buildControls(controller),
            _buildSpeedControl(controller),
            const SizedBox(height: AppDimensions.lg),
          ],
        ),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────
  Widget _buildHeader(PlayerController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPadding,
        vertical: AppDimensions.md,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.arrow_down_2,
                color: isDark ? Colors.white : AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
          Expanded(
            child: Obx(() => Column(
                  children: [
                    Text(
                      'En cours',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isDark ? Colors.white38 : AppColors.textTertiary,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      controller.currentCourse.value?.titre ?? '',
                      style: AppTextStyles.labelMedium.copyWith(
                        color:
                            isDark ? Colors.white70 : AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                )),
          ),
          GestureDetector(
            onTap: () => _showPlaylist(controller),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.menu_1,
                color: isDark ? Colors.white : AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Artwork ─────────────────────────────────────────
  Widget _buildArtwork(PlayerController controller) {
    return Obx(() {
      final imageUrl = controller.currentCourse.value?.imageUrl ?? '';

      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.85, end: 1.0),
        duration: AppAnimations.slow,
        curve: AppAnimations.smooth,
        builder: (_, scale, child) => Transform.scale(
          scale: scale,
          child: child,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.xl,
            vertical: AppDimensions.md,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: AppColors.playerSurface,
                  child: const Center(
                    child: Icon(
                      Iconsax.book,
                      color: AppColors.primary,
                      size: 60,
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.playerSurface,
                  child: const Center(
                    child: Icon(
                      Iconsax.book,
                      color: AppColors.primary,
                      size: 60,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  // ─── Infos audio ─────────────────────────────────────
  Widget _buildAudioInfo(PlayerController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPadding,
            vertical: AppDimensions.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.currentAudio.value?.titre ?? '',
                      style: AppTextStyles.h3.copyWith(
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.currentCourse.value?.titre ?? '',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color:
                            isDark ? Colors.white54 : AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.md,
                  vertical: AppDimensions.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusFull,
                  ),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '${controller.currentIndex + 1} / '
                  '${controller.playlist.length}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  // ─── Barre de progression ─────────────────────────────
  Widget _buildProgressBar(PlayerController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPadding,
      ),
      child: Column(
        children: [
          Obx(() => SliderTheme(
                data: SliderThemeData(
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 14,
                  ),
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: isDark
                      ? AppColors.progressBg
                      : Colors.black.withOpacity(0.1),
                  thumbColor: AppColors.primary,
                  overlayColor: AppColors.primary.withOpacity(0.2),
                ),
                child: Slider(
                  value: controller.progressValue,
                  onChanged: controller.seekTo,
                ),
              )),
          Obx(() => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      controller.formatDuration(
                        controller.position.value,
                      ),
                      style: AppTextStyles.playerTimer.copyWith(
                        color:
                            isDark ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      controller.formatDuration(
                        controller.duration.value,
                      ),
                      style: AppTextStyles.playerTimer.copyWith(
                        color:
                            isDark ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ─── Contrôles ────────────────────────────────────────
  Widget _buildControls(PlayerController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPadding,
        vertical: AppDimensions.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Obx(() => _ControlButton(
                icon: Iconsax.previous,
                size: 24,
                isDark: isDark,
                onTap:
                    controller.hasPrevious ? controller.skipToPrevious : null,
                opacity: controller.hasPrevious ? 1.0 : 0.3,
              )),
          _ControlButton(
            icon: Iconsax.forward_15_seconds,
            size: 26,
            isDark: isDark,
            onTap: controller.seekBackward,
            isFlipped: true,
          ),
          Obx(() => _PlayPauseButton(
                isPlaying: controller.isPlaying.value,
                isLoading: controller.isLoading.value ||
                    controller.playerState.value == PlayerState.loading,
                onTap: controller.togglePlayPause,
              )),
          _ControlButton(
            icon: Iconsax.forward_15_seconds,
            size: 26,
            isDark: isDark,
            onTap: controller.seekForward,
          ),
          Obx(() => _ControlButton(
                icon: Iconsax.next,
                size: 24,
                isDark: isDark,
                onTap: controller.hasNext ? controller.skipToNext : null,
                opacity: controller.hasNext ? 1.0 : 0.3,
              )),
        ],
      ),
    );
  }

  // ─── Vitesse ──────────────────────────────────────────
  Widget _buildSpeedControl(PlayerController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() => GestureDetector(
          onTap: controller.cycleSpeed,
          child: AnimatedContainer(
            duration: AppAnimations.fast,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.md,
              vertical: AppDimensions.sm,
            ),
            decoration: BoxDecoration(
              color: controller.speed.value != 1.0
                  ? AppColors.primary.withOpacity(0.15)
                  : isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.06),
              borderRadius: BorderRadius.circular(
                AppDimensions.radiusFull,
              ),
              border: Border.all(
                color: controller.speed.value != 1.0
                    ? AppColors.primary.withOpacity(0.4)
                    : isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1),
              ),
            ),
            child: Text(
              '${controller.speed.value}x',
              style: AppTextStyles.labelMedium.copyWith(
                color: controller.speed.value != 1.0
                    ? AppColors.primary
                    : isDark
                        ? Colors.white70
                        : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ));
  }

  // ─── Playlist bottom sheet ────────────────────────────
  void _showPlaylist(PlayerController controller) {
    Get.bottomSheet(
      DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.75,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.playerSurface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusXl),
                topRight: Radius.circular(AppDimensions.radiusXl),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(
                    top: AppDimensions.md,
                    bottom: AppDimensions.lg,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.screenPadding,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Playlist',
                        style: AppTextStyles.h3.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.sm),
                      Text(
                        '${controller.playlist.length} leçons',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.md),
                Expanded(
                  child: Obx(() => ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.screenPadding,
                        ),
                        itemCount: controller.playlist.length,
                        itemBuilder: (_, index) {
                          final audio = controller.playlist[index];
                          final isCurrent =
                              audio.id == controller.currentAudio.value?.id;

                          return GestureDetector(
                            onTap: () {
                              Get.back();
                              controller.playAudio(
                                audio: audio,
                                course: controller.currentCourse.value!,
                                playlist: controller.playlist,
                              );
                            },
                            child: AnimatedContainer(
                              duration: AppAnimations.fast,
                              margin: const EdgeInsets.only(
                                bottom: AppDimensions.sm,
                              ),
                              padding: const EdgeInsets.all(
                                AppDimensions.md,
                              ),
                              decoration: BoxDecoration(
                                color: isCurrent
                                    ? AppColors.primary.withOpacity(0.15)
                                    : Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusMd,
                                ),
                                border: isCurrent
                                    ? Border.all(
                                        color:
                                            AppColors.primary.withOpacity(0.3),
                                      )
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 28,
                                    child: isCurrent
                                        ? Icon(
                                            Iconsax.volume_high,
                                            size: 16,
                                            color: AppColors.primary,
                                          )
                                        : Text(
                                            '${index + 1}',
                                            style: AppTextStyles.labelSmall
                                                .copyWith(
                                              color: Colors.white38,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(width: AppDimensions.sm),
                                  Expanded(
                                    child: Text(
                                      audio.titre,
                                      style: AppTextStyles.labelMedium.copyWith(
                                        color: isCurrent
                                            ? AppColors.primaryLight
                                            : Colors.white70,
                                        fontWeight: isCurrent
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    audio.dureeFormatee,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: Colors.white38,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )),
                ),
                const SizedBox(height: AppDimensions.xl),
              ],
            ),
          );
        },
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }
}

// ─── Bouton contrôle ──────────────────────────────────────
class _ControlButton extends StatefulWidget {
  final IconData icon;
  final double size;
  final VoidCallback? onTap;
  final double opacity;
  final bool isFlipped;
  final bool isDark; // ← ajouté

  const _ControlButton({
    required this.icon,
    required this.size,
    required this.isDark, // ← ajouté
    this.onTap,
    this.opacity = 1.0,
    this.isFlipped = false,
  });

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton>
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
      onTapDown: (_) {
        if (widget.onTap != null) _controller.forward();
      },
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Opacity(
          opacity: widget.opacity,
          child: Transform.scale(
            scaleX: widget.isFlipped ? -1 : 1,
            child: Icon(
              widget.icon,
              color: widget.isDark ? Colors.white : AppColors.textPrimary,
              size: widget.size,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Bouton Play/Pause ────────────────────────────────────
class _PlayPauseButton extends StatefulWidget {
  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onTap;

  const _PlayPauseButton({
    required this.isPlaying,
    required this.isLoading,
    required this.onTap,
  });

  @override
  State<_PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<_PlayPauseButton>
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
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
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
          width: AppDimensions.playerThumbSize + 16,
          height: AppDimensions.playerThumbSize + 16,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.5),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: widget.isLoading
              ? const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  ),
                )
              : AnimatedSwitcher(
                  duration: AppAnimations.fast,
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    widget.isPlaying ? Iconsax.pause : Iconsax.play5,
                    key: ValueKey(widget.isPlaying),
                    color: Colors.white,
                    size: 28,
                  ),
                ),
        ),
      ),
    );
  }
}
