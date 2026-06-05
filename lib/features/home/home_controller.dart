import 'package:get/get.dart';
import '../../data/models/course_model.dart';
import '../../data/models/progress_model.dart';
import '../../data/repositories/course_repository.dart';
import '../../data/local/hive_service.dart';
import 'package:hive/hive.dart';
import '../../core/utils/mock_data.dart';
import '../../data/models/course_model.dart';

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
  }

  // ─── Chargement des cours ─────────────────────────────
  // Future<void> loadCourses() async {
  //   try {
  //     isLoading.value = true;
  //     hasError.value = false;

  //     final result = await _courseRepo.getCourses();
  //     courses.assignAll(result);

  //     // Charger le dernier cours écouté
  //     _loadLastCourse();

  //   } catch (e) {
  //     hasError.value = true;
  //     errorMessage.value = 'Impossible de charger les cours';
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  Future<void> loadCourses() async {
  try {
    isLoading.value = true;
    hasError.value = false;

    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 800));

    // Données mock
    courses.assignAll(MockData.courses);

    // Mettre en cache dans Hive pour la recherche
    final box = Hive.box<CourseModel>('coursesBox');
    for (final course in MockData.courses) {
      await box.put(course.id, course);
    }

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

    // Dernier élément de l'historique
    final lastEntry = history.last;
    final courseId = lastEntry['course_id'] as int?;
    if (courseId == null) return;

    // Trouver le cours dans la liste
    final course = courses.firstWhereOrNull((c) => c.id == courseId);
    if (course == null) return;

    lastCourse.value = course;
    lastProgress.value = HiveService.getProgress(courseId);
  }

  // ─── Progression d'un cours ───────────────────────────
  double getProgression(int courseId) {
    final progress = HiveService.getProgress(courseId);
    return progress?.pourcentageAudio ?? 0.0;
  }

  // ─── Refresh ─────────────────────────────────────────
  Future<void> refresh() => loadCourses();

  // ─── Navigation vers un cours ─────────────────────────
  void goToCourse(CourseModel course) {
    Get.toNamed('/course/${course.id}', arguments: course);
  }
}