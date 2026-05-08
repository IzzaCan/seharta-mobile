import 'package:get/get.dart';

import '../controllers/family_hub_controller.dart';

class FamilyHubBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FamilyHubController>(
      () => FamilyHubController(),
    );
  }
}
