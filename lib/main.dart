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

  // 1. Init Hive
  await Hive.initFlutter();
  Hive.registerAdapter(CourseModelAdapter());
  Hive.registerAdapter(AudioModelAdapter());
  Hive.registerAdapter(ProgressModelAdapter());

  // 2. Boxes
  await Hive.openBox<CourseModel>('coursesBox');
  await Hive.openBox<AudioModel>('audiosBox');
  await Hive.openBox<ProgressModel>('progressBox');
  await Hive.openBox('favoritesBox');
  await Hive.openBox('historyBox');
  await Hive.openBox('downloadsBox');

  // 3. Services
  Get.put(ProgressService());
  Get.put(PlayerController(), permanent: true);
  Get.put(DownloadService());

  runApp(const EcodiApp());
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