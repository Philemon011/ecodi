import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:ecodi/services/progress_service.dart';
import 'package:get/get.dart';
import '../../core/constants/app_enums.dart';
import '../../data/local/hive_service.dart';
import '../../data/models/audio_model.dart';
import '../../data/models/course_model.dart';
import '../../main.dart';

class PlayerController extends GetxController {

  // ─── State observable ────────────────────────────────
  final Rx<AudioModel?> currentAudio = Rx<AudioModel?>(null);
  final Rx<CourseModel?> currentCourse = Rx<CourseModel?>(null);
  final RxList<AudioModel> playlist = <AudioModel>[].obs;

  final RxBool isPlaying = false.obs;
  final RxBool isLoading = false.obs;
  final Rx<PlayerState> playerState = PlayerState.idle.obs;

  final Rx<Duration> position = Duration.zero.obs;
  final Rx<Duration> duration = Duration.zero.obs;
  final RxDouble speed = 1.0.obs;

  

  // ─── Subscriptions ───────────────────────────────────
  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _stateSub;
  Timer? _progressTimer;

  // ─── Lifecycle ───────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _listenToAudioHandler();
  }

  @override
  void onClose() {
    _cancelSubscriptions();
    super.onClose();
  }

  // ─── Écouter les streams de l'AudioHandler ────────────
  void _listenToAudioHandler() {
    // Position
    _positionSub = audioHandler.positionStream.listen((pos) {
      position.value = pos;
    });

    // Durée
    _durationSub = audioHandler.durationStream.listen((dur) {
      if (dur != null) duration.value = dur;
    });

    // État lecture
    _stateSub = audioHandler.playbackState.listen((state) {
      isPlaying.value = state.playing;

      playerState.value = switch (state.processingState) {
        AudioProcessingState.idle      => PlayerState.idle,
        AudioProcessingState.loading   => PlayerState.loading,
        AudioProcessingState.buffering => PlayerState.loading,
        AudioProcessingState.ready     => state.playing
            ? PlayerState.playing
            : PlayerState.paused,
        AudioProcessingState.completed => PlayerState.stopped,
        _                              => PlayerState.idle,
      };
    });
  }

  // ─── Lancer un audio ─────────────────────────────────
  Future<void> playAudio({
    required AudioModel audio,
    required CourseModel course,
    required List<AudioModel> playlist,
  }) async {
    try {
      isLoading.value = true;

      currentAudio.value = audio;
      currentCourse.value = course;
      this.playlist.assignAll(playlist);

      // Récupérer la position sauvegardée
      final progress = HiveService.getProgress(course.id);
      Duration? initialPosition;

      if (progress != null && progress.audioId == audio.id) {
        initialPosition = Duration(
          seconds: progress.position.toInt(),
        );
      }

      // Charger la queue dans l'AudioHandler
      final queue = playlist.map((a) => MediaItem(
        id: a.urlEffective,
        title: a.titre,
        album: course.titre,
        duration: Duration(seconds: a.duree),
        artUri: Uri.parse(course.imageUrl),
        extras: {
          'audio_id': a.id,
          'course_id': course.id,
        },
      )).toList();

      await audioHandler.loadQueue(queue);

      // Charger l'audio sélectionné
      await audioHandler.loadAudio(
        url: audio.urlEffective,
        title: audio.titre,
        courseTitle: course.titre,
        imageUrl: course.imageUrl,
        initialPosition: initialPosition,
      );

      // Lancer la lecture
      await audioHandler.play();

      // Ajouter à l'historique
      await HiveService.addToHistory(
        courseId: course.id,
        audioId: audio.id,
      );

      // Démarrer la sauvegarde automatique
      _startProgressTimer();

    } catch (e) {
      playerState.value = PlayerState.error;
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Contrôles ───────────────────────────────────────
  Future<void> togglePlayPause() async {
    if (isPlaying.value) {
      await audioHandler.pause();
    } else {
      await audioHandler.play();
    }
  }

  Future<void> seekTo(double value) async {
    final newPos = Duration(
      milliseconds: (value * duration.value.inMilliseconds).toInt(),
    );
    await audioHandler.seek(newPos);
  }

  Future<void> seekForward() => audioHandler.seekForward15();
  Future<void> seekBackward() => audioHandler.seekBackward15();

  Future<void> skipToNext() async {
    final index = _currentIndex;
    if (index < playlist.length - 1) {
      await playAudio(
        audio: playlist[index + 1],
        course: currentCourse.value!,
        playlist: playlist,
      );
    }
  }

  Future<void> skipToPrevious() async {
    // Si > 3 secondes → retour au début
    if (position.value.inSeconds > 3) {
      await audioHandler.seek(Duration.zero);
      return;
    }

    final index = _currentIndex;
    if (index > 0) {
      await playAudio(
        audio: playlist[index - 1],
        course: currentCourse.value!,
        playlist: playlist,
      );
    }
  }

  // ─── Vitesse ─────────────────────────────────────────
  Future<void> setSpeed(double newSpeed) async {
    speed.value = newSpeed;
    await audioHandler.setSpeed(newSpeed);
  }

  // Vitesses disponibles
  List<double> get availableSpeeds =>
      [0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  // Passer à la vitesse suivante
  Future<void> cycleSpeed() async {
    final speeds = availableSpeeds;
    final currentIndex = speeds.indexOf(speed.value);
    final nextIndex = (currentIndex + 1) % speeds.length;
    await setSpeed(speeds[nextIndex]);
  }

  // ─── Progression ─────────────────────────────────────

  // Valeur 0.0 → 1.0 pour le slider
  double get progressValue {
    if (duration.value.inMilliseconds == 0) return 0.0;
    return (position.value.inMilliseconds /
            duration.value.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  // Durée formatée "03:45"
  String formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      return '${d.inHours}:$m:$s';
    }
    return '$m:$s';
  }

  // ─── Sauvegarde via ProgressService ──────────────────
void _startProgressTimer() {
  final progressService = Get.find<ProgressService>();
  final audio = currentAudio.value;
  final course = currentCourse.value;
  if (audio == null || course == null) return;

  progressService.startTracking(
    courseId: course.id,
    audioId: audio.id,
    dureeAudio: duration.value.inSeconds.toDouble(),
    getPosition: () async =>
        audioHandler.position.inSeconds.toDouble(),
  );
}

  Future<void> _saveProgress() async {
  final audio = currentAudio.value;
  final course = currentCourse.value;
  if (audio == null || course == null) return;

  await Get.find<ProgressService>().saveNow(
    courseId: course.id,
    audioId: audio.id,
    position: position.value.inSeconds.toDouble(),
    dureeAudio: duration.value.inSeconds.toDouble(),
  );
}

  // ─── Helpers ─────────────────────────────────────────
  int get _currentIndex {
  return playlist.indexWhere(
    (a) => a.id == currentAudio.value?.id,
  );
}

  bool get hasNext => _currentIndex < playlist.length - 1;
  bool get hasPrevious => _currentIndex > 0;

  bool get isFirstAudio => _currentIndex == 0;
  bool get isLastAudio => _currentIndex == playlist.length - 1;

  int get currentIndex => _currentIndex;

  // ─── Annuler les subscriptions ────────────────────────
  void _cancelSubscriptions() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _stateSub?.cancel();
    _progressTimer?.cancel();
  }
}