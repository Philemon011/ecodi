import 'package:get/get.dart';
import '../../data/providers/api_provider.dart';
import '../../data/repositories/audio_repository.dart';
import 'course_detail_controller.dart';

class CourseDetailBinding extends Bindings {
  @override
  void dependencies() {

    // ApiProvider — réutilise l'existant si déjà créé
    Get.lazyPut<ApiProvider>(
      () => ApiProvider(),
      fenix: true,
    );

    // AudioRepository
    Get.lazyPut<AudioRepository>(
      () => AudioRepository(
        api: Get.find<ApiProvider>(),
      ),
      fenix: true,
    );

    // CourseDetailController
    Get.lazyPut<CourseDetailController>(
      () => CourseDetailController(
        audioRepo: Get.find<AudioRepository>(),
      ),
    );
  }
}