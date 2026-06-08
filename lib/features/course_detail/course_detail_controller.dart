import 'package:collection/collection.dart';
import 'package:get/get.dart';

import '../../core/constants/app_enums.dart';
import '../../data/local/hive_service.dart';
import '../../data/models/audio_model.dart';
import '../../data/models/course_model.dart';
import '../../data/models/progress_model.dart';
import '../../data/repositories/audio_repository.dart';
import '../../services/progress_service.dart';
import '../player/player_controller.dart';

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

    course = Get.arguments as CourseModel;

    loadAudios();
    _checkFavorite();

    // Écouter les changements de progression → rebuild auto
    ever(Get.find<ProgressService>().progressions, (_) {
      progress.value = HiveService.getProgress(course.id);
      audios.refresh();
    });
  }

  // ─── Chargement des audios depuis l'API ──────────────
  Future<void> loadAudios() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final result = await _audioRepo.getAudios(course.id);
      audios.assignAll(result);

      // Charger la progression initiale
      progress.value = HiveService.getProgress(course.id);

    } catch (e) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Statut d'un audio ────────────────────────────────
  LessonStatus getAudioStatus(AudioModel audio) {
    final ps = Get.find<ProgressService>();

    if (ps.isAudioCompleted(course.id, audio.id)) {
      return LessonStatus.completed;
    }
    if (ps.isAudioInProgress(course.id, audio.id)) {
      return LessonStatus.inProgress;
    }
    return LessonStatus.notStarted;
  }

  // ─── Progression globale ──────────────────────────────
  double get progressionGlobale {
    return Get.find<ProgressService>().getCourseProgression(
      course.id,
      audios.length,
    );
  }

  // ─── Audio actuellement en lecture ───────────────────
  AudioModel? get currentAudio {
    final playerController = Get.find<PlayerController>();

    if (playerController.currentAudio.value == null) return null;
    if (playerController.playerState.value == PlayerState.idle) {
      return null;
    }
    if (playerController.playerState.value == PlayerState.stopped) {
      return null;
    }

    return audios.firstWhereOrNull(
      (a) => a.id == playerController.currentAudio.value?.id,
    );
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

  // ─── Reprendre le cours ───────────────────────────────
  void resumeCourse() {
    if (audios.isEmpty) return;

    final p = progress.value;
    if (p == null) {
      playAudio(audios.first);
      return;
    }

    final audio = audios.firstWhereOrNull(
      (a) => a.id == p.audioId,
    );

    playAudio(audio ?? audios.first);
  }

  // ─── Refresh ─────────────────────────────────────────
  Future<void> refresh() async {
    await loadAudios();
  }
}