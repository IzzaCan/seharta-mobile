import 'package:get/get.dart';

import '../controllers/manage_wallets_controller.dart';

class ManageWalletsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManageWalletsController>(
      () => ManageWalletsController(),
    );
  }
}
