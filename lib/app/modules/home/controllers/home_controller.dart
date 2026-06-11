import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../data/services/family_service.dart';
import '../../../data/services/auth_service.dart';

class HomeController extends GetxController {
  final FamilyService _familyService = Get.find<FamilyService>();
  final AuthService _authService = Get.find<AuthService>();
  
  RxString get familyName => _familyService.familyName;
  String? get avatarUrl => _authService.currentUser.value?.avatarUrl;

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
