import 'package:get/get.dart';
import '../controllers/join_group_controller.dart';

class JoinGroupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JoinGroupController>(
      () => JoinGroupController(),
    );
  }
}
