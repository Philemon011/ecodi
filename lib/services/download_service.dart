import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../core/constants/app_enums.dart';
import '../data/local/hive_service.dart';
import '../data/models/audio_model.dart';
import '../data/repositories/audio_repository.dart';

class DownloadTask {
  final int audioId;
  final int courseId;
  final String titre;
  final RxDouble progress;
  final Rx<DownloadStatus> status;
  CancelToken? cancelToken;

  DownloadTask({
    required this.audioId,
    required this.courseId,
    required this.titre,
  })  : progress = 0.0.obs,
        status = DownloadStatus.notDownloaded.obs;
}

class DownloadService extends GetxService {
  final Dio _dio = Dio();
  final AudioRepository _audioRepo;

  // Tâches actives
  final RxMap<int, DownloadTask> activeTasks =
      <int, DownloadTask>{}.obs;

  DownloadService({AudioRepository? audioRepo})
      : _audioRepo = audioRepo ?? AudioRepository();

  // ─── Télécharger un audio ─────────────────────────────
  Future<void> downloadAudio(AudioModel audio) async {
    // Déjà téléchargé
    if (HiveService.isDownloaded(audio.id)) return;

    // Déjà en cours
    if (activeTasks.containsKey(audio.id)) return;

    // Créer la tâche
    final task = DownloadTask(
      audioId: audio.id,
      courseId: audio.courseId,
      titre: audio.titre,
    );
    activeTasks[audio.id] = task;
    task.status.value = DownloadStatus.downloading;

    try {
      // Dossier de destination
      final dir = await _getDownloadDir();
      final fileName = 'audio_${audio.id}.mp3';
      final filePath = '${dir.path}/$fileName';

      // Téléchargement avec progression
      task.cancelToken = CancelToken();

      await _dio.download(
        audio.audioUrl,
        filePath,
        cancelToken: task.cancelToken,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            task.progress.value = received / total;
          }
        },
      );

      // Calculer la taille
      final file = File(filePath);
      final sizeMb = file.lengthSync() / (1024 * 1024);

      // Sauvegarder dans Hive
      await HiveService.saveDownload(
        audioId: audio.id,
        path: filePath,
        sizeMb: sizeMb,
      );

      // Mettre à jour le repo
      await _audioRepo.setLocalPath(
        audio.courseId,
        audio.id,
        filePath,
      );

      task.status.value = DownloadStatus.downloaded;
      task.progress.value = 1.0;

    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        task.status.value = DownloadStatus.notDownloaded;
      } else {
        task.status.value = DownloadStatus.error;
      }
    } catch (e) {
      task.status.value = DownloadStatus.error;
    } finally {
      // Retirer la tâche active après 2s
      await Future.delayed(const Duration(seconds: 2));
      activeTasks.remove(audio.id);
    }
  }

  // ─── Télécharger un cours complet ─────────────────────
  Future<void> downloadCourse(
    int courseId,
    List<AudioModel> audios,
  ) async {
    for (final audio in audios) {
      if (!HiveService.isDownloaded(audio.id)) {
        await downloadAudio(audio);
      }
    }
  }

  // ─── Annuler un téléchargement ────────────────────────
  void cancelDownload(int audioId) {
    final task = activeTasks[audioId];
    task?.cancelToken?.cancel('Annulé par l\'utilisateur');
    activeTasks.remove(audioId);
  }

  // ─── Supprimer un téléchargement ──────────────────────
  Future<void> deleteDownload(int audioId) async {
    final path = HiveService.getLocalPath(audioId);

    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }

    await HiveService.removeDownload(audioId);
  }

  // ─── Statut d'un audio ────────────────────────────────
  DownloadStatus getStatus(int audioId) {
    if (activeTasks.containsKey(audioId)) {
      return activeTasks[audioId]!.status.value;
    }
    if (HiveService.isDownloaded(audioId)) {
      return DownloadStatus.downloaded;
    }
    return DownloadStatus.notDownloaded;
  }

  // ─── Progression d'un audio ───────────────────────────
  double getProgress(int audioId) {
    return activeTasks[audioId]?.progress.value ?? 0.0;
  }

  // ─── Taille totale téléchargée ────────────────────────
  double getTotalSizeMb() {
    final downloads = HiveService.getAllDownloads();
    return downloads.fold(
      0.0,
      (sum, d) => sum + ((d['size_mb'] as num?)?.toDouble() ?? 0.0),
    );
  }

  // ─── Dossier de téléchargement ────────────────────────
  Future<Directory> _getDownloadDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${appDir.path}/ecodi_audios');
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }
    return downloadDir;
  }
}