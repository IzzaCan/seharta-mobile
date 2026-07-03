import 'package:get/get.dart';

import '../controllers/add_asset_controller.dart';

class AddAssetBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddAssetController>(
      () => AddAssetController(),
    );
  }
}
