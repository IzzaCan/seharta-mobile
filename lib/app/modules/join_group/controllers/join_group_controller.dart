import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/providers/family_provider.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';

class JoinGroupController extends GetxController {
  final FamilyProvider _familyProvider = FamilyProvider();
  final AuthService _authService = Get.find<AuthService>();

  late TextEditingController codeController;
  final isLoading = false.obs;

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

  Future<void> submitCode() async {
    final code = codeController.text.trim().toUpperCase();
    if (code.length != 6) {
      Get.snackbar(
        'Validasi Gagal',
        'Masukkan kode 6-digit dengan benar',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return;
    }

    final token = _authService.accessToken.value;
    if (token.isEmpty) {
      Get.snackbar(
        'Sesi Habis',
        'Silakan masuk kembali untuk melanjutkan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return;
    }

    isLoading.value = true;
    try {
      final response = await _familyProvider.joinFamily(
        code: code,
        token: token,
      );

      // Refresh session current user agar family_id ter-update
      await _authService.checkCurrentSession();

      Get.snackbar(
        'Sukses',
        'Berhasil bergabung dengan grup keluarga!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
      );

      // Navigasi ke halaman utama
      Get.offAllNamed(Routes.HOME);
    } catch (e) {
      Get.snackbar(
        'Gagal Bergabung',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading.value = false;
    }
  }
}
