import 'package:get/get.dart';

import '../controllers/add_asset_controller.dart';
import '../../harta/controllers/gold_controller.dart';

class AddAssetBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<GoldController>()) {
      Get.put<GoldController>(GoldController(), permanent: true);
    }
    Get.lazyPut<AddAssetController>(
      () => AddAssetController(),
    );
  }
}
