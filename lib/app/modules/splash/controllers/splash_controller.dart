import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';

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
      final prefs = await SharedPreferences.getInstance();
      final isAppLockEnabled = prefs.getBool('is_app_lock_enabled') ?? false;
      final storedPin = prefs.getString('security_pin') ?? '';

      if (isAppLockEnabled && storedPin.isNotEmpty) {
        Get.offAllNamed(Routes.PIN, arguments: {'mode': 'unlock'});
      } else {
        if (_authService.currentUser.value?.familyId != null) {
          Get.offNamed('/home');
        } else {
          Get.offNamed('/select-status');
        }
      }
    } else {
      Get.offNamed('/login');
    }
  }
}
