import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';

class SplashController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    
    if (_authService.isLoggedIn) {
      if (_authService.currentUser.value?.familyId != null) {
        Get.offNamed('/home');
      } else {
        Get.offNamed('/select-status');
      }
    } else {
      Get.offNamed('/login');
    }
  }
}
