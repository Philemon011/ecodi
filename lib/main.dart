import 'package:ecodi/services/download_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:audio_service/audio_service.dart';

import 'core/theme/app_theme.dart';
import 'data/models/course_model.dart';
import 'data/models/audio_model.dart';
import 'data/models/progress_model.dart';
import 'features/main/main_screen.dart';
import 'features/player/player_controller.dart';
import 'routes/app_pages.dart';
import 'services/audio_handler.dart';
import 'services/progress_service.dart';

late EcodiAudioHandler audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('✅ 1. Flutter initialisé');

  // 1. Init Hive
  await Hive.initFlutter();
  debugPrint('✅ 2. Hive initialisé');

  Hive.registerAdapter(CourseModelAdapter());
  Hive.registerAdapter(AudioModelAdapter());
  Hive.registerAdapter(ProgressModelAdapter());
  debugPrint('✅ 3. Adapters enregistrés');

  // 2. Ouvrir les boxes
  await Hive.openBox<CourseModel>('coursesBox');
  await Hive.openBox<AudioModel>('audiosBox');
  await Hive.openBox<ProgressModel>('progressBox');
  await Hive.openBox('favoritesBox');
  await Hive.openBox('historyBox');
  await Hive.openBox('downloadsBox');
  debugPrint('✅ 4. Boxes Hive ouvertes');

  // 3. Init audio_service avec timeout
debugPrint('⏳ 5. Démarrage AudioService...');
try {
  audioHandler = await AudioService.init(
    builder: () => EcodiAudioHandler(),
    config:  AudioServiceConfig(
      androidNotificationChannelId: 'com.ecodi.audio',
      androidNotificationChannelName: 'Ecodi Audio',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: false,
    ),
  ).timeout(
    const Duration(seconds: 5),
    onTimeout: () {
      debugPrint('⚠️ AudioService timeout — init sans audio');
      return EcodiAudioHandler();
    },
  );
  debugPrint('✅ 6. AudioService initialisé');
} catch (e) {
  debugPrint('⚠️ AudioService erreur : $e');
  audioHandler = EcodiAudioHandler();
}
  debugPrint('✅ 6. AudioService initialisé');

  // 4. Services globaux
  Get.put(ProgressService());
  Get.put(PlayerController(), permanent: true);
  debugPrint('✅ 7. Services injectés');

  Get.put(DownloadService());

  runApp(const EcodiApp());
  debugPrint('✅ 8. App lancée');
}

class EcodiApp extends StatelessWidget {
  const EcodiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Ecodi',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
      getPages: AppPages.routes,
    );
  }
}