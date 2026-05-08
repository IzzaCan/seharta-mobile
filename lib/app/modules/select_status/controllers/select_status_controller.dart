import 'package:get/get.dart';

class SelectStatusController extends GetxController {
  void createNewGroup() {
    Get.toNamed('/create-group');
  }

  void joinGroup() {
    Get.toNamed('/join-group');
  }
}
