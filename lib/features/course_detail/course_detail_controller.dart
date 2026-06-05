import 'package:get/get.dart';
import '../../data/models/audio_model.dart';
import '../../data/models/course_model.dart';
import '../../data/models/progress_model.dart';
import '../../data/repositories/audio_repository.dart';
import '../../data/local/hive_service.dart';
import '../../core/constants/app_enums.dart';

class CourseDetailController extends GetxController {

  final AudioRepository _audioRepo;

  CourseDetailController({AudioRepository? audioRepo})
      : _audioRepo = audioRepo ?? AudioRepository();

  // ─── State ───────────────────────────────────────────
  late CourseModel course;
  final RxList<AudioModel> audios = <AudioModel>[].obs;
  final Rx<ProgressModel?> progress = Rx<ProgressModel?>(null);
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxBool isFavorite = false.obs;

  // ─── Lifecycle ───────────────────────────────────────
  @override
  void onInit() {
    super.onInit();

    // Récupérer le cours passé en argument
    course = Get.arguments as CourseModel;

    // Charger les données
    loadAudios();
    _loadProgress();
    _checkFavorite();
  }

  // ─── Chargement des audios ────────────────────────────
  Future<void> loadAudios() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final result = await _audioRepo.getAudios(course.id);
      audios.assignAll(result);

    } catch (e) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Progression ─────────────────────────────────────
  void _loadProgress() {
    progress.value = HiveService.getProgress(course.id);
  }

  // Statut d'un audio précis
  LessonStatus getAudioStatus(AudioModel audio) {
    final p = progress.value;
    if (p == null) return LessonStatus.notStarted;

    // Audio en cours
    if (p.audioId == audio.id && !p.estTermine) {
      return LessonStatus.inProgress;
    }

    // Audio terminé : ordre inférieur à l'audio en cours
    if (audio.ordre < _getCurrentAudioOrdre()) {
      return LessonStatus.completed;
    }

    // Audio terminé explicitement
    if (p.audioId == audio.id && p.estTermine) {
      return LessonStatus.completed;
    }

    return LessonStatus.notStarted;
  }

  int _getCurrentAudioOrdre() {
    final p = progress.value;
    if (p == null) return 0;
    final current = audios.firstWhereOrNull(
      (a) => a.id == p.audioId,
    );
    return current?.ordre ?? 0;
  }

  // Progression globale du cours (0.0 → 1.0)
  double get progressionGlobale {
    if (audios.isEmpty) return 0.0;
    final termines = audios
        .where((a) => getAudioStatus(a) == LessonStatus.completed)
        .length;
    return termines / audios.length;
  }

  // L'audio actuellement en cours
  AudioModel? get currentAudio {
    final p = progress.value;
    if (p == null) return null;
    return audios.firstWhereOrNull((a) => a.id == p.audioId);
  }

  // ─── Favoris ─────────────────────────────────────────
  void _checkFavorite() {
    isFavorite.value = HiveService.isFavorite(course.id);
  }

  Future<void> toggleFavorite() async {
    await HiveService.toggleFavorite(course.id);
    isFavorite.value = HiveService.isFavorite(course.id);
  }

  // ─── Navigation vers le lecteur ──────────────────────
  void playAudio(AudioModel audio) {
    Get.toNamed(
      '/player',
      arguments: {
        'course': course,
        'audio': audio,
        'playlist': audios,
      },
    );
  }

  // Reprendre là où on s'est arrêté
  void resumeCourse() {
  if (audios.isEmpty) return;

  final p = progress.value;
  if (p == null) {
    playAudio(audios.first);
    return;
  }

  // firstWhereOrNull évite le crash
  final audio = audios.firstWhereOrNull(
    (a) => a.id == p.audioId,
  );

  playAudio(audio ?? audios.first);
}

  // ─── Refresh ─────────────────────────────────────────
  Future<void> refresh() async {
    await loadAudios();
    _loadProgress();
  }
}