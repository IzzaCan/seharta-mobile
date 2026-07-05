import 'package:get/get.dart';
import '../controllers/budget_detail_controller.dart';

class BudgetDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BudgetDetailController>(
      () => BudgetDetailController(),
    );
  }
}
