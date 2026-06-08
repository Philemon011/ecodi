import 'package:ecodi/services/progress_service.dart';
import 'package:get/get.dart';
import 'package:collection/collection.dart';
import '../../data/models/course_model.dart';
import '../../data/models/progress_model.dart';
import '../../data/repositories/course_repository.dart';
import '../../data/local/hive_service.dart';

class HomeController extends GetxController {

  final CourseRepository _courseRepo;

  HomeController({CourseRepository? courseRepo})
      : _courseRepo = courseRepo ?? CourseRepository();

  // ─── State observable ────────────────────────────────
  final RxList<CourseModel> courses = <CourseModel>[].obs;
  final Rx<CourseModel?> lastCourse = Rx<CourseModel?>(null);
  final Rx<ProgressModel?> lastProgress = Rx<ProgressModel?>(null);
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // ─── Lifecycle ───────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    loadCourses();

    // Écouter les changements de progression → rebuild des cartes
    ever(Get.find<ProgressService>().progressions, (_) {
      courses.refresh();
      _loadLastCourse();
    });
  }

  // ─── Chargement depuis la vraie API ──────────────────
  Future<void> loadCourses() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final result = await _courseRepo.getCourses();
      courses.assignAll(result);

      _loadLastCourse();

    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Impossible de charger les cours';
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Dernier cours écouté ─────────────────────────────
  void _loadLastCourse() {
    final history = HiveService.getHistory();
    if (history.isEmpty) return;

    final lastEntry = history.last;
    final courseId = lastEntry['course_id'] as int?;
    if (courseId == null) return;

    final course = courses.firstWhereOrNull(
      (c) => c.id == courseId,
    );
    if (course == null) return;

    lastCourse.value = course;
    lastProgress.value = HiveService.getProgress(courseId);
  }

  // ─── Progression d'un cours ───────────────────────────
  double getProgression(int courseId) {
    final course = courses.firstWhereOrNull(
      (c) => c.id == courseId,
    );
    if (course == null) return 0.0;

    return Get.find<ProgressService>().getCourseProgression(
      courseId,
      course.nombreLecons,
    );
  }

  // ─── Refresh ─────────────────────────────────────────
  Future<void> refresh() => loadCourses();

  // ─── Navigation vers un cours ─────────────────────────
  void goToCourse(CourseModel course) {
    Get.toNamed('/course/${course.id}', arguments: course);
  }
}