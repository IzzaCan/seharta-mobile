import 'package:get/get.dart';

import '../controllers/disconnect_confirmation_controller.dart';

class DisconnectConfirmationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DisconnectConfirmationController>(
      () => DisconnectConfirmationController(),
    );
  }
}
