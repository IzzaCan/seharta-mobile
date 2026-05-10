import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class ProfileController extends GetxController {
  // State untuk Switch (Toggle)
  var isNotificationOn = true.obs;
  var isAppLockOn = false.obs;

  // Fungsi toggle
  void toggleNotification(bool value) {
    isNotificationOn.value = value;
  }

  void toggleAppLock(bool value) {
    isAppLockOn.value = value;
  }

  // Aksi navigasi & aksi khusus
  void showPairingCode() {
    print("Tampilkan Modal QR Code");
  }

  void unpairAccount() {
    print("Putuskan Tautan (Tampilkan Pop-up Peringatan)");
  }

  void logout() {
    // Navigasi ke Login dan hapus seluruh history navigasi
    Get.offAllNamed(Routes.LOGIN);
  }
}
