import 'package:collection/collection.dart';
import 'package:hive/hive.dart';

import '../models/audio_model.dart';
import '../providers/api_provider.dart';

class AudioRepository {
  final ApiProvider _api;
  final Box<AudioModel> _box;

  AudioRepository({
    ApiProvider? api,
    Box<AudioModel>? box,
  })  : _api = api ?? ApiProvider(),
        _box = box ?? Hive.box<AudioModel>('audiosBox');


        // ─── Récupérer un audio par son id seul ───────────────
AudioModel? getAudioFromBox(int audioId) {
  return _box.values.firstWhereOrNull(
    (a) => a.id == audioId,
  );
}

  // ─── Récupérer les audios d'un cours ─────────────────

  Future<List<AudioModel>> getAudios(int courseId) async {
    try {
      // 1. Appel API
      final audios = await _api.fetchAudios(courseId);

      // 2. Mettre à jour le cache
      // On garde les localPath existants avant d'écraser
      for (final audio in audios) {
        final existing = _box.get(_audioKey(courseId, audio.id));
        if (existing != null && existing.localPath != null) {
          audio.localPath = existing.localPath;
        }
        await _box.put(_audioKey(courseId, audio.id), audio);
      }

      return _sortedAudios(audios);

    } on ApiException {
      return _getAudiosFromCache(courseId);
    } catch (e) {
      return _getAudiosFromCache(courseId);
    }
  }

  // ─── Récupérer un audio précis ────────────────────────

  AudioModel? getAudio(int courseId, int audioId) {
    return _box.get(_audioKey(courseId, audioId));
  }

  // ─── Marquer un audio comme téléchargé ───────────────

  Future<void> setLocalPath(int courseId, int audioId, String path) async {
    final audio = _box.get(_audioKey(courseId, audioId));
    if (audio != null) {
      audio.localPath = path;
      await audio.save();
    }
  }

  // ─── Supprimer le fichier local d'un audio ────────────

  Future<void> removeLocalPath(int courseId, int audioId) async {
    final audio = _box.get(_audioKey(courseId, audioId));
    if (audio != null) {
      audio.localPath = null;
      await audio.save();
    }
  }

  // ─── Tous les audios téléchargés ─────────────────────

  List<AudioModel> getDownloadedAudios() {
    return _box.values
        .where((audio) => audio.estTelecharge)
        .toList();
  }

  // ─── Audios téléchargés d'un cours précis ────────────

  List<AudioModel> getDownloadedAudiosByCourse(int courseId) {
    return _box.values
        .where((a) => a.courseId == courseId && a.estTelecharge)
        .toList();
  }

  // ─── Tout le cours est-il téléchargé ? ───────────────

  bool isCourseFullyDownloaded(int courseId) {
    final audios = _box.values
        .where((a) => a.courseId == courseId)
        .toList();

    if (audios.isEmpty) return false;

    return audios.every((a) => a.estTelecharge);
  }

  // ─── Helpers privés ──────────────────────────────────

  // Clé unique : "courseId_audioId"
  // Ex: "3_12" = audio 12 du cours 3
  String _audioKey(int courseId, int audioId) => '${courseId}_$audioId';

  List<AudioModel> _getAudiosFromCache(int courseId) {
    final audios = _box.values
        .where((a) => a.courseId == courseId)
        .toList();
    return _sortedAudios(audios);
  }

  List<AudioModel> _sortedAudios(List<AudioModel> audios) {
    audios.sort((a, b) => a.ordre.compareTo(b.ordre));
    return audios;
  }

  // Audios d'un cours depuis le cache uniquement
List<AudioModel> getAudiosFromCache(int courseId) {
  return _box.values
      .where((a) => a.courseId == courseId)
      .toList();
}
}