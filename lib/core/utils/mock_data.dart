import '../../data/models/audio_model.dart';
import '../../data/models/course_model.dart';

class MockData {
  MockData._();

  static List<CourseModel> get courses => [
    CourseModel(
      id: 1,
      titre: 'Les Fondements de la Foi',
      description:
          'Découvrez les bases essentielles de la foi chrétienne à travers des enseignements audio clairs et profonds. Ce cours est idéal pour les nouveaux croyants comme pour ceux qui souhaitent approfondir leurs connaissances.',
      imageUrl:
          'https://images.unsplash.com/photo-1504052434569-70ad5836ab65?w=400',
      dureeTotale: 7200,
      nombreLecons: 4,
      ordre: 1,
    ),
    CourseModel(
      id: 2,
      titre: 'Le Saint-Esprit',
      description:
          'Une étude approfondie sur la personne et l\'œuvre du Saint-Esprit dans la vie du croyant. Apprenez à reconnaître sa voix et à marcher selon son guidement.',
      imageUrl:
          'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=400',
      dureeTotale: 5400,
      nombreLecons: 3,
      ordre: 2,
    ),
    CourseModel(
      id: 3,
      titre: 'La Prière',
      description:
          'Apprenez à développer une vie de prière efficace et transformatrice. Des principes pratiques pour une communion profonde avec Dieu.',
      imageUrl:
          'https://images.unsplash.com/photo-1518173946687-a4c8892bbd9f?w=400',
      dureeTotale: 3600,
      nombreLecons: 3,
      ordre: 3,
    ),
    CourseModel(
      id: 4,
      titre: 'L\'Évangile de Jean',
      description:
          'Parcourez le quatrième évangile verset par verset pour une compréhension profonde du ministère de Jésus-Christ et de son amour pour l\'humanité.',
      imageUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      dureeTotale: 10800,
      nombreLecons: 4,
      ordre: 4,
    ),
  ];

  static List<AudioModel> getAudios(int courseId) {
    switch (courseId) {
      case 1:
        return [
          AudioModel(
            id: 101,
            courseId: 1,
            titre: 'Introduction à la Foi',
            audioUrl:
                'https://sample-files.com/downloads/audio/mp3/low-bitrate-32kbps.mp3',
            duree: 180,
            ordre: 1,
          ),
          AudioModel(
            id: 102,
            courseId: 1,
            titre: 'La Foi et les Œuvres',
            audioUrl:
                'https://sample-files.com/downloads/audio/mp3/low-bitrate-32kbps.mp3',
            duree: 240,
            ordre: 2,
          ),
          AudioModel(
            id: 103,
            courseId: 1,
            titre: 'Grandir dans la Foi',
            audioUrl:
                'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
            duree: 200,
            ordre: 3,
          ),
          AudioModel(
            id: 104,
            courseId: 1,
            titre: 'La Foi victorieuse',
            audioUrl:
                'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
            duree: 220,
            ordre: 4,
          ),
        ];
      case 2:
        return [
          AudioModel(
            id: 201,
            courseId: 2,
            titre: 'Qui est le Saint-Esprit ?',
            audioUrl:
                'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
            duree: 300,
            ordre: 1,
          ),
          AudioModel(
            id: 202,
            courseId: 2,
            titre: 'Les dons du Saint-Esprit',
            audioUrl:
                'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
            duree: 280,
            ordre: 2,
          ),
          AudioModel(
            id: 203,
            courseId: 2,
            titre: 'Marcher dans l\'Esprit',
            audioUrl:
                'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',
            duree: 260,
            ordre: 3,
          ),
        ];
      case 3:
        return [
          AudioModel(
            id: 301,
            courseId: 3,
            titre: 'Pourquoi prier ?',
            audioUrl:
                'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
            duree: 190,
            ordre: 1,
          ),
          AudioModel(
            id: 302,
            courseId: 3,
            titre: 'Comment prier efficacement',
            audioUrl:
                'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3',
            duree: 210,
            ordre: 2,
          ),
          AudioModel(
            id: 303,
            courseId: 3,
            titre: 'La prière de foi',
            audioUrl:
                'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3',
            duree: 230,
            ordre: 3,
          ),
        ];
      case 4:
        return [
          AudioModel(
            id: 401,
            courseId: 4,
            titre: 'Jean chapitre 1 — Le Verbe',
            audioUrl:
                'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-11.mp3',
            duree: 350,
            ordre: 1,
          ),
          AudioModel(
            id: 402,
            courseId: 4,
            titre: 'Jean chapitre 3 — La Nouvelle Naissance',
            audioUrl:
                'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-12.mp3',
            duree: 320,
            ordre: 2,
          ),
          AudioModel(
            id: 403,
            courseId: 4,
            titre: 'Jean chapitre 11 — La Résurrection',
            audioUrl:
                'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-13.mp3',
            duree: 380,
            ordre: 3,
          ),
          AudioModel(
            id: 404,
            courseId: 4,
            titre: 'Jean chapitre 21 — Le Recommissionnement',
            audioUrl:
                'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-14.mp3',
            duree: 290,
            ordre: 4,
          ),
        ];
      default:
        return [];
    }
  }
}