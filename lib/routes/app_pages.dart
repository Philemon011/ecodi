import 'package:ecodi/features/search/search_screen.dart';
import 'package:get/get.dart';
import '../features/home/home_binding.dart';
import '../features/home/home_screen.dart';
import '../features/course_detail/course_detail_binding.dart';
import '../features/course_detail/course_detail_screen.dart';
import '../features/player/player_binding.dart';
import '../features/player/player_screen.dart';

abstract class AppRoutes {
  static const home = '/home';
  static const course = '/course/:id';
  static const player = '/player';
  static const downloads = '/downloads';
  static const settings = '/settings';
}

abstract class AppPages {
  static const initial = AppRoutes.home;

  static final routes = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.course,
      page: () => const CourseDetailScreen(),
      binding: CourseDetailBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.player,
      page: () => const PlayerScreen(),
      binding: PlayerBinding(),
      // Transition slide du bas vers le haut
      // comme Spotify / Apple Music
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: '/search',
      page: () => const SearchScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 250),
    ),
  ];
}
