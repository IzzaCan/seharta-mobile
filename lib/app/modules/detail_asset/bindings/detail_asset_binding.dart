import 'package:get/get.dart';
import '../controllers/detail_asset_controller.dart';

class DetailAssetBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailAssetController>(
      () => DetailAssetController(),
    );
  }
}
