import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class CreateGroupController extends GetxController {
  // Mock pairing code
  final pairingCode = 'X7B92K'.obs;

  void copyCode() {
    Clipboard.setData(ClipboardData(text: pairingCode.value));
    Get.snackbar(
      'Berhasil',
      'Kode berhasil disalin ke clipboard',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void goToHome() {
    print("Navigating to Home...");
    Get.offAllNamed(Routes.HOME);
  }
}
