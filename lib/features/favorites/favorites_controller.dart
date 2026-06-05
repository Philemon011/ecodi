import 'package:get/get.dart';
import '../../data/local/hive_service.dart';
import '../../data/models/course_model.dart';
import '../../data/repositories/course_repository.dart';

class FavoritesController extends GetxController {
  final CourseRepository _courseRepo;

  FavoritesController({CourseRepository? courseRepo})
      : _courseRepo = courseRepo ?? CourseRepository();

  // ─── State ───────────────────────────────────────────
  final RxList<CourseModel> favorites = <CourseModel>[].obs;
  final RxBool isLoading = true.obs;

  // ─── Lifecycle ───────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  // ─── Charger les favoris ──────────────────────────────
  Future<void> loadFavorites() async {
    try {
      isLoading.value = true;

      final ids = HiveService.getFavoriteIds();
      final courses = <CourseModel>[];

      for (final id in ids) {
        final course = await _courseRepo.getCourse(id);
        if (course != null) courses.add(course);
      }

      favorites.assignAll(courses);

    } finally {
      isLoading.value = false;
    }
  }

  // ─── Retirer un favori ────────────────────────────────
  Future<void> removeFavorite(CourseModel course) async {
    await HiveService.toggleFavorite(course.id);
    favorites.remove(course);
  }

  // ─── Navigation ───────────────────────────────────────
  void goToCourse(CourseModel course) {
    Get.toNamed('/course/${course.id}', arguments: course);
  }

  // ─── Refresh ─────────────────────────────────────────
  Future<void> refresh() => loadFavorites();
}