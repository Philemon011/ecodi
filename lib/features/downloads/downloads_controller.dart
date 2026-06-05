import 'package:get/get.dart';
import '../../core/constants/app_enums.dart';
import '../../data/local/hive_service.dart';
import '../../data/models/audio_model.dart';
import '../../data/repositories/audio_repository.dart';
import '../../services/download_service.dart';

class DownloadedItem {
  final AudioModel audio;
  final double sizeMb;
  final DateTime date;

  DownloadedItem({
    required this.audio,
    required this.sizeMb,
    required this.date,
  });
}

class DownloadsController extends GetxController {
  final DownloadService _downloadService;
  final AudioRepository _audioRepo;

  DownloadsController({
    DownloadService? downloadService,
    AudioRepository? audioRepo,
  })  : _downloadService = downloadService ?? DownloadService(),
        _audioRepo = audioRepo ?? AudioRepository();

  // ─── State ───────────────────────────────────────────
  final RxList<DownloadedItem> downloadedItems =
      <DownloadedItem>[].obs;
  final RxBool isLoading = true.obs;
  final RxDouble totalSizeMb = 0.0.obs;

  // ─── Lifecycle ───────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    loadDownloads();
  }

  // ─── Charger les téléchargements ──────────────────────
  Future<void> loadDownloads() async {
    try {
      isLoading.value = true;

      final downloads = HiveService.getAllDownloads();
      final items = <DownloadedItem>[];

      for (final dl in downloads) {
        final audioId = dl['audio_id'] as int?;
        if (audioId == null) continue;

        // Récupérer l'audio depuis Hive
        final audio = _audioRepo.getAudioFromBox(audioId);
        if (audio == null) continue;

        items.add(DownloadedItem(
          audio: audio,
          sizeMb: (dl['size_mb'] as num?)?.toDouble() ?? 0.0,
          date: DateTime.tryParse(
                dl['date'] as String? ?? '',
              ) ??
              DateTime.now(),
        ));
      }

      // Trier par date décroissante
      items.sort((a, b) => b.date.compareTo(a.date));
      downloadedItems.assignAll(items);

      // Taille totale
      totalSizeMb.value = _downloadService.getTotalSizeMb();

    } finally {
      isLoading.value = false;
    }
  }

  // ─── Supprimer un téléchargement ──────────────────────
  Future<void> deleteDownload(DownloadedItem item) async {
    await _downloadService.deleteDownload(item.audio.id);
    downloadedItems.remove(item);
    totalSizeMb.value = _downloadService.getTotalSizeMb();
  }

  // ─── Tout supprimer ───────────────────────────────────
  Future<void> deleteAll() async {
    for (final item in List.from(downloadedItems)) {
      await _downloadService.deleteDownload(item.audio.id);
    }
    downloadedItems.clear();
    totalSizeMb.value = 0.0;
  }

  // ─── Statut d'un audio ────────────────────────────────
  DownloadStatus getStatus(int audioId) =>
      _downloadService.getStatus(audioId);

  // ─── Taille formatée ─────────────────────────────────
  String formatSize(double mb) {
    if (mb < 1) return '${(mb * 1024).toStringAsFixed(0)} KB';
    if (mb < 1024) return '${mb.toStringAsFixed(1)} MB';
    return '${(mb / 1024).toStringAsFixed(2)} GB';
  }

  // ─── Refresh ─────────────────────────────────────────
  Future<void> refresh() => loadDownloads();
}