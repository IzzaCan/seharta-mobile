import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';

class OtpVerificationController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  
  late String email;
  
  // Controllers for 6 OTP digits
  final List<TextEditingController> otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  // Timer states
  var resendTimer = 60.obs;
  Timer? _timer;
  
  // Loading states
  var isVerifying = false.obs;
  var isResending = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Get email from arguments
    email = Get.arguments as String? ?? '';
    if (email.isEmpty) {
      Get.snackbar('Error', 'Email tidak ditemukan. Silakan ulangi pendaftaran.', backgroundColor: Colors.red, colorText: Colors.white);
      Get.offAllNamed(Routes.LOGIN);
    } else {
      startTimer();
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.onClose();
  }

  void startTimer() {
    resendTimer.value = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTimer.value > 0) {
        resendTimer.value--;
      } else {
        timer.cancel();
      }
    });
  }

  void onOtpChanged(String value, int index) {
    if (value.isNotEmpty) {
      // Pindah ke textfield berikutnya
      if (index < 5) {
        FocusScope.of(Get.context!).requestFocus(focusNodes[index + 1]);
      } else {
        // Jika box terakhir terisi, hilangkan keyboard
        FocusScope.of(Get.context!).unfocus();
      }
    } else {
      // Pindah ke textfield sebelumnya saat dihapus
      if (index > 0) {
        FocusScope.of(Get.context!).requestFocus(focusNodes[index - 1]);
      }
    }
  }

  Future<void> verifyOtp() async {
    String otp = otpControllers.map((c) => c.text).join();
    
    if (otp.length < 6) {
      Get.snackbar(
        'Perhatian',
        'Harap masukkan 6 digit kode OTP',
        backgroundColor: const Color(0xFFFDE8E8),
        colorText: const Color(0xFF9B1C1C),
      );
      return;
    }

    try {
      isVerifying.value = true;
      await _authService.verifyEmail(email, otp);
      
      Get.snackbar(
        'Verifikasi Berhasil',
        'Email Anda telah berhasil diverifikasi. Silakan login.',
        backgroundColor: const Color(0xFF1F9975),
        colorText: Colors.white,
      );
      
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      Get.snackbar(
        'Verifikasi Gagal',
        e.toString(),
        backgroundColor: const Color(0xFFFDE8E8),
        colorText: const Color(0xFF9B1C1C),
      );
    } finally {
      isVerifying.value = false;
    }
  }

  Future<void> resendOtp() async {
    if (resendTimer.value > 0) return;

    try {
      isResending.value = true;
      await _authService.resendVerification(email);
      
      Get.snackbar(
        'Terkirim',
        'Kode OTP baru telah dikirim ke email Anda.',
        backgroundColor: const Color(0xFF1F9975),
        colorText: Colors.white,
      );
      
      // Bersihkan input
      for (var c in otpControllers) {
        c.clear();
      }
      FocusScope.of(Get.context!).requestFocus(focusNodes[0]);
      
      startTimer();
    } catch (e) {
      Get.snackbar(
        'Gagal',
        e.toString(),
        backgroundColor: const Color(0xFFFDE8E8),
        colorText: const Color(0xFF9B1C1C),
      );
    } finally {
      isResending.value = false;
    }
  }
}
