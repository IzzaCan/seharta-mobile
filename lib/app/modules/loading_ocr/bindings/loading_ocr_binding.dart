import 'package:get/get.dart';

import '../controllers/loading_ocr_controller.dart';

class LoadingOcrBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoadingOcrController>(
      () => LoadingOcrController(),
    );
  }
}
