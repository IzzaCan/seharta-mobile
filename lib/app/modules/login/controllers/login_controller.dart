import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';

class LoginController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  // Controller untuk text field
  late TextEditingController emailController;
  late TextEditingController passwordController;

  // Obscure text untuk password
  var isPasswordHidden = true.obs;
  
  // Loading state untuk tombol login
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Default testing email bisa dikosongkan agar lebih bersih untuk user
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordView() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  // Validasi Input
  bool _validateInput() {
    final email = emailController.text.trim();
    final password = passwordController.text;

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

    return true;
  }

  // Aksi Login ke Backend
  Future<void> login() async {
    if (!_validateInput()) return;

    isLoading.value = true;
    try {
      await _authService.login(
        emailController.text.trim(),
        passwordController.text,
      );

      Get.snackbar(
        'Berhasil',
        'Selamat Datang Kembali, ${_authService.currentUser.value?.fullName ?? "Pengguna"}!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDEF7EC),
        colorText: const Color(0xFF03543F),
        margin: const EdgeInsets.all(16),
      );

      // Arahkan ke select-status
      Get.offNamed('/select-status');
    } catch (e) {
      Get.snackbar(
        'Login Gagal',
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
