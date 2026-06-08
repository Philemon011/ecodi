import 'package:ecodi/services/download_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_animations.dart';
import '../../data/models/audio_model.dart';

import '../constants/app_enums.dart';

class LessonTile extends StatefulWidget {
  final AudioModel audio;
  final LessonStatus status;
  final bool isPlaying;
  final VoidCallback? onTap;
  final VoidCallback? onDownload;

  const LessonTile({
    super.key,
    required this.audio,
    required this.status,
    this.isPlaying = false,
    this.onTap,
    this.onDownload,
  });

  @override
  State<LessonTile> createState() => _LessonTileState();
}

class _LessonTileState extends State<LessonTile>
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
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.98).animate(
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedContainer(
          duration: AppAnimations.normal,
          margin: const EdgeInsets.only(bottom: AppDimensions.sm),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.md,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: widget.isPlaying
                ? AppColors.primary.withOpacity(0.08)
                : isDark
                    ? AppColors.cardDark2
                    : AppColors.cardLight,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: widget.isPlaying
                ? Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1.5,
                  )
                : Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.04),
                    width: 1,
                  ),
          ),
          child: Row(
            children: [
              // Icône statut
              _buildStatusIcon(),

              const SizedBox(width: AppDimensions.md),

              // Titre + durée
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.audio.titre,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: widget.isPlaying
                            ? AppColors.primary
                            : isDark
                                ? AppColors.textDarkPrimary
                                : AppColors.textPrimary,
                        fontWeight: widget.isPlaying
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.audio.dureeFormatee,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),

              // ─── Partie droite ────────────────────────────────
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Bouton téléchargement
                  Obx(() {
                    final ds = Get.find<DownloadService>();
                    final status = ds.getStatus(widget.audio.id);
                    final progress = ds.getProgress(widget.audio.id);

                    if (status == DownloadStatus.downloading) {
                      return SizedBox(
                        width: 28,
                        height: 28,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 2,
                              color: AppColors.primary,
                              backgroundColor:
                                  AppColors.primary.withOpacity(0.2),
                            ),
                            Text(
                              '${(progress * 100).toInt()}',
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 8,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (status == DownloadStatus.downloaded) {
                      return Icon(
                        Iconsax.tick_circle5,
                        size: 18,
                        color: AppColors.success,
                      );
                    }

                    return GestureDetector(
                      onTap: () => ds.downloadAudio(widget.audio),
                      child: Icon(
                        Iconsax.arrow_down_1,
                        size: 18,
                        color: AppColors.textTertiary,
                      ),
                    );
                  }),

                  const SizedBox(width: AppDimensions.sm),

                  // Flèche ou animation lecture
                  widget.isPlaying
                      ? _PlayingIndicator()
                      : Icon(
                          Iconsax.arrow_right_3,
                          size: AppDimensions.iconSm,
                          color: AppColors.textTertiary,
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    switch (widget.status) {
      case LessonStatus.completed:
        return Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.successLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Iconsax.tick_circle5,
            size: 18,
            color: AppColors.success,
          ),
        );

      case LessonStatus.inProgress:
        return Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Iconsax.play5,
            size: 16,
            color: Colors.white,
          ),
        );

      case LessonStatus.notStarted:
        return Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.textTertiary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${widget.audio.ordre}',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
    }
  }
}

// ─── Indicateur de lecture animé ─────────────────────────
class _PlayingIndicator extends StatefulWidget {
  @override
  State<_PlayingIndicator> createState() => _PlayingIndicatorState();
}

class _PlayingIndicatorState extends State<_PlayingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(3, (i) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              final delay = i * 0.2;
              final value = ((_controller.value + delay) % 1.0);
              final height = 4 + (12 * value);
              return Container(
                width: 3,
                height: height,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
