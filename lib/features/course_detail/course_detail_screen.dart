import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_enums.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_animations.dart';
import '../../core/widgets/ecodi_button.dart';
import '../../core/widgets/ecodi_progress_bar.dart';
import '../../core/widgets/lesson_tile.dart';
import 'course_detail_controller.dart';

class CourseDetailScreen extends StatelessWidget {
  const CourseDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CourseDetailController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.bgDark : AppColors.bgLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [

          // ── Header avec image ────────────────────────
          _buildSliverAppBar(context, controller, isDark),

          // ── Contenu ──────────────────────────────────
          SliverToBoxAdapter(
            child: Obx(() {
              if (controller.isLoading.value) {
                return _buildSkeleton(isDark);
              }
              if (controller.hasError.value) {
                return _buildError(controller);
              }
              return _buildContent(context, controller, isDark);
            }),
          ),
        ],
      ),

      // ── Bouton flottant "Commencer / Reprendre" ──────
      bottomNavigationBar: _buildBottomBar(
        context,
        controller,
        isDark,
      ),
    );
  }

  // ─── SliverAppBar avec image hero ─────────────────────
  Widget _buildSliverAppBar(
    BuildContext context,
    CourseDetailController controller,
    bool isDark,
  ) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor:
          isDark ? AppColors.bgDark : AppColors.bgLight,
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Iconsax.arrow_left,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
      actions: [
        // Bouton favori
        Obx(() => GestureDetector(
          onTap: controller.toggleFavorite,
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              shape: BoxShape.circle,
            ),
            child: AnimatedSwitcher(
              duration: AppAnimations.fast,
              child: Icon(
                controller.isFavorite.value
                    ? Iconsax.heart5
                    : Iconsax.heart,
                key: ValueKey(controller.isFavorite.value),
                color: controller.isFavorite.value
                    ? AppColors.accent
                    : Colors.white,
                size: 20,
              ),
            ),
          ),
        )),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _buildHeroImage(controller),
      ),
    );
  }

  // ─── Image hero avec gradient ─────────────────────────
  Widget _buildHeroImage(CourseDetailController controller) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Image
        Hero(
          tag: 'course_image_${controller.course.id}',
          child: CachedNetworkImage(
            imageUrl: controller.course.imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              color: AppColors.primary.withOpacity(0.2),
            ),
            errorWidget: (_, __, ___) => Container(
              color: AppColors.primary.withOpacity(0.2),
              child: const Icon(
                Iconsax.book,
                color: AppColors.primary,
                size: 60,
              ),
            ),
          ),
        ),

        // Gradient bas → titre visible
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
                stops: const [0.4, 1.0],
              ),
            ),
          ),
        ),

        // Titre sur l'image
        Positioned(
          bottom: AppDimensions.lg,
          left: AppDimensions.screenPadding,
          right: AppDimensions.screenPadding,
          child: Text(
            controller.course.titre,
            style: AppTextStyles.h1.copyWith(
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Contenu principal ────────────────────────────────
  Widget _buildContent(
    BuildContext context,
    CourseDetailController controller,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Stats du cours ──────────────────────────
          _buildStats(controller, isDark),

          const SizedBox(height: AppDimensions.lg),

          // ── Progression globale ──────────────────────
          Obx(() => _buildProgression(controller, isDark)),

          const SizedBox(height: AppDimensions.lg),

          // ── Description ─────────────────────────────
          _buildDescription(controller, isDark),

          const SizedBox(height: AppDimensions.xl),

          // ── Liste des leçons ─────────────────────────
          _buildLessonsList(controller, isDark),

          // Espace pour le bouton bas
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // ─── Stats : leçons + durée ───────────────────────────
  Widget _buildStats(
    CourseDetailController controller,
    bool isDark,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: AppAnimations.slow,
      curve: AppAnimations.smooth,
      builder: (_, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - value)),
          child: child,
        ),
      ),
      child: Row(
        children: [
          _StatChip(
            icon: Iconsax.book,
            label: '${controller.course.nombreLecons} leçons',
            isDark: isDark,
          ),
          const SizedBox(width: AppDimensions.sm),
          _StatChip(
            icon: Iconsax.clock,
            label: controller.course.dureeFormatee,
            isDark: isDark,
          ),
          const SizedBox(width: AppDimensions.sm),
          _StatChip(
            icon: Iconsax.volume_high,
            label: 'Audio',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  // ─── Progression globale ──────────────────────────────
  Widget _buildProgression(
    CourseDetailController controller,
    bool isDark,
  ) {
    final progression = controller.progressionGlobale;
    if (progression == 0.0) return const SizedBox.shrink();

    final termines = controller.audios
        .where((a) =>
            controller.getAudioStatus(a) == LessonStatus.completed)
        .length;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius:
            BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progression',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$termines / ${controller.audios.length} leçons',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          EcodiProgressBar(
            value: progression,
            height: 6,
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            '${(progression * 100).toInt()}% complété',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Description ─────────────────────────────────────
  Widget _buildDescription(
    CourseDetailController controller,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'À propos',
          style: AppTextStyles.h3.copyWith(
            color: isDark
                ? AppColors.textDarkPrimary
                : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        Text(
          controller.course.description,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark
                ? AppColors.textDarkSecondary
                : AppColors.textSecondary,
            height: 1.7,
          ),
        ),
      ],
    );
  }

  // ─── Liste des leçons ─────────────────────────────────
  Widget _buildLessonsList(
    CourseDetailController controller,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Leçons',
          style: AppTextStyles.h3.copyWith(
            color: isDark
                ? AppColors.textDarkPrimary
                : AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: AppDimensions.md),

        Obx(() => ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.audios.length,
          itemBuilder: (context, index) {
            final audio = controller.audios[index];
            final status = controller.getAudioStatus(audio);
            final isPlaying =
                controller.currentAudio?.id == audio.id;

            // Animation décalée
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
              child: LessonTile(
                audio: audio,
                status: status,
                isPlaying: isPlaying,
                onTap: () => controller.playAudio(audio),
              ),
            );
          },
        )),
      ],
    );
  }

  // ─── Barre bas : bouton Commencer / Reprendre ─────────
  Widget _buildBottomBar(
    BuildContext context,
    CourseDetailController controller,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.only(
        left: AppDimensions.screenPadding,
        right: AppDimensions.screenPadding,
        top: AppDimensions.md,
        bottom: MediaQuery.of(context).padding.bottom +
            AppDimensions.md,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgDark : AppColors.bgLight,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.06),
          ),
        ),
      ),
      child: Obx(() {
        final hasProgress =
            controller.progress.value != null;

        return EcodiButton.primary(
          label: hasProgress ? 'Reprendre' : 'Commencer',
          fullWidth: true,
          icon: Icon(
            hasProgress ? Iconsax.play_circle : Iconsax.play5,
            color: Colors.white,
            size: 20,
          ),
          onTap: controller.resumeCourse,
        );
      }),
    );
  }

  // ─── Skeleton ────────────────────────────────────────
  Widget _buildSkeleton(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SkeletonBox(width: 200, height: 16, radius: 6),
          const SizedBox(height: AppDimensions.md),
          _SkeletonBox(
            width: double.infinity,
            height: 60,
            radius: AppDimensions.radiusMd,
          ),
          const SizedBox(height: AppDimensions.lg),
          _SkeletonBox(width: 100, height: 16, radius: 6),
          const SizedBox(height: AppDimensions.sm),
          _SkeletonBox(
            width: double.infinity,
            height: 80,
            radius: 6,
          ),
          const SizedBox(height: AppDimensions.lg),
          ...List.generate(
            4,
            (i) => Padding(
              padding: const EdgeInsets.only(
                bottom: AppDimensions.sm,
              ),
              child: _SkeletonBox(
                width: double.infinity,
                height: 68,
                radius: AppDimensions.radiusMd,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Erreur ──────────────────────────────────────────
  Widget _buildError(CourseDetailController controller) {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.warning_2,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: AppDimensions.md),
            Text(
              'Erreur de chargement',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: AppDimensions.xl),
            EcodiButton.secondary(
              label: 'Réessayer',
              onTap: controller.refresh,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Widget : chip statistique ────────────────────────────
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.sm,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark2
            : AppColors.cardLight,
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
          Icon(
            icon,
            size: 14,
            color: AppColors.primary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: isDark
                  ? AppColors.textDarkPrimary
                  : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Widget : skeleton box ────────────────────────────────
class _SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.radius,
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
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: (isDark ? Colors.white : Colors.black)
              .withOpacity(_animation.value * 0.12),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}