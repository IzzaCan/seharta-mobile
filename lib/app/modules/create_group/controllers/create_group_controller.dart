import 'package:flutter/services.dart';
import 'package:get/get.dart';

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
    Get.offAllNamed('/home');
  }
}
