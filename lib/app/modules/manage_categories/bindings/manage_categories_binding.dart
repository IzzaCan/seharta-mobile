import 'package:get/get.dart';

import '../controllers/manage_categories_controller.dart';

class ManageCategoriesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManageCategoriesController>(
      () => ManageCategoriesController(),
    );
  }
}
