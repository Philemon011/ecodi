import 'package:hive/hive.dart';

part 'course_model.g.dart';

@HiveType(typeId: 0)
class CourseModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String titre;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String imageUrl;

  @HiveField(4)
  final int dureeTotale; // en secondes

  @HiveField(5)
  final int nombreLecons;

  @HiveField(6)
  final int ordre;

  CourseModel({
    required this.id,
    required this.titre,
    required this.description,
    required this.imageUrl,
    required this.dureeTotale,
    required this.nombreLecons,
    required this.ordre,
  });

  // Depuis JSON (réponse API Laravel)
  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'],
      titre: json['titre'],
      description: json['description'],
      imageUrl: json['image_url'],
      dureeTotale: json['duree_totale'],
      nombreLecons: json['nombre_lecons'],
      ordre: json['ordre'],
    );
  }

  // Vers JSON (si besoin)
  Map<String, dynamic> toJson() => {
    'id': id,
    'titre': titre,
    'description': description,
    'image_url': imageUrl,
    'duree_totale': dureeTotale,
    'nombre_lecons': nombreLecons,
    'ordre': ordre,
  };

  // Durée formatée : "2h 30min" ou "45min"
  String get dureeFormatee {
    final h = dureeTotale ~/ 3600;
    final m = (dureeTotale % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}min';
    return '${m}min';
  }
}