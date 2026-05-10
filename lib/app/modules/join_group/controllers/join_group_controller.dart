import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../views/scan_qr_view.dart';

class JoinGroupController extends GetxController {
  late TextEditingController codeController;

  @override
  void onInit() {
    super.onInit();
    codeController = TextEditingController();
  }

  @override
  void onClose() {
    codeController.dispose();
    super.onClose();
  }

  void submitCode() {
    if (codeController.text.length >= 6) {
      Get.snackbar(
        'Berhasil',
        'Bergabung dengan grup...',
        snackPosition: SnackPosition.BOTTOM,
      );
      // Navigate to home after brief delay
      Future.delayed(const Duration(seconds: 1), () {
        Get.offAllNamed(Routes.HOME);
      });
    } else {
      Get.snackbar(
        'Error',
        'Masukkan kode 6-digit dengan benar',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  void scanQR() async {
    final result = await Get.to(() => const ScanQrView());
    if (result != null && result is String) {
      codeController.text = result;
      Get.snackbar(
        'Berhasil',
        'Kode QR berhasil di-scan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
      );
    }
  }
}
