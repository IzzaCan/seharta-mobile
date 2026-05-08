import 'package:get/get.dart';
import '../controllers/select_status_controller.dart';

class SelectStatusBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SelectStatusController>(
      () => SelectStatusController(),
    );
  }
}
