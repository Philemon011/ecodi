import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_animations.dart';
import 'search_controller.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late EcodiSearchController controller;
  late TextEditingController _textController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    controller = Get.put(EcodiSearchController());
    _textController = TextEditingController();
    _focusNode = FocusNode();

    // Ouvrir le clavier automatiquement
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Barre de recherche ───────────────────
            _buildSearchBar(isDark),

            // ── Contenu ─────────────────────────────
            Expanded(
              child: Obx(() => _buildContent(isDark)),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Barre de recherche ───────────────────────────────
  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.screenPadding,
        AppDimensions.screenPaddingTop,
        AppDimensions.screenPadding,
        AppDimensions.md,
      ),
      child: Row(
        children: [
          // Champ de recherche
          Expanded(
            child: AnimatedContainer(
              duration: AppAnimations.normal,
              curve: AppAnimations.smooth,
              height: 50,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.cardDark
                    : AppColors.cardLight,
                borderRadius: BorderRadius.circular(
                  AppDimensions.radiusFull,
                ),
                border: Border.all(
                  color: _focusNode.hasFocus
                      ? AppColors.primary.withOpacity(0.4)
                      : isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.black.withOpacity(0.08),
                  width: _focusNode.hasFocus ? 1.5 : 1,
                ),
                boxShadow: _focusNode.hasFocus
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  // Icône recherche
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.md,
                    ),
                    child: Obx(() => Icon(
                      controller.isSearching.value
                          ? Icons.hourglass_empty_rounded
                          : Iconsax.search_normal,
                      size: 20,
                      color: _focusNode.hasFocus
                          ? AppColors.primary
                          : AppColors.textTertiary,
                    )),
                  ),

                  // TextField
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      onChanged: controller.onQueryChanged,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: isDark
                            ? AppColors.textDarkPrimary
                            : AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Cours, leçons...',
                        hintStyle: AppTextStyles.bodyLarge
                            .copyWith(
                          color: AppColors.textTertiary,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      textInputAction: TextInputAction.search,
                    ),
                  ),

                  // Bouton effacer
                  Obx(() {
                    if (controller.query.value.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return GestureDetector(
                      onTap: () {
                        _textController.clear();
                        controller.clearSearch();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.md,
                        ),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.textTertiary
                                .withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          const SizedBox(width: AppDimensions.md),

          // Bouton Annuler
          GestureDetector(
            onTap: () => Get.back(),
            child: Text(
              'Annuler',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Contenu principal ────────────────────────────────
  Widget _buildContent(bool isDark) {
    // État initial — rien tapé encore
    if (!controller.hasSearched.value) {
      return _buildInitial(isDark);
    }

    // Chargement
    if (controller.isSearching.value) {
      return _buildLoading(isDark);
    }

    // Aucun résultat
    if (controller.results.isEmpty) {
      return _buildNoResults(isDark);
    }

    // Résultats
    return _buildResults(isDark);
  }

  // ─── État initial ─────────────────────────────────────
  Widget _buildInitial(bool isDark) {
    return Center(
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
              Iconsax.search_normal,
              size: 36,
              color: AppColors.primary.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: AppDimensions.lg),
          Text(
            'Cherche un cours ou\nune leçon',
            style: AppTextStyles.h3.copyWith(
              color: isDark
                  ? AppColors.textDarkPrimary
                  : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            'Tape au moins 1 lettre\npour commencer',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── Chargement ───────────────────────────────────────
  Widget _buildLoading(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          4,
          (_) => Padding(
            padding: const EdgeInsets.only(
              bottom: AppDimensions.sm,
            ),
            child: _SkeletonBox(
              width: double.infinity,
              height: 72,
              radius: AppDimensions.radiusMd,
              isDark: isDark,
            ),
          ),
        ),
      ),
    );
  }

  // ─── Aucun résultat ───────────────────────────────────
  Widget _buildNoResults(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.search_status,
              size: 36,
              color: AppColors.warning.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: AppDimensions.lg),
          Text(
            'Aucun résultat',
            style: AppTextStyles.h3.copyWith(
              color: isDark
                  ? AppColors.textDarkPrimary
                  : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          Obx(() => Text(
            '"${controller.query.value}" ne correspond\nà aucun cours ou leçon',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          )),
        ],
      ),
    );
  }

  // ─── Résultats ────────────────────────────────────────
  Widget _buildResults(bool isDark) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPadding,
      ),
      children: [

        // ── Section cours ──────────────────────────
        if (controller.coursesCount > 0) ...[
          _SectionLabel(
            label: 'Cours',
            count: controller.coursesCount,
            isDark: isDark,
          ),
          const SizedBox(height: AppDimensions.sm),
          ...controller.results
              .where((r) => r.isCourse)
              .toList()
              .asMap()
              .entries
              .map((entry) {
            final index = entry.key;
            final result = entry.value;
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(
                milliseconds: 200 + (index * 50),
              ),
              curve: AppAnimations.smooth,
              builder: (_, value, child) => Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 12 * (1 - value)),
                  child: child,
                ),
              ),
              child: _CourseResult(
                course: result.course!,
                isDark: isDark,
                onTap: () => controller.goToCourse(
                  result.course!,
                ),
              ),
            );
          }),
          const SizedBox(height: AppDimensions.lg),
        ],

        // ── Section leçons ─────────────────────────
        if (controller.audiosCount > 0) ...[
          _SectionLabel(
            label: 'Leçons',
            count: controller.audiosCount,
            isDark: isDark,
          ),
          const SizedBox(height: AppDimensions.sm),
          ...controller.results
              .where((r) => !r.isCourse)
              .toList()
              .asMap()
              .entries
              .map((entry) {
            final index = entry.key;
            final result = entry.value;
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(
                milliseconds: 200 + (index * 50),
              ),
              curve: AppAnimations.smooth,
              builder: (_, value, child) => Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 12 * (1 - value)),
                  child: child,
                ),
              ),
              child: _AudioResult(
                audio: result.audio!,
                course: result.course!,
                isDark: isDark,
                onTap: () => controller.playAudio(
                  result.audio!,
                  result.course!,
                ),
              ),
            );
          }),
        ],

        // Espace bas de page
        const SizedBox(height: 100),
      ],
    );
  }


  
  }


  // ─── Label de section ─────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final int count;
  final bool isDark;

  const _SectionLabel({
    required this.label,
    required this.count,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: AppTextStyles.h3.copyWith(
            color: isDark
                ? AppColors.textDarkPrimary
                : AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: AppDimensions.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.sm,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(
              AppDimensions.radiusFull,
            ),
          ),
          child: Text(
            '$count',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Résultat cours ───────────────────────────────────────
class _CourseResult extends StatefulWidget {
  final dynamic course;
  final bool isDark;
  final VoidCallback onTap;

  const _CourseResult({
    required this.course,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_CourseResult> createState() => _CourseResultState();
}

class _CourseResultState extends State<_CourseResult>
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
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    width: 52,
                    height: 52,
                    color: AppColors.primary.withOpacity(0.1),
                    child: const Icon(
                      Iconsax.book,
                      color: AppColors.primary,
                      size: 20,
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
                    const SizedBox(height: 3),
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
                      ],
                    ),
                  ],
                ),
              ),

              // Badge cours
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.sm,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusFull,
                  ),
                ),
                child: Text(
                  'Cours',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
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

// ─── Résultat audio ───────────────────────────────────────
class _AudioResult extends StatefulWidget {
  final dynamic audio;
  final dynamic course;
  final bool isDark;
  final VoidCallback onTap;

  const _AudioResult({
    required this.audio,
    required this.course,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_AudioResult> createState() => _AudioResultState();
}

class _AudioResultState extends State<_AudioResult>
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
              // Icône audio
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMd,
                  ),
                ),
                child: Icon(
                  Iconsax.music,
                  size: 22,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(width: AppDimensions.md),

              // Infos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.audio.titre,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: widget.isDark
                            ? AppColors.textDarkPrimary
                            : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.course.titre,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

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