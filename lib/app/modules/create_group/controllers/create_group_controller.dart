import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../data/providers/family_provider.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';

class CreateGroupController extends GetxController {
  final FamilyProvider _familyProvider = FamilyProvider();
  final AuthService _authService = Get.find<AuthService>();

  // State observables
  final pairingCode = ''.obs;
  final isLoading = false.obs;

  // Form Controller
  late TextEditingController familyNameController;
  
  // Timer untuk polling status pairing
  Timer? _pairingTimer;

  @override
  void onInit() {
    super.onInit();
    familyNameController = TextEditingController();
  }

  @override
  void onClose() {
    familyNameController.dispose();
    _pairingTimer?.cancel();
    super.onClose();
  }

  /// Memanggil API untuk membuat keluarga baru dan men-generate PIN 6-digit.
  Future<void> createFamily() async {
    final name = familyNameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar(
        'Validasi Gagal',
        'Nama keluarga tidak boleh kosong',
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
      final response = await _familyProvider.createFamily(
        familyName: name,
        token: token,
      );

      // Ambil kode pairing dari respon server
      final code = response['code'] as String?;
      if (code != null) {
        pairingCode.value = code;
        
        // Refresh session current user agar family_id ter-update
        await _authService.checkCurrentSession();

        // Mulai polling status pairing
        _startPairingStatusCheck(code, token);

        Get.snackbar(
          'Sukses',
          'Dompet bersama berhasil dibuat! Menunggu pasangan terhubung...',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900],
        );
      } else {
        throw 'Gagal mendapatkan kode pairing dari server';
      }
    } catch (e) {
      Get.snackbar(
        'Gagal Membuat Keluarga',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Memulai timer berkala untuk memeriksa status apakah pasangan sudah memasukkan PIN.
  void _startPairingStatusCheck(String code, String token) {
    _pairingTimer?.cancel();
    _pairingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        final response = await _familyProvider.checkPairingStatus(
          code: code,
          token: token,
        );
        
        final isUsed = response['is_used'] as bool? ?? false;
        if (isUsed) {
          _pairingTimer?.cancel();
          
          // Refresh session user agar status family_id terupdate secara global
          await _authService.checkCurrentSession();
          
          Get.snackbar(
            'Pasangan Terhubung',
            'Pasangan Anda telah bergabung! Mengalihkan ke Beranda...',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green[100],
            colorText: Colors.green[900],
            duration: const Duration(seconds: 3),
          );
          
          // Mengalihkan secara otomatis ke beranda
          Get.offAllNamed(Routes.HOME);
        }
      } catch (e) {
        debugPrint("Error checking pairing status: $e");
      }
    });
  }

  void copyCode() {
    if (pairingCode.value.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: pairingCode.value));
      Get.snackbar(
        'Berhasil',
        'Kode berhasil disalin ke clipboard',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
      );
    }
  }

  void goToHome() {
    print("Navigating to Home...");
    Get.offAllNamed(Routes.HOME);
  }
}
