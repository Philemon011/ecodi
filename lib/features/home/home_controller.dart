import 'package:get/get.dart';
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

    // ── Données de test (à retirer quand backend prêt) ──
    await Future.delayed(const Duration(seconds: 1));

    final mockCourses = [
      CourseModel(
        id: 1,
        titre: 'Les Fondements de la Foi ',
        description: 'Découvrez les bases essentielles de la foi chrétienne à travers des enseignements audio clairs et profonds.Découvrez les bases essentielles de la foi chrétienne à travers des enseignements audio clairs et profonds.Découvrez les bases essentielles de la foi chrétienne à travers des enseignements audio clairs et profonds.Découvrez les bases essentielles de la foi chrétienne à travers des enseignements audio clairs et profonds.Découvrez les bases essentielles de la foi chrétienne à travers des enseignements audio clairs et profonds.Découvrez les bases essentielles de la foi chrétienne à travers des enseignements audio clairs et profonds.Découvrez les bases essentielles de la foi chrétienne à travers des enseignements audio clairs et profonds.Découvrez les bases essentielles de la foi chrétienne à travers des enseignements audio clairs et profonds.Découvrez les bases essentielles de la foi chrétienne à travers des enseignements audio clairs et profonds.Découvrez les bases essentielles de la foi chrétienne à travers des enseignements audio clairs et profonds.Découvrez les bases essentielles de la foi chrétienne à travers des enseignements audio clairs et profonds.Découvrez les bases essentielles de la foi chrétienne à travers des enseignements audio clairs et profonds.Découvrez les bases essentielles de la foi chrétienne à travers des enseignements audio clairs et profonds.Découvrez les bases essentielles de la foi chrétienne à travers des enseignements audio clairs et profonds.Découvrez les bases essentielles de la foi chrétienne à travers des enseignements audio clairs et profonds.Découvrez les bases essentielles de la foi chrétienne à travers des enseignements audio clairs et profonds.Découvrez les bases essentielles de la foi chrétienne à travers des enseignements audio clairs et profonds.Découvrez les bases essentielles de la foi chrétienne à travers des enseignements audio clairs et profonds.Découvrez les bases essentielles de la foi chrétienne à travers des enseignements audio clairs et profonds.Découvrez les bases essentielles de la foi chrétienne à travers des enseignements audio clairs et profonds.Découvrez les bases essentielles de la foi chrétienne à travers des enseignements audio clairs et profonds.Découvrez les bases essentielles de la foi chrétienne à travers des enseignements audio clairs et profonds.Découvrez les bases essentielles de la foi chrétienne à travers des enseignements audio clairs et profonds.Découvrez les bases essentielles de la foi chrétienne à travers des enseignements audio clairs et profonds.Découvrez les bases essentielles de la foi chrétienne à travers des enseignements audio clairs et profonds.Découvrez les bases essentielles de la foi chrétienne à travers des enseignements audio clairs et profonds.Découvrez les bases essentielles de la foi chrétienne à travers des enseignements audio clairs et profonds.Découvrez les bases essentielles de la foi chrétienne à travers des enseignements audio clairs et profonds.Découvrez les bases essentielles de la foi chrétienne à travers des enseignements audio clairs et profonds.Découvrez les bases essentielles de la foi chrétienne à travers des enseignements audio clairs et profonds.Découvrez les bases essentielles de la foi chrétienne à travers des enseignements audio clairs et profonds.',
        imageUrl: 'https://images.unsplash.com/photo-1504052434569-70ad5836ab65?w=400',
        dureeTotale: 7200,
        nombreLecons: 8,
        ordre: 1,
      ),
      CourseModel(
        id: 2,
        titre: 'Le Saint-Esprit',
        description: 'Une étude approfondie sur la personne et l\'œuvre du Saint-Esprit dans la vie du croyant.',
        imageUrl: 'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=400',
        dureeTotale: 5400,
        nombreLecons: 6,
        ordre: 2,
      ),
      CourseModel(
        id: 3,
        titre: 'La Prière',
        description: 'Apprenez à développer une vie de prière efficace et transformatrice.',
        imageUrl: 'https://images.unsplash.com/photo-1518173946687-a4c8892bbd9f?w=400',
        dureeTotale: 3600,
        nombreLecons: 4,
        ordre: 3,
      ),
      CourseModel(
        id: 4,
        titre: 'L\'Évangile de Jean',
        description: 'Parcourez le quatrième évangile verset par verset pour une compréhension profonde.',
        imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        dureeTotale: 10800,
        nombreLecons: 12,
        ordre: 4,
      ),
      CourseModel(
        id: 3,
        titre: 'La Prière',
        description: 'Apprenez à développer une vie de prière efficace et transformatrice.',
        imageUrl: 'https://images.unsplash.com/photo-1518173946687-a4c8892bbd9f?w=400',
        dureeTotale: 3600,
        nombreLecons: 4,
        ordre: 3,
      ),
      CourseModel(
        id: 4,
        titre: 'L\'Évangile de Jean',
        description: 'Parcourez le quatrième évangile verset par verset pour une compréhension profonde.',
        imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        dureeTotale: 10800,
        nombreLecons: 12,
        ordre: 4,
      ),
      CourseModel(
        id: 3,
        titre: 'La Prière',
        description: 'Apprenez à développer une vie de prière efficace et transformatrice.',
        imageUrl: 'https://images.unsplash.com/photo-1518173946687-a4c8892bbd9f?w=400',
        dureeTotale: 3600,
        nombreLecons: 4,
        ordre: 3,
      ),
      CourseModel(
        id: 4,
        titre: 'L\'Évangile de Jean',
        description: 'Parcourez le quatrième évangile verset par verset pour une compréhension profonde.',
        imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        dureeTotale: 10800,
        nombreLecons: 12,
        ordre: 4,
      ),
      CourseModel(
        id: 3,
        titre: 'La Prière',
        description: 'Apprenez à développer une vie de prière efficace et transformatrice.',
        imageUrl: 'https://images.unsplash.com/photo-1518173946687-a4c8892bbd9f?w=400',
        dureeTotale: 3600,
        nombreLecons: 4,
        ordre: 3,
      ),
      CourseModel(
        id: 4,
        titre: 'L\'Évangile de Jean',
        description: 'Parcourez le quatrième évangile verset par verset pour une compréhension profonde.',
        imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        dureeTotale: 10800,
        nombreLecons: 12,
        ordre: 4,
      ),
    ];

    courses.assignAll(mockCourses);
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