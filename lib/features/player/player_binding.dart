import 'package:get/get.dart';
import 'player_controller.dart';

class PlayerBinding extends Bindings {
  @override
  void dependencies() {
    // PlayerController est permanent — déjà instancié dans main.dart
    // On vérifie juste qu'il existe, sinon on le crée
    if (!Get.isRegistered<PlayerController>()) {
      Get.put(PlayerController(), permanent: true);
    }
  }
}