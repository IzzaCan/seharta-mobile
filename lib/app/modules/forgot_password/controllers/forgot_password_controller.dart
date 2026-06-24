import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';

class ForgotPasswordController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  late TextEditingController emailController;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
  }

  @override
  void onClose() {
    super.onClose();
  }

  bool _validateInput() {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      Get.snackbar(
        'Validasi Gagal',
        'Alamat email tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFDE8E8),
        colorText: const Color(0xFF9B1C1C),
        margin: const EdgeInsets.all(16),
      );
      return false;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        'Validasi Gagal',
        'Format email tidak valid',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFDE8E8),
        colorText: const Color(0xFF9B1C1C),
        margin: const EdgeInsets.all(16),
      );
      return false;
    }

    return true;
  }

  Future<void> sendResetCode() async {
    if (!_validateInput()) return;

    final email = emailController.text.trim();
    isLoading.value = true;

    try {
      await _authService.forgotPassword(email);

      Get.snackbar(
        'Kode Terkirim',
        'Silakan periksa kotak masuk email Anda.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDEF7EC),
        colorText: const Color(0xFF03543F),
        margin: const EdgeInsets.all(16),
      );

      Get.toNamed(Routes.RESET_PASSWORD, arguments: email);
    } catch (e) {
      Get.snackbar(
        'Gagal',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFDE8E8),
        colorText: const Color(0xFF9B1C1C),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
