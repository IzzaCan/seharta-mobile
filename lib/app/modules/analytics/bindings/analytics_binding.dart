  import 'package:get/get.dart';

  import '../controllers/analytics_controller.dart';
  import '../../harta/controllers/gold_controller.dart';

  class AnalyticsBinding extends Bindings {
    @override
    void dependencies() {
      // Register GoldController if not already registered (shared across pages)
      if (!Get.isRegistered<GoldController>()) {
        Get.put<GoldController>(
          GoldController(),
          permanent: true,
        );
      }
      Get.lazyPut<AnalyticsController>(
        () => AnalyticsController(),
      );
    }
  }
