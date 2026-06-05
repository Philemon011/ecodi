import 'dart:async';
import 'package:get/get.dart';
import '../data/local/hive_service.dart';
import '../data/models/progress_model.dart';

class ProgressService extends GetxService {

  Timer? _timer;

  // ─── Progression observable ───────────────────────────
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

  // ─── Charger toutes les progressions au démarrage ─────
  void _loadAllProgressions() {
    final box = HiveService.getAllProgressions();
    for (final progress in box) {
      courseProgressions[progress.courseId] =
          progress.pourcentageAudio;
    }
  }

  // ─── Démarrer la sauvegarde automatique ───────────────
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
        await _saveProgress(
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

  // ─── Sauvegarder la progression ───────────────────────
  Future<void> _saveProgress({
    required int courseId,
    required int audioId,
    required double position,
    required double dureeAudio,
  }) async {
    await HiveService.updateProgress(
      courseId: courseId,
      audioId: audioId,
      position: position,
      dureeAudio: dureeAudio,
    );

    // Mettre à jour l'observable
    final progress = HiveService.getProgress(courseId);
    if (progress != null) {
      courseProgressions[courseId] = progress.pourcentageAudio;
    }
  }

  // ─── Sauvegarder immédiatement (fermeture app) ────────
  Future<void> saveNow({
    required int courseId,
    required int audioId,
    required double position,
    required double dureeAudio,
  }) async {
    await _saveProgress(
      courseId: courseId,
      audioId: audioId,
      position: position,
      dureeAudio: dureeAudio,
    );
  }

  // ─── Récupérer la progression d'un cours ──────────────
  double getProgression(int courseId) {
    return courseProgressions[courseId] ?? 0.0;
  }

  // ─── Récupérer la position de reprise ─────────────────
  Duration? getResumePosition(int courseId, int audioId) {
    final progress = HiveService.getProgress(courseId);
    if (progress == null) return null;
    if (progress.audioId != audioId) return null;
    if (progress.estTermine) return null;
    return Duration(seconds: progress.position.toInt());
  }

  // ─── Marquer un audio comme terminé ──────────────────
  Future<void> markAsCompleted({
    required int courseId,
    required int audioId,
    required double dureeAudio,
  }) async {
    await HiveService.updateProgress(
      courseId: courseId,
      audioId: audioId,
      position: dureeAudio,
      dureeAudio: dureeAudio,
    );
    courseProgressions[courseId] = 1.0;
  }

  // ─── Réinitialiser la progression d'un cours ──────────
  Future<void> resetProgression(int courseId) async {
    await HiveService.deleteProgress(courseId);
    courseProgressions.remove(courseId);
  }
}