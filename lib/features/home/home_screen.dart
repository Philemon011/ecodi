import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_animations.dart';
import '../../core/widgets/course_card.dart';
import 'home_controller.dart';
import '../../data/local/hive_service.dart';
import '../../core/widgets/ecodi_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        onRefresh: controller.refresh,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── App Bar ──────────────────────────────────
            _buildAppBar(context, isDark),

            // ── Contenu ──────────────────────────────────
            SliverToBoxAdapter(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return _buildSkeleton();
                }
                if (controller.hasError.value) {
                  return _buildError(controller);
                }
                return _buildContent(context, controller, isDark);
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ─── App Bar avec animation ───────────────────────────
  Widget _buildAppBar(BuildContext context, bool isDark) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      snap: true,
      pinned: false,
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(
          left: AppDimensions.screenPadding,
          bottom: AppDimensions.md,
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bonjour 👋',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Ecodi',
              style: AppTextStyles.h1.copyWith(
                color:
                    isDark ? AppColors.textDarkPrimary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
      actions: [
        // Bouton recherche
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            onPressed: () => Get.toNamed('/search'),
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark2 : AppColors.cardLight,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Iconsax.search_normal,
                size: AppDimensions.iconSm,
                color:
                    isDark ? AppColors.textDarkPrimary : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Contenu principal ────────────────────────────────
  Widget _buildContent(
    BuildContext context,
    HomeController controller,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section "Continuer" ──────────────────────
          Obx(() {
            if (controller.lastCourse.value == null) {
              return const SizedBox.shrink();
            }
            return _buildContinueSection(controller, isDark);
          }),

          // ── Section "Tous les cours" ─────────────────
          _buildCoursesSection(controller, isDark),

          // Espace bas de page
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // ─── Section Continuer ────────────────────────────────
  Widget _buildContinueSection(
    HomeController controller,
    bool isDark,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: AppAnimations.slow,
      curve: AppAnimations.smooth,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppDimensions.lg),

          // Titre section
          _SectionTitle(title: 'Continuer'),

          const SizedBox(height: AppDimensions.md),

          // Card horizontale
          CourseCard.horizontal(
            course: controller.lastCourse.value!,
            progress: controller.lastProgress.value,
            onTap: () => controller.goToCourse(
              controller.lastCourse.value!,
            ),
          ),

          const SizedBox(height: AppDimensions.xl),
        ],
      ),
    );
  }

  // ─── Section Tous les cours ───────────────────────────
  Widget _buildCoursesSection(
    HomeController controller,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre + compteur
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SectionTitle(title: 'Tous les cours'),
            Obx(() => Text(
                  '${controller.courses.length} cours',
                  style: AppTextStyles.bodySmall,
                )),
          ],
        ),

        const SizedBox(height: AppDimensions.md),

        // Grille de cours
        Obx(() => _buildCoursesGrid(controller)),
      ],
    );
  }

  // ─── Grille de cours ─────────────────────────────────
  Widget _buildCoursesGrid(HomeController controller) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppDimensions.md,
        mainAxisSpacing: AppDimensions.md,
        childAspectRatio: 0.72,
      ),
      itemCount: controller.courses.length,
      itemBuilder: (context, index) {
        final course = controller.courses[index];
        final progress = HiveService.getProgress(course.id);

        // Animation décalée par index
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(
            milliseconds: 400 + (index * 80),
          ),
          curve: AppAnimations.smooth,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: child,
              ),
            );
          },
          child: CourseCard(
            course: course,
            progress: progress,
            onTap: () => controller.goToCourse(course),
          ),
        );
      },
    );
  }

  // ─── Skeleton loader ─────────────────────────────────
  Widget _buildSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppDimensions.lg),

          // Skeleton "Continuer"
          _SkeletonBox(width: 120, height: 18, radius: 6),
          const SizedBox(height: AppDimensions.md),
          _SkeletonBox(
            width: double.infinity,
            height: AppDimensions.cardHeightSmall,
            radius: AppDimensions.radiusLg,
          ),

          const SizedBox(height: AppDimensions.xl),

          // Skeleton "Tous les cours"
          _SkeletonBox(width: 140, height: 18, radius: 6),
          const SizedBox(height: AppDimensions.md),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppDimensions.md,
              mainAxisSpacing: AppDimensions.md,
              childAspectRatio: 0.72,
            ),
            itemCount: 4,
            itemBuilder: (_, __) => _SkeletonBox(
              width: double.infinity,
              height: double.infinity,
              radius: AppDimensions.radiusLg,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Erreur ──────────────────────────────────────────
  Widget _buildError(HomeController controller) {
    return SizedBox(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.wifi_square,
                size: 32,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
            Text(
              'Impossible de charger',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              'Vérifie ta connexion internet',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppDimensions.xl),
            EcodiButton.primary(
              label: 'Réessayer',
              icon: const Icon(
                Iconsax.refresh,
                size: 18,
                color: Colors.white,
              ),
              onTap: controller.refresh,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Widget : titre de section ────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      title,
      style: AppTextStyles.h2.copyWith(
        color: isDark ? AppColors.textDarkPrimary : AppColors.textPrimary,
      ),
    );
  }
}

// ─── Widget : boîte skeleton animée ──────────────────────
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: (isDark ? Colors.white : Colors.black)
                .withOpacity(_animation.value * 0.12),
            borderRadius: BorderRadius.circular(widget.radius),
          ),
        );
      },
    );
  }
}
