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

  // ─── Progression ─────────────────────────────────────

  // Récupérer la progression d'un cours
  static ProgressModel? getProgress(int courseId) {
    return _progressBox.get(courseId);
  }

  // Sauvegarder la progression
  static Future<void> saveProgress(ProgressModel progress) async {
    await _progressBox.put(progress.courseId, progress);
  }

  // ─── Toutes les progressions ──────────────────────────
static List<ProgressModel> getAllProgressions() {
  return _progressBox.values.toList();
}

// ─── Supprimer une progression ────────────────────────
static Future<void> deleteProgress(int courseId) async {
  await _progressBox.delete(courseId);
}

// ─── Effacer tout l'historique ────────────────────────
static Future<void> clearHistory() async {
  await _historyBox.delete('history');
}

  // Créer ou mettre à jour la progression
  static Future<void> updateProgress({
    required int courseId,
    required int audioId,
    required double position,
    required double dureeAudio,
  }) async {
    final existing = _progressBox.get(courseId);

    if (existing != null) {
      existing.mettreAJour(
        nouvellePosition: position,
        nouvelAudioId: audioId,
      );
    } else {
      await _progressBox.put(
        courseId,
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

  // Progression globale d'un cours (leçons terminées / total)
  static double getCourseProgression(int courseId, int totalLecons) {
    final progress = _progressBox.get(courseId);
    if (progress == null || totalLecons == 0) return 0.0;
    return (progress.estTermine ? 1.0 : progress.pourcentageAudio)
        .clamp(0.0, 1.0);
  }

  // ─── Historique ──────────────────────────────────────

  // Récupérer tout l'historique
  static List<Map<dynamic, dynamic>> getHistory() {
    final history = _historyBox.get('history');
    if (history == null) return [];
    return List<Map<dynamic, dynamic>>.from(history);
  }

  // Ajouter une entrée dans l'historique
  static Future<void> addToHistory({
    required int courseId,
    required int audioId,
  }) async {
    final history = getHistory();

    // Supprimer l'entrée existante pour ce cours
    history.removeWhere((e) => e['course_id'] == courseId);

    // Ajouter en dernier
    history.add({
      'course_id': courseId,
      'audio_id': audioId,
      'date': DateTime.now().toIso8601String(),
    });

    // Garder seulement les 20 derniers
    if (history.length > 20) {
      history.removeAt(0);
    }

    await _historyBox.put('history', history);
  }

  // ─── Favoris ─────────────────────────────────────────

  // Est-ce qu'un cours est en favori ?
  static bool isFavorite(int courseId) {
    final favorites = _getFavoriteIds();
    return favorites.contains(courseId);
  }

  // Ajouter / retirer un favori
  static Future<void> toggleFavorite(int courseId) async {
    final favorites = _getFavoriteIds();

    if (favorites.contains(courseId)) {
      favorites.remove(courseId);
    } else {
      favorites.add(courseId);
    }

    await _favoritesBox.put('favorites', favorites);
  }

  // Liste des ids favoris
  static List<int> _getFavoriteIds() {
    final raw = _favoritesBox.get('favorites');
    if (raw == null) return [];
    return List<int>.from(raw);
  }

  // Tous les ids favoris (public)
  static List<int> getFavoriteIds() => _getFavoriteIds();

  // ─── Téléchargements ─────────────────────────────────

  // Sauvegarder le chemin d'un fichier téléchargé
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

  // Supprimer un téléchargement
  static Future<void> removeDownload(int audioId) async {
    await _downloadsBox.delete('dl_$audioId');
  }

  // Récupérer tous les téléchargements
  static List<Map<dynamic, dynamic>> getAllDownloads() {
    return _downloadsBox.values
        .whereType<Map>()
        .toList();
  }

  // Un audio est-il téléchargé ?
  static bool isDownloaded(int audioId) {
    return _downloadsBox.containsKey('dl_$audioId');
  }

  // Chemin local d'un audio téléchargé
  static String? getLocalPath(int audioId) {
    final data = _downloadsBox.get('dl_$audioId');
    if (data == null) return null;
    return data['path'] as String?;
  }
}