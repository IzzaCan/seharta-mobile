import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';

enum PinStep { verifyCurrent, enterNew, confirmNew }

class PinController extends GetxController {
  late SharedPreferences _prefs;
  
  var step = PinStep.verifyCurrent.obs;
  var currentPin = ''.obs; 
  
  var storedPin = ''.obs;
  var newPin = ''.obs; 
  
  var isInitialized = false.obs;
  var isUnlockMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments['mode'] == 'unlock') {
      isUnlockMode.value = true;
    }
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    storedPin.value = _prefs.getString('security_pin') ?? '';
    
    if (storedPin.value.isEmpty) {
      // If somehow in unlock mode but no pin exists, unlock and go home
      if (isUnlockMode.value) {
        _goToInitialScreen();
        return;
      }
      step.value = PinStep.enterNew;
    } else {
      step.value = PinStep.verifyCurrent;
    }
    isInitialized.value = true;
  }

  void addDigit(String digit) {
    if (currentPin.value.length < 6) {
      currentPin.value += digit;
    }

    if (currentPin.value.length == 6) {
      Future.delayed(const Duration(milliseconds: 150), () {
        _processStep();
      });
    }
  }

  void removeDigit() {
    if (currentPin.value.isNotEmpty) {
      currentPin.value = currentPin.value.substring(0, currentPin.value.length - 1);
    }
  }

  void _processStep() {
    switch (step.value) {
      case PinStep.verifyCurrent:
        if (currentPin.value == storedPin.value) {
          if (isUnlockMode.value) {
            _goToInitialScreen();
          } else {
            step.value = PinStep.enterNew;
            currentPin.value = '';
            Get.snackbar('Berhasil', 'PIN saat ini terverifikasi', backgroundColor: Colors.green[100], colorText: Colors.green[900]);
          }
        } else {
          currentPin.value = '';
          Get.snackbar('Gagal', 'PIN saat ini salah', backgroundColor: Colors.red[100], colorText: Colors.red[900]);
        }
        break;
        
      case PinStep.enterNew:
        newPin.value = currentPin.value;
        step.value = PinStep.confirmNew;
        currentPin.value = '';
        break;
        
      case PinStep.confirmNew:
        if (currentPin.value == newPin.value) {
          _prefs.setString('security_pin', currentPin.value);
          _prefs.setBool('is_app_lock_enabled', true);
          if (Get.isRegistered<ProfileController>()) {
            final profileCtrl = Get.find<ProfileController>();
            profileCtrl.isAppLockOn = true;
            profileCtrl.update();
          }
          Get.back(); // close page first
          Get.snackbar('Berhasil', 'PIN keamanan berhasil diperbarui', backgroundColor: Colors.green[100], colorText: Colors.green[900]);
        } else {
          currentPin.value = '';
          step.value = PinStep.enterNew;
          Get.snackbar('Gagal', 'Konfirmasi PIN tidak cocok. Silakan ulangi.', backgroundColor: Colors.red[100], colorText: Colors.red[900]);
        }
        break;
    }
  }

  void _goToInitialScreen() {
    final authService = Get.find<AuthService>();
    if (authService.currentUser.value?.familyId != null) {
      Get.offAllNamed(Routes.HOME);
    } else {
      Get.offAllNamed(Routes.SELECT_STATUS);
    }
  }

  void forgotPin() {
    if (isUnlockMode.value) {
      Get.defaultDialog(
        title: 'Lupa PIN',
        middleText: 'Jika Anda lupa PIN, Anda harus keluar dari akun (Logout) dan masuk kembali dengan email & password. Apakah Anda ingin keluar?',
        textConfirm: 'Keluar Akun',
        textCancel: 'Batal',
        confirmTextColor: Colors.white,
        buttonColor: const Color(0xFF0D2B33),
        onConfirm: () async {
          final authService = Get.find<AuthService>();
          await authService.clearAuthSession();
          await _prefs.remove('security_pin');
          await _prefs.remove('is_app_lock_enabled');
          Get.offAllNamed(Routes.LOGIN);
        }
      );
    } else {
      Get.defaultDialog(
        title: 'Lupa PIN',
        middleText: 'Untuk mengatur ulang PIN, Anda dapat menyetel ulang PIN saat ini. Apakah Anda yakin?',
        textConfirm: 'Reset PIN',
        textCancel: 'Batal',
        confirmTextColor: Colors.white,
        buttonColor: const Color(0xFF0D2B33),
        onConfirm: () {
          _prefs.remove('security_pin');
          storedPin.value = '';
          step.value = PinStep.enterNew;
          currentPin.value = '';
          Get.back();
          Get.snackbar('Reset', 'PIN keamanan disetel ulang. Silakan masukkan PIN baru.', backgroundColor: Colors.orange[100], colorText: Colors.orange[900]);
        }
      );
    }
  }
}
