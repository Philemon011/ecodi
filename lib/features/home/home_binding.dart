import 'package:get/get.dart';
import '../../data/providers/api_provider.dart';
import '../../data/repositories/course_repository.dart';
import 'home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {

    // ApiProvider — singleton partagé
    Get.lazyPut<ApiProvider>(
      () => ApiProvider(),
      fenix: true, // se recrée si détruit
    );

    // CourseRepository — injecte ApiProvider
    Get.lazyPut<CourseRepository>(
      () => CourseRepository(
        api: Get.find<ApiProvider>(),
      ),
      fenix: true,
    );

    // HomeController — injecte CourseRepository
    Get.lazyPut<HomeController>(
      () => HomeController(
        courseRepo: Get.find<CourseRepository>(),
      ),
    );
  }
}