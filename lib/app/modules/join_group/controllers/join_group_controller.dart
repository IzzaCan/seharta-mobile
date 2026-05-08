import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
        Get.offAllNamed('/home');
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
}
