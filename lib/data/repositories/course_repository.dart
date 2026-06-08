import 'package:hive/hive.dart';

import '../models/course_model.dart';
import '../providers/api_provider.dart';

class CourseRepository {
  final ApiProvider _api;
  final Box<CourseModel> _box;

  CourseRepository({
    ApiProvider? api,
    Box<CourseModel>? box,
  })  : _api = api ?? ApiProvider(),
        _box = box ?? Hive.box<CourseModel>('coursesBox');

  // ─── Récupérer tous les cours ─────────────────────────

  Future<List<CourseModel>> getCourses() async {
    try {
      // 1. On essaie l'API en premier
      final courses = await _api.fetchCourses();

      // 2. On met à jour le cache Hive
      await _box.clear();
      for (final course in courses) {
        await _box.put(course.id, course);
      }

      return courses;

    } on ApiException {
      // 3. Pas de réseau ? On sert le cache
      return _getCoursesFromCache();
    } catch (e) {
      return _getCoursesFromCache();
    }
  }

  // ─── Récupérer un cours par id ────────────────────────

  Future<CourseModel?> getCourse(int id) async {
    try {
      final course = await _api.fetchCourse(id);

      // Mettre à jour ce cours dans le cache
      await _box.put(course.id, course);

      return course;

    } on ApiException {
      // Fallback : cache Hive
      return _box.get(id);
    } catch (e) {
      return _box.get(id);
    }
  }

  // ─── Recherche locale dans le cache ──────────────────

  List<CourseModel> searchLocal(String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return [];

    return _box.values.where((course) {
      return course.titre.toLowerCase().contains(q) ||
          course.description.toLowerCase().contains(q);
    }).toList();
  }

  // ─── Cache uniquement ─────────────────────────────────

  List<CourseModel> _getCoursesFromCache() {
    final courses = _box.values.toList();

    // Trier par ordre
    courses.sort((a, b) => a.ordre.compareTo(b.ordre));

    return courses;
  }

  // Récupérer un cours depuis le cache uniquement
CourseModel? getCourseFromCache(int id) {
  return _box.get(id);
}

  // Tous les cours en cache
List<CourseModel> getAllCachedCourses() {
  return _box.values.toList();
}

  // Cache vide ?
  bool get cacheVide => _box.isEmpty;

  // Nombre de cours en cache
  int get nombreCours => _box.length;
}