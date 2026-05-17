import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';

class RegisterController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isPasswordHidden = true.obs;
  final isConfirmPasswordHidden = true.obs;
  
  // Loading state untuk tombol daftar
  var isLoading = false.obs;

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  // Validasi Input
  bool _validateInput() {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (name.isEmpty) {
      Get.snackbar(
        'Validasi Gagal',
        'Nama lengkap tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFDE8E8),
        colorText: const Color(0xFF9B1C1C),
        margin: const EdgeInsets.all(16),
      );
      return false;
    }

    if (name.length < 3) {
      Get.snackbar(
        'Validasi Gagal',
        'Nama lengkap minimal harus terdiri dari 3 karakter',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFDE8E8),
        colorText: const Color(0xFF9B1C1C),
        margin: const EdgeInsets.all(16),
      );
      return false;
    }

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

    if (password.isEmpty) {
      Get.snackbar(
        'Validasi Gagal',
        'Kata sandi tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFDE8E8),
        colorText: const Color(0xFF9B1C1C),
        margin: const EdgeInsets.all(16),
      );
      return false;
    }

    if (password.length < 8) {
      Get.snackbar(
        'Validasi Gagal',
        'Kata sandi minimal harus terdiri dari 8 karakter',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFDE8E8),
        colorText: const Color(0xFF9B1C1C),
        margin: const EdgeInsets.all(16),
      );
      return false;
    }

    if (confirmPassword != password) {
      Get.snackbar(
        'Validasi Gagal',
        'Konfirmasi kata sandi tidak cocok',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFDE8E8),
        colorText: const Color(0xFF9B1C1C),
        margin: const EdgeInsets.all(16),
      );
      return false;
    }

    return true;
  }

  // Aksi Register ke Backend
  Future<void> register() async {
    if (!_validateInput()) return;

    isLoading.value = true;
    try {
      await _authService.register(
        nameController.text.trim(),
        emailController.text.trim(),
        passwordController.text,
      );

      Get.snackbar(
        'Pendaftaran Berhasil',
        'Akun Anda berhasil dibuat. Selamat bergabung, ${nameController.text.trim()}!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDEF7EC),
        colorText: const Color(0xFF03543F),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      );

      // Setelah berhasil mendaftar, langsung arahkan ke select-status karena token login sudah didapatkan
      Get.offAllNamed('/select-status');
    } catch (e) {
      Get.snackbar(
        'Pendaftaran Gagal',
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
