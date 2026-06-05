import 'dart:async';
import 'package:get/get.dart';
import '../../data/models/audio_model.dart';
import '../../data/models/course_model.dart';
import '../../data/repositories/audio_repository.dart';
import '../../data/repositories/course_repository.dart';

class SearchResult {
  final CourseModel? course;
  final AudioModel? audio;
  final bool isCourse;

  SearchResult.course(this.course)
      : audio = null,
        isCourse = true;

  SearchResult.audio(this.audio, CourseModel parentCourse)
      : course = parentCourse,
        isCourse = false;
}

class EcodiSearchController extends GetxController {
  final CourseRepository _courseRepo;
  final AudioRepository _audioRepo;

  EcodiSearchController({
    CourseRepository? courseRepo,
    AudioRepository? audioRepo,
  })  : _courseRepo = courseRepo ?? CourseRepository(),
        _audioRepo = audioRepo ?? AudioRepository();

  // ─── State ───────────────────────────────────────────
  final RxList<SearchResult> results = <SearchResult>[].obs;
  final RxBool isSearching = false.obs;
  final RxBool hasSearched = false.obs;
  final RxString query = ''.obs;

  // Debounce timer
  Timer? _debounce;

  // ─── Lifecycle ───────────────────────────────────────
  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  // ─── Recherche avec debounce ──────────────────────────
  void onQueryChanged(String value) {
    query.value = value;

    // Annuler le timer précédent
    _debounce?.cancel();

    if (value.trim().isEmpty) {
      results.clear();
      hasSearched.value = false;
      isSearching.value = false;
      return;
    }

    // Attendre 400ms avant de chercher
    // évite de chercher à chaque frappe
    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => _search(value.trim()),
    );
  }

  // ─── Recherche principale ─────────────────────────────
  Future<void> _search(String q) async {
    try {
      isSearching.value = true;
      hasSearched.value = true;

      final searchResults = <SearchResult>[];
      final qLower = q.toLowerCase();

      // 1. Chercher dans les cours (cache local)
      final courses = _courseRepo.searchLocal(q);
      for (final course in courses) {
        searchResults.add(SearchResult.course(course));
      }

      // 2. Chercher dans les audios (cache local)
      final audios = _searchAudios(qLower);
      for (final entry in audios.entries) {
        searchResults.add(
          SearchResult.audio(entry.key, entry.value),
        );
      }

      results.assignAll(searchResults);

    } finally {
      isSearching.value = false;
    }
  }

  // ─── Recherche dans les audios ────────────────────────
  Map<AudioModel, CourseModel> _searchAudios(String q) {
    final Map<AudioModel, CourseModel> found = {};
    final courses = _courseRepo.searchLocal('');

    // Si pas de résultats cours on cherche quand même les audios
    final allCourses = _courseRepo.getAllCachedCourses();

    for (final course in allCourses) {
      final audios = _audioRepo.getAudiosFromCache(course.id);
      for (final audio in audios) {
        if (audio.titre.toLowerCase().contains(q)) {
          found[audio] = course;
        }
      }
    }
    return found;
  }

  // ─── Effacer la recherche ─────────────────────────────
  void clearSearch() {
    query.value = '';
    results.clear();
    hasSearched.value = false;
    isSearching.value = false;
    _debounce?.cancel();
  }

  // ─── Navigation ───────────────────────────────────────
  void goToCourse(CourseModel course) {
    Get.toNamed('/course/${course.id}', arguments: course);
  }

  void playAudio(AudioModel audio, CourseModel course) {
    Get.toNamed(
      '/player',
      arguments: {
        'course': course,
        'audio': audio,
        'playlist': [audio],
      },
    );
  }

  // ─── Compteurs ────────────────────────────────────────
  int get coursesCount =>
      results.where((r) => r.isCourse).length;

  int get audiosCount =>
      results.where((r) => !r.isCourse).length;
}