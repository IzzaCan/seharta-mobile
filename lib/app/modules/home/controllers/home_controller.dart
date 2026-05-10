import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class HomeController extends GetxController {
  // State untuk Bottom Navigation Bar
  var currentIndex = 0.obs;

  // State untuk menyembunyikan/menampilkan nominal aset
  var isAssetVisible = true.obs;

  void changePage(int index) {
    currentIndex.value = index;
    switch (index) {
      case 0:
        Get.offAllNamed(Routes.HOME);
        break;
      case 1:
        Get.offAllNamed(Routes.HARTA);
        break;
      case 2:
        Get.offAllNamed(Routes.ANALYTICS);
        break;
      case 3:
        Get.offAllNamed(Routes.PROFILE);
        break;
    }
  }

  void toggleAssetVisibility() {
    isAssetVisible.value = !isAssetVisible.value;
  }
}
