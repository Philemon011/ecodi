import 'package:hive/hive.dart';

part 'progress_model.g.dart';

@HiveType(typeId: 2)
class ProgressModel extends HiveObject {
  @HiveField(0)
  final int courseId;

  @HiveField(1)
  int audioId;

  @HiveField(2)
  double position; // en secondes

  @HiveField(3)
  double dureeAudio; // en secondes (pour calculer le %)

  @HiveField(4)
  bool termine;

  @HiveField(5)
  DateTime derniereLecture;

  ProgressModel({
    required this.courseId,
    required this.audioId,
    required this.position,
    required this.dureeAudio,
    this.termine = false,
    required this.derniereLecture,
  });

  // Pourcentage de progression de cet audio (0.0 → 1.0)
  double get pourcentageAudio {
    if (dureeAudio <= 0) return 0.0;
    final p = position / dureeAudio;
    return p.clamp(0.0, 1.0);
  }

  // Considéré terminé si > 90% écouté
  bool get estTermine => termine || pourcentageAudio >= 0.90;

  // Mise à jour de la position (appelée toutes les 4 secondes)
  void mettreAJour({
    required double nouvellePosition,
    required int nouvelAudioId,
  }) {
    audioId = nouvelAudioId;
    position = nouvellePosition;
    derniereLecture = DateTime.now();
    if (pourcentageAudio >= 0.90) termine = true;
    save(); // Hive persiste automatiquement
  }

  // Depuis JSON (si besoin de sérialiser)
  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    return ProgressModel(
      courseId: json['course_id'],
      audioId: json['audio_id'],
      position: (json['position'] as num).toDouble(),
      dureeAudio: (json['duree_audio'] as num).toDouble(),
      termine: json['termine'] ?? false,
      derniereLecture: DateTime.parse(json['derniere_lecture']),
    );
  }

  Map<String, dynamic> toJson() => {
    'course_id': courseId,
    'audio_id': audioId,
    'position': position,
    'duree_audio': dureeAudio,
    'termine': termine,
    'derniere_lecture': derniereLecture.toIso8601String(),
  };
}