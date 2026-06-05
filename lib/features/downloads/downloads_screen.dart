import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_animations.dart';
import '../../core/constants/app_enums.dart';
import '../../services/download_service.dart';
import 'downloads_controller.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      DownloadsController(
        downloadService: Get.find<DownloadService>(),
      ),
    );
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
                  if (controller.downloadedItems.isEmpty) {
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
    DownloadsController controller,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.screenPadding,
        AppDimensions.screenPaddingTop,
        AppDimensions.screenPadding,
        AppDimensions.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Téléchargements',
            style: AppTextStyles.h1.copyWith(
              color: isDark
                  ? AppColors.textDarkPrimary
                  : AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: AppDimensions.md),

          // Stats + bouton tout supprimer
          Obx(() {
            if (controller.downloadedItems.isEmpty) {
              return const SizedBox.shrink();
            }
            return Row(
              children: [
                // Nombre de fichiers
                _StatPill(
                  icon: Iconsax.document_download,
                  label:
                      '${controller.downloadedItems.length} fichiers',
                  isDark: isDark,
                ),

                const SizedBox(width: AppDimensions.sm),

                // Taille totale
                _StatPill(
                  icon: Iconsax.folder,
                  label: controller.formatSize(
                    controller.totalSizeMb.value,
                  ),
                  isDark: isDark,
                ),

                const Spacer(),

                // Bouton tout supprimer
                GestureDetector(
                  onTap: () => _confirmDeleteAll(
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
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusFull,
                      ),
                      border: Border.all(
                        color: AppColors.error.withOpacity(0.2),
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
                          'Tout supprimer',
                          style: AppTextStyles.labelSmall
                              .copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ─── Liste des téléchargements ────────────────────────
  Widget _buildList(
    BuildContext context,
    DownloadsController controller,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPadding,
      ),
      child: Obx(() => Column(
        children: List.generate(
          controller.downloadedItems.length,
          (index) {
            final item = controller.downloadedItems[index];

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
              child: _DownloadItem(
                item: item,
                controller: controller,
                isDark: isDark,
                onDelete: () => _confirmDelete(
                  context,
                  controller,
                  item,
                  isDark,
                ),
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
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.document_download,
                size: 36,
                color: AppColors.primary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
            Text(
              'Aucun téléchargement',
              style: AppTextStyles.h3.copyWith(
                color: isDark
                    ? AppColors.textDarkPrimary
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              'Télécharge des leçons pour\nles écouter sans internet',
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
          4,
          (_) => Padding(
            padding: const EdgeInsets.only(
              bottom: AppDimensions.sm,
            ),
            child: _SkeletonBox(
              width: double.infinity,
              height: 80,
              radius: AppDimensions.radiusMd,
              isDark: isDark,
            ),
          ),
        ),
      ),
    );
  }

  // ─── Dialog confirmation suppression ─────────────────
  void _confirmDelete(
    BuildContext context,
    DownloadsController controller,
    DownloadedItem item,
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
          'Supprimer ?',
          style: AppTextStyles.h3.copyWith(
            color: isDark
                ? AppColors.textDarkPrimary
                : AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Supprimer "${item.audio.titre}" de tes téléchargements ?',
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
              controller.deleteDownload(item);
            },
            child: Text(
              'Supprimer',
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

  // ─── Dialog tout supprimer ────────────────────────────
  void _confirmDeleteAll(
    BuildContext context,
    DownloadsController controller,
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
          'Tout supprimer ?',
          style: AppTextStyles.h3.copyWith(
            color: isDark
                ? AppColors.textDarkPrimary
                : AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Tous les téléchargements seront supprimés.',
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
              controller.deleteAll();
            },
            child: Text(
              'Tout supprimer',
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

// ─── Item téléchargement ──────────────────────────────────
class _DownloadItem extends StatelessWidget {
  final DownloadedItem item;
  final DownloadsController controller;
  final bool isDark;
  final VoidCallback onDelete;

  const _DownloadItem({
    required this.item,
    required this.controller,
    required this.isDark,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.sm),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.04),
        ),
      ),
      child: Row(
        children: [
          // Icône audio
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Icon(
              Iconsax.music,
              size: 20,
              color: AppColors.success,
            ),
          ),

          const SizedBox(width: AppDimensions.md),

          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.audio.titre,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: isDark
                        ? AppColors.textDarkPrimary
                        : AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      item.audio.dureeFormatee,
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(width: AppDimensions.sm),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.textTertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.sm),
                    Text(
                      controller.formatSize(item.sizeMb),
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bouton supprimer
          GestureDetector(
            onTap: onDelete,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.trash,
                size: 16,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stat pill ────────────────────────────────────────────
class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _StatPill({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.xs,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark2 : AppColors.cardLight,
        borderRadius:
            BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.06),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.primary),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: isDark
                  ? AppColors.textDarkPrimary
                  : AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Skeleton box ─────────────────────────────────────────
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
          parent: _controller, curve: Curves.easeInOut),
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