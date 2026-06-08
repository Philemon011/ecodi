import 'package:hive/hive.dart';
import '../models/progress_model.dart';

class HiveService {
  HiveService._();

  // ─── Boxes ───────────────────────────────────────────
  static Box<ProgressModel> get _progressBox =>
      Hive.box<ProgressModel>('progressBox');

  static Box get _historyBox => Hive.box('historyBox');
  static Box get _favoritesBox => Hive.box('favoritesBox');
  static Box get _downloadsBox => Hive.box('downloadsBox');

  // ════════════════════════════════════════════════════
  // PROGRESSION
  // ════════════════════════════════════════════════════

  // Clé unique par audio
  static String _progressKey(int courseId, int audioId) =>
      '${courseId}_$audioId';

  // Sauvegarder la progression d'un audio
  static Future<void> updateProgress({
    required int courseId,
    required int audioId,
    required double position,
    required double dureeAudio,
  }) async {
    final key = _progressKey(courseId, audioId);
    final existing = _progressBox.get(key);

    if (existing != null) {
      existing.audioId = audioId;
      existing.position = position;
      existing.dureeAudio = dureeAudio;
      existing.derniereLecture = DateTime.now();
      if (existing.pourcentageAudio >= 0.90) {
        existing.termine = true;
      }
      await existing.save();
    } else {
      await _progressBox.put(
        key,
        ProgressModel(
          courseId: courseId,
          audioId: audioId,
          position: position,
          dureeAudio: dureeAudio,
          derniereLecture: DateTime.now(),
        ),
      );
    }
  }

  // Dernière leçon écoutée d'un cours
  static ProgressModel? getProgress(int courseId) {
    final entries = _progressBox.values
        .where((p) => p.courseId == courseId)
        .toList();

    if (entries.isEmpty) return null;

    entries.sort((a, b) =>
        b.derniereLecture.compareTo(a.derniereLecture));

    return entries.first;
  }

  // Progression d'un audio précis
  static ProgressModel? getAudioProgress(
      int courseId, int audioId) {
    return _progressBox.get(
      _progressKey(courseId, audioId),
    );
  }

  // Nombre de leçons terminées pour un cours
  static int getCompletedAudiosCount(int courseId) {
    return _progressBox.values
        .where((p) => p.courseId == courseId && p.estTermine)
        .length;
  }

  // Un audio est-il terminé ?
  static bool isAudioCompleted(int courseId, int audioId) {
    final p = _progressBox.get(
      _progressKey(courseId, audioId),
    );
    return p?.estTermine ?? false;
  }

  // Un audio est-il en cours ?
  static bool isAudioInProgress(int courseId, int audioId) {
    final p = _progressBox.get(
      _progressKey(courseId, audioId),
    );
    if (p == null) return false;
    return !p.estTermine && p.position > 0;
  }

  // Progression globale d'un cours (0.0 → 1.0)
  static double getCourseProgression(
      int courseId, int totalLecons) {
    if (totalLecons == 0) return 0.0;

    final terminees = getCompletedAudiosCount(courseId);

    final enCours = _progressBox.values
        .where((p) =>
            p.courseId == courseId &&
            !p.estTermine &&
            p.position > 0)
        .toList();

    double progression = terminees / totalLecons;

    if (enCours.isNotEmpty) {
      final current = enCours.first;
      progression += current.pourcentageAudio / totalLecons;
    }

    return progression.clamp(0.0, 1.0);
  }

  // Toutes les progressions d'un cours
  static List<ProgressModel> getAllProgressions() {
    return _progressBox.values.toList();
  }

  // Supprimer la progression d'un cours
  static Future<void> deleteProgress(int courseId) async {
    final keys = _progressBox.keys
        .where((k) => k.toString().startsWith('${courseId}_'))
        .toList();
    for (final key in keys) {
      await _progressBox.delete(key);
    }
  }

  // ════════════════════════════════════════════════════
  // HISTORIQUE
  // ════════════════════════════════════════════════════

  static List<Map<dynamic, dynamic>> getHistory() {
    final history = _historyBox.get('history');
    if (history == null) return [];
    return List<Map<dynamic, dynamic>>.from(history);
  }

  static Future<void> addToHistory({
    required int courseId,
    required int audioId,
  }) async {
    final history = getHistory();

    history.removeWhere((e) => e['course_id'] == courseId);

    history.add({
      'course_id': courseId,
      'audio_id': audioId,
      'date': DateTime.now().toIso8601String(),
    });

    if (history.length > 20) {
      history.removeAt(0);
    }

    await _historyBox.put('history', history);
  }

  static Future<void> clearHistory() async {
    await _historyBox.delete('history');
  }

  // ════════════════════════════════════════════════════
  // FAVORIS
  // ════════════════════════════════════════════════════

  static bool isFavorite(int courseId) {
    return _getFavoriteIds().contains(courseId);
  }

  static Future<void> toggleFavorite(int courseId) async {
    final favorites = _getFavoriteIds();

    if (favorites.contains(courseId)) {
      favorites.remove(courseId);
    } else {
      favorites.add(courseId);
    }

    await _favoritesBox.put('favorites', favorites);
  }

  static List<int> _getFavoriteIds() {
    final raw = _favoritesBox.get('favorites');
    if (raw == null) return [];
    return List<int>.from(raw);
  }

  static List<int> getFavoriteIds() => _getFavoriteIds();

  // ════════════════════════════════════════════════════
  // TÉLÉCHARGEMENTS
  // ════════════════════════════════════════════════════

  static Future<void> saveDownload({
    required int audioId,
    required String path,
    required double sizeMb,
  }) async {
    await _downloadsBox.put('dl_$audioId', {
      'audio_id': audioId,
      'path': path,
      'size_mb': sizeMb,
      'date': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> removeDownload(int audioId) async {
    await _downloadsBox.delete('dl_$audioId');
  }

  static List<Map<dynamic, dynamic>> getAllDownloads() {
    return _downloadsBox.values
        .whereType<Map>()
        .toList();
  }

  static bool isDownloaded(int audioId) {
    return _downloadsBox.containsKey('dl_$audioId');
  }

  static String? getLocalPath(int audioId) {
    final data = _downloadsBox.get('dl_$audioId');
    if (data == null) return null;
    return data['path'] as String?;
  }
}