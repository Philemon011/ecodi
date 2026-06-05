import 'dart:async';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart' as ja;

import '../../core/constants/app_enums.dart';
import '../../data/local/hive_service.dart';
import '../../data/models/audio_model.dart';
import '../../data/models/course_model.dart';
import '../../services/progress_service.dart';
import 'package:flutter/foundation.dart';

class PlayerController extends GetxController {

  // Player direct — sans audio_service pour l'instant
  final ja.AudioPlayer _player = ja.AudioPlayer();

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
    _listenToPlayer();
  }

  @override
  void onClose() {
    _cancelSubscriptions();
    _player.dispose();
    super.onClose();
  }

  // ─── Écouter le player ────────────────────────────────
  void _listenToPlayer() {
    // Position
    _positionSub = _player.positionStream.listen((pos) {
      position.value = pos;
    });

    // Durée
    _durationSub = _player.durationStream.listen((dur) {
      if (dur != null) duration.value = dur;
    });

    // État
    _stateSub = _player.playerStateStream.listen((state) {
      isPlaying.value = state.playing;

      playerState.value = switch (state.processingState) {
        ja.ProcessingState.idle      => PlayerState.idle,
        ja.ProcessingState.loading   => PlayerState.loading,
        ja.ProcessingState.buffering => PlayerState.loading,
        ja.ProcessingState.ready     => state.playing
            ? PlayerState.playing
            : PlayerState.paused,
        ja.ProcessingState.completed => PlayerState.stopped,
        _                            => PlayerState.idle,
      };

      // Audio terminé → suivant automatique
      if (state.processingState == ja.ProcessingState.completed) {
        skipToNext();
      }
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
      playerState.value = PlayerState.loading;

      currentAudio.value = audio;
      currentCourse.value = course;
      this.playlist.assignAll(playlist);

      debugPrint('▶ Chargement audio : ${audio.urlEffective}');

      // Récupérer la position sauvegardée
      final progress = HiveService.getProgress(course.id);
      Duration? initialPosition;
      if (progress != null &&
          progress.audioId == audio.id &&
          !progress.estTermine) {
        initialPosition = Duration(
          seconds: progress.position.toInt(),
        );
        debugPrint('⏩ Reprise à : $initialPosition');
      }

      // Charger l'audio
      await _player.setUrl(
        audio.urlEffective,
        initialPosition: initialPosition,
      );

      // Lancer la lecture
      await _player.play();
      debugPrint('✅ Audio en lecture');

      // Historique
      await HiveService.addToHistory(
        courseId: course.id,
        audioId: audio.id,
      );

      // Sauvegarde progression
      _startProgressTimer();

    } catch (e) {
      debugPrint('❌ Erreur audio : $e');
      playerState.value = PlayerState.error;
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Contrôles ───────────────────────────────────────
  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> seekTo(double value) async {
    final newPos = Duration(
      milliseconds:
          (value * duration.value.inMilliseconds).toInt(),
    );
    await _player.seek(newPos);
  }

  Future<void> seekForward() async {
    final newPos = position.value + const Duration(seconds: 15);
    final max = duration.value;
    await _player.seek(newPos > max ? max : newPos);
  }

  Future<void> seekBackward() async {
    final newPos = position.value - const Duration(seconds: 15);
    await _player.seek(
      newPos < Duration.zero ? Duration.zero : newPos,
    );
  }

  Future<void> skipToNext() async {
    final index = currentIndex;
    if (index < playlist.length - 1) {
      await playAudio(
        audio: playlist[index + 1],
        course: currentCourse.value!,
        playlist: playlist,
      );
    }
  }

  Future<void> skipToPrevious() async {
    if (position.value.inSeconds > 3) {
      await _player.seek(Duration.zero);
      return;
    }
    final index = currentIndex;
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
    await _player.setSpeed(newSpeed);
  }

  List<double> get availableSpeeds =>
      [0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  Future<void> cycleSpeed() async {
    final speeds = availableSpeeds;
    final index = speeds.indexOf(speed.value);
    final next = (index + 1) % speeds.length;
    await setSpeed(speeds[next]);
  }

  // ─── Progression ─────────────────────────────────────
  double get progressValue {
    if (duration.value.inMilliseconds == 0) return 0.0;
    return (position.value.inMilliseconds /
            duration.value.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  String formatDuration(Duration d) {
    final m =
        d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s =
        d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) return '${d.inHours}:$m:$s';
    return '$m:$s';
  }

  // ─── Timer progression ────────────────────────────────
  void _startProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(
      const Duration(seconds: 4),
      (_) => _saveProgress(),
    );
  }

  Future<void> _saveProgress() async {
    final audio = currentAudio.value;
    final course = currentCourse.value;
    if (audio == null || course == null) return;

    await HiveService.updateProgress(
      courseId: course.id,
      audioId: audio.id,
      position: position.value.inSeconds.toDouble(),
      dureeAudio: duration.value.inSeconds.toDouble(),
    );
  }

  // ─── Helpers ─────────────────────────────────────────
  int get _currentIndex => playlist.indexWhere(
        (a) => a.id == currentAudio.value?.id,
      );

  int get currentIndex => _currentIndex;

  bool get hasNext => _currentIndex < playlist.length - 1;
  bool get hasPrevious => _currentIndex > 0;

  // ─── Annuler subscriptions ────────────────────────────
  void _cancelSubscriptions() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _stateSub?.cancel();
    _progressTimer?.cancel();
  }
}