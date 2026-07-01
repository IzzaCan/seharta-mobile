import 'package:get/get.dart';
import '../controllers/add_goal_controller.dart';

class AddGoalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddGoalController>(
      () => AddGoalController(),
    );
  }
}
