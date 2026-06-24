import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';

class ResetPasswordController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  late TextEditingController otpController;
  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;

  var isPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs;
  var isLoading = false.obs;
  
  String email = '';

  @override
  void onInit() {
    super.onInit();
    otpController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    
    // Mengambil argument email dari rute sebelumnya
    if (Get.arguments != null && Get.arguments is String) {
      email = Get.arguments as String;
    }
  }

  @override
  void onClose() {
    super.onClose();
  }

  void togglePasswordView() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPasswordView() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  bool _validateInput() {
    final otp = otpController.text.trim();
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (otp.isEmpty) {
      Get.snackbar('Validasi Gagal', 'Kode verifikasi tidak boleh kosong', 
          backgroundColor: const Color(0xFFFDE8E8), colorText: const Color(0xFF9B1C1C), snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
      return false;
    }

    if (newPassword.isEmpty || newPassword.length < 8) {
      Get.snackbar('Validasi Gagal', 'Password baru minimal harus 8 karakter', 
          backgroundColor: const Color(0xFFFDE8E8), colorText: const Color(0xFF9B1C1C), snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
      return false;
    }

    if (newPassword != confirmPassword) {
      Get.snackbar('Validasi Gagal', 'Konfirmasi password tidak cocok', 
          backgroundColor: const Color(0xFFFDE8E8), colorText: const Color(0xFF9B1C1C), snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
      return false;
    }

    return true;
  }

  Future<void> submitResetPassword() async {
    if (!_validateInput()) return;

    isLoading.value = true;
    try {
      await _authService.resetPassword(
        email,
        otpController.text.trim(),
        newPasswordController.text,
      );

      Get.snackbar(
        'Berhasil',
        'Password berhasil diubah. Silakan login kembali.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDEF7EC),
        colorText: const Color(0xFF03543F),
        margin: const EdgeInsets.all(16),
      );

      Get.offAllNamed(Routes.LOGIN);
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
