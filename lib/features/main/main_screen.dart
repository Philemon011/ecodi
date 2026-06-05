import 'package:ecodi/features/favorites/favorites_screen.dart';
import 'package:ecodi/features/history/history_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_animations.dart';
import '../../core/widgets/mini_player.dart';
import '../home/home_screen.dart';
import '../home/home_binding.dart';
import '../downloads/downloads_screen.dart';
import '../settings/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;

  // Écrans
  final List<Widget> _screens = const [
    HomeScreen(),
    FavoritesScreen(),
    HistoryScreen(),
    DownloadsScreen(),
    SettingsScreen(),
  ];
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    // Init les bindings des écrans
    HomeBinding().dependencies();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: AppAnimations.normal,
      curve: AppAnimations.smooth,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: Stack(
        children: [
          // ── Écrans ────────────────────────────────
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: _screens,
          ),

          // ── Mini Player + Bottom Nav ───────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Mini player au-dessus de la nav bar
                const MiniPlayer(),

                // Bottom navigation bar
                _buildBottomNav(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Bottom Navigation Bar ────────────────────────────
  Widget _buildBottomNav(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.06),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppDimensions.bottomNavHeight,
          child: Row(
            children: [
              // Nav items
              _NavItem(
                icon: Iconsax.home,
                iconActive: Iconsax.home_25,
                label: 'Accueil',
                isActive: _currentIndex == 0,
                onTap: () => _onTabChanged(0),
              ),
              _NavItem(
                icon: Iconsax.heart,
                iconActive: Iconsax.heart5,
                label: 'Favoris',
                isActive: _currentIndex == 1,
                onTap: () => _onTabChanged(1),
              ),
              _NavItem(
                icon: Iconsax.clock,
                iconActive: Iconsax.clock5,
                label: 'Historique',
                isActive: _currentIndex == 2,
                onTap: () => _onTabChanged(2),
              ),
              _NavItem(
                icon: Iconsax.document_download,
                iconActive: Iconsax.document_download5,
                label: 'Télécharg.',
                isActive: _currentIndex == 3,
                onTap: () => _onTabChanged(3),
              ),
              _NavItem(
                icon: Iconsax.setting,
                iconActive: Iconsax.setting_2,
                label: 'Paramètres',
                isActive: _currentIndex == 4,
                onTap: () => _onTabChanged(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Item de navigation ───────────────────────────────────
class _NavItem extends StatefulWidget {
  final IconData icon;
  final IconData iconActive;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.iconActive,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
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
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.85).animate(
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        behavior: HitTestBehavior.opaque,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Indicateur actif
              AnimatedContainer(
                duration: AppAnimations.normal,
                curve: AppAnimations.smooth,
                width: widget.isActive ? 32 : 0,
                height: 3,
                margin: const EdgeInsets.only(
                  bottom: AppDimensions.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Icône
              AnimatedSwitcher(
                duration: AppAnimations.fast,
                child: Icon(
                  widget.isActive ? widget.iconActive : widget.icon,
                  key: ValueKey(widget.isActive),
                  size: AppDimensions.iconMd,
                  color: widget.isActive
                      ? AppColors.primary
                      : isDark
                          ? AppColors.textDarkSecondary
                          : AppColors.textTertiary,
                ),
              ),

              const SizedBox(height: AppDimensions.xs),

              // Label
              AnimatedDefaultTextStyle(
                duration: AppAnimations.fast,
                style: AppTextStyles.labelSmall.copyWith(
                  color: widget.isActive
                      ? AppColors.primary
                      : isDark
                          ? AppColors.textDarkSecondary
                          : AppColors.textTertiary,
                  fontWeight:
                      widget.isActive ? FontWeight.w600 : FontWeight.w400,
                ),
                child: Text(widget.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
