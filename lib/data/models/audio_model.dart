import 'package:hive/hive.dart';

part 'audio_model.g.dart';

@HiveType(typeId: 1)
class AudioModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final int courseId;

  @HiveField(2)
  final String titre;

  @HiveField(3)
  final String audioUrl;

  @HiveField(4)
  final int duree; // en secondes

  @HiveField(5)
  final int ordre;

  @HiveField(6)
  String? localPath; // chemin fichier téléchargé (null = pas téléchargé)

  AudioModel({
    required this.id,
    required this.courseId,
    required this.titre,
    required this.audioUrl,
    required this.duree,
    required this.ordre,
    this.localPath,
  });

  // Depuis JSON (réponse API Laravel)
  factory AudioModel.fromJson(Map<String, dynamic> json) {
    return AudioModel(
      id: json['id'],
      courseId: json['course_id'],
      titre: json['titre'],
      audioUrl: json['audio_url'],
      duree: json['duree'],
      ordre: json['ordre'],
    );
  }

  // Vers JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'course_id': courseId,
    'titre': titre,
    'audio_url': audioUrl,
    'duree': duree,
    'ordre': ordre,
  };

  // L'URL à utiliser : fichier local si téléchargé, sinon URL distante
  String get urlEffective => localPath ?? audioUrl;

  // Est-ce que cet audio est disponible offline ?
  bool get estTelecharge => localPath != null;

  // Durée formatée : "3min 45s" ou "1h 02min"
  String get dureeFormatee {
    final h = duree ~/ 3600;
    final m = (duree % 3600) ~/ 60;
    final s = duree % 60;
    if (h > 0) return '${h}h ${m.toString().padLeft(2, '0')}min';
    if (m > 0) return '${m}min ${s.toString().padLeft(2, '0')}s';
    return '${s}s';
  }
}