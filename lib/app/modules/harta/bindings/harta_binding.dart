import 'package:get/get.dart';

import '../controllers/harta_controller.dart';
import '../controllers/gold_controller.dart';

class HartaBinding extends Bindings {
  @override
  void dependencies() {
    // GoldController must be registered first and kept permanent for other tabs
    if (!Get.isRegistered<GoldController>()) {
      Get.put<GoldController>(GoldController(), permanent: true);
    }
    Get.lazyPut<HartaController>(
      () => HartaController(),
    );
  }
}
