import 'package:get/get.dart';
import '../../data/local/hive_service.dart';
import '../../data/models/audio_model.dart';
import '../../data/models/course_model.dart';
import '../../data/repositories/audio_repository.dart';
import '../../data/repositories/course_repository.dart';

class HistoryEntry {
  final AudioModel audio;
  final CourseModel course;
  final DateTime date;
  final double progression;

  HistoryEntry({
    required this.audio,
    required this.course,
    required this.date,
    required this.progression,
  });

  // Date formatée lisible
  String get dateFormatee {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} jours';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class HistoryController extends GetxController {
  final AudioRepository _audioRepo;
  final CourseRepository _courseRepo;

  HistoryController({
    AudioRepository? audioRepo,
    CourseRepository? courseRepo,
  })  : _audioRepo = audioRepo ?? AudioRepository(),
        _courseRepo = courseRepo ?? CourseRepository();

  // ─── State ───────────────────────────────────────────
  final RxList<HistoryEntry> entries = <HistoryEntry>[].obs;
  final RxBool isLoading = true.obs;

  // ─── Lifecycle ───────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  // ─── Charger l'historique ─────────────────────────────
  Future<void> loadHistory() async {
    try {
      isLoading.value = true;

      final history = HiveService.getHistory();
      final result = <HistoryEntry>[];

      // Parcourir en ordre inverse (plus récent en premier)
      for (final entry in history.reversed) {
        final courseId = entry['course_id'] as int?;
        final audioId = entry['audio_id'] as int?;
        final dateStr = entry['date'] as String?;

        if (courseId == null || audioId == null) continue;

        // Récupérer le cours
        final course = await _courseRepo.getCourse(courseId);
        if (course == null) continue;

        // Récupérer l'audio
        final audio = _audioRepo.getAudioFromBox(audioId);
        if (audio == null) continue;

        // Progression
        final progress = HiveService.getProgress(courseId);
        final progression = progress?.pourcentageAudio ?? 0.0;

        // Date
        final date = dateStr != null
            ? DateTime.tryParse(dateStr) ?? DateTime.now()
            : DateTime.now();

        result.add(HistoryEntry(
          audio: audio,
          course: course,
          date: date,
          progression: progression,
        ));
      }

      entries.assignAll(result);

    } finally {
      isLoading.value = false;
    }
  }

  // ─── Effacer l'historique ─────────────────────────────
  Future<void> clearHistory() async {
    await HiveService.clearHistory();
    entries.clear();
  }

  // ─── Navigation vers le lecteur ──────────────────────
  void playEntry(HistoryEntry entry) {
    Get.toNamed(
      '/player',
      arguments: {
        'course': entry.course,
        'audio': entry.audio,
        'playlist': [entry.audio],
      },
    );
  }

  // ─── Navigation vers le cours ─────────────────────────
  void goToCourse(HistoryEntry entry) {
    Get.toNamed(
      '/course/${entry.course.id}',
      arguments: entry.course,
    );
  }

  // ─── Refresh ─────────────────────────────────────────
  Future<void> refresh() => loadHistory();
}