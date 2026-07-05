import 'package:get/get.dart';
import '../controllers/budgeting_controller.dart';

class BudgetingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BudgetingController>(
      () => BudgetingController(),
    );
  }
}
