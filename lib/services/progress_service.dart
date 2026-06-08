import 'dart:async';
import 'package:get/get.dart';
import '../data/local/hive_service.dart';
import '../data/models/progress_model.dart';

class ProgressService extends GetxService {

  Timer? _timer;

  // ─── State réactif observable par tous les écrans ────
  final RxMap<String, ProgressModel> progressions =
      <String, ProgressModel>{}.obs;

  final RxMap<int, double> courseProgressions =
      <int, double>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAllProgressions();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  // ─── Charger toutes les progressions au démarrage ────
  void _loadAllProgressions() {
    final all = HiveService.getAllProgressions();
    for (final p in all) {
      final key = '${p.courseId}_${p.audioId}';
      progressions[key] = p;
    }
    _recalculateAllCourses();
  }

  // ─── Recalculer la progression de tous les cours ─────
  void _recalculateAllCourses() {
    final courseIds = progressions.values
        .map((p) => p.courseId)
        .toSet();

    for (final courseId in courseIds) {
      _recalculateCourse(courseId);
    }
  }

  // ─── Recalculer la progression d'un cours ────────────
  void _recalculateCourse(int courseId) {
    final entries = progressions.values
        .where((p) => p.courseId == courseId)
        .toList();

    if (entries.isEmpty) {
      courseProgressions[courseId] = 0.0;
      return;
    }

    final totalTerminees = entries.where((p) => p.estTermine).length;
    final enCours = entries
        .where((p) => !p.estTermine && p.position > 0)
        .toList();

    // On ne peut pas calculer sans savoir le total des leçons
    // On stocke juste le nombre de terminées pour l'instant
    // Le calcul final se fait dans les controllers
    courseProgressions[courseId] =
        totalTerminees.toDouble();
  }

  // ─── Mettre à jour la progression d'un audio ─────────
  Future<void> updateProgress({
    required int courseId,
    required int audioId,
    required double position,
    required double dureeAudio,
  }) async {
    // Sauvegarder dans Hive
    await HiveService.updateProgress(
      courseId: courseId,
      audioId: audioId,
      position: position,
      dureeAudio: dureeAudio,
    );

    // Mettre à jour le state réactif
    final key = '${courseId}_$audioId';
    final updated = HiveService.getAudioProgress(courseId, audioId);
    if (updated != null) {
      progressions[key] = updated;
      _recalculateCourse(courseId);
    }
  }

  // ─── Démarrer le tracking ─────────────────────────────
  void startTracking({
    required int courseId,
    required int audioId,
    required double dureeAudio,
    required Future<double> Function() getPosition,
  }) {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 4),
      (_) async {
        final position = await getPosition();
        await updateProgress(
          courseId: courseId,
          audioId: audioId,
          position: position,
          dureeAudio: dureeAudio,
        );
      },
    );
  }

  // ─── Arrêter le tracking ──────────────────────────────
  void stopTracking() {
    _timer?.cancel();
    _timer = null;
  }

  // ─── Sauvegarder immédiatement ────────────────────────
  Future<void> saveNow({
    required int courseId,
    required int audioId,
    required double position,
    required double dureeAudio,
  }) async {
    await updateProgress(
      courseId: courseId,
      audioId: audioId,
      position: position,
      dureeAudio: dureeAudio,
    );
  }

  // ─── Getters réactifs ────────────────────────────────

  // Progression d'un audio (0.0 → 1.0)
  double getAudioProgression(int courseId, int audioId) {
    final key = '${courseId}_$audioId';
    return progressions[key]?.pourcentageAudio ?? 0.0;
  }

  // Progression globale d'un cours (0.0 → 1.0)
  double getCourseProgression(int courseId, int totalLecons) {
    if (totalLecons == 0) return 0.0;

    final entries = progressions.values
        .where((p) => p.courseId == courseId)
        .toList();

    final terminees = entries.where((p) => p.estTermine).length;
    final enCours = entries
        .where((p) => !p.estTermine && p.position > 0)
        .toList();

    double progression = terminees / totalLecons;

    if (enCours.isNotEmpty) {
      progression += enCours.first.pourcentageAudio / totalLecons;
    }

    return progression.clamp(0.0, 1.0);
  }

  // Statut d'un audio
  bool isAudioCompleted(int courseId, int audioId) {
    final key = '${courseId}_$audioId';
    return progressions[key]?.estTermine ?? false;
  }

  bool isAudioInProgress(int courseId, int audioId) {
    final key = '${courseId}_$audioId';
    final p = progressions[key];
    if (p == null) return false;
    return !p.estTermine && p.position > 0;
  }

  // Position de reprise
  Duration? getResumePosition(int courseId, int audioId) {
    final key = '${courseId}_$audioId';
    final p = progressions[key];
    if (p == null) return null;
    if (p.estTermine) return null;
    return Duration(seconds: p.position.toInt());
  }
}