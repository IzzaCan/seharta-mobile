import 'package:get/get.dart';

import '../controllers/harta_controller.dart';

class HartaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HartaController>(
      () => HartaController(),
    );
  }
}
