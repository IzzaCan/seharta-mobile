import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../routes/app_pages.dart';
import '../../../data/services/family_service.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/user_model.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'dart:typed_data';
import '../views/widgets/image_calibration_dialog.dart';

class ProfileController extends GetxController {
  final FamilyService _familyService = Get.find<FamilyService>();
  final AuthService _authService = Get.find<AuthService>();
  
  RxString get familyName => _familyService.familyName;
  Rx<UserModel?> get currentUser => _authService.currentUser;
  String? get avatarUrl => currentUser.value?.avatarUrl;
  
  String? get partnerName => _familyService.partner?.fullName;
  String? get partnerAvatarUrl => _familyService.partner?.avatarUrl;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    isAppLockOn.value = prefs.getBool('is_app_lock_enabled') ?? false;
  }

  Future<void> pickProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      try {
        final bytes = await pickedFile.readAsBytes();
        
        final GlobalKey cropperKey = GlobalKey();
        final RxBool isUploading = false.obs;

        Get.dialog(
          ImageCalibrationDialog(
            imageBytes: bytes,
            cropperKey: cropperKey,
            isLoading: isUploading,
            onApply: () async {
              try {
                isUploading.value = true;
                
                // Ambil gambar yang di-crop dari RepaintBoundary
                RenderRepaintBoundary boundary = cropperKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
                ui.Image image = await boundary.toImage(pixelRatio: 2.0); // Resolusi lebih tinggi
                ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
                
                if (byteData != null) {
                  final croppedBytes = byteData.buffer.asUint8List();
                  
                  // Gunakan API upload dari AuthService
                  await _authService.uploadAvatar(croppedBytes, 'profile.png');
                  
                  Get.back(); // Tutup dialog kalibrasi
                  Get.snackbar('Berhasil', 'Foto profil berhasil diperbarui', backgroundColor: const Color(0xFF1F9975), colorText: Colors.white);
                } else {
                  throw 'Gagal mengekstrak data gambar';
                }
              } catch (e) {
                Get.snackbar('Gagal', 'Gagal memproses foto: $e', backgroundColor: Colors.red, colorText: Colors.white);
              } finally {
                isUploading.value = false;
              }
            },
          ),
          barrierDismissible: false,
        );
      } catch (e) {
        Get.snackbar('Gagal', 'Gagal memuat foto: $e', backgroundColor: Colors.red, colorText: Colors.white);
      }
    }
  }

  void showSettingsBottomSheet() {
    final nameController = TextEditingController(text: currentUser.value?.fullName ?? '');
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final isLoading = false.obs;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pengaturan Profil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
              ),
              const SizedBox(height: 16),
              const Text('Ganti Password (Opsional)', style: TextStyle(fontWeight: FontWeight.bold)),
              TextField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password Lama'),
              ),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password Baru'),
              ),
              const SizedBox(height: 24),
              Obx(() => SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D2B33),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isLoading.value ? null : () async {
                    try {
                      isLoading.value = true;
                      if (nameController.text != currentUser.value?.fullName && nameController.text.isNotEmpty) {
                        await _authService.updateProfile(nameController.text);
                      }
                      if (oldPasswordController.text.isNotEmpty && newPasswordController.text.isNotEmpty) {
                        await _authService.updatePassword(oldPasswordController.text, newPasswordController.text);
                      }
                      Get.back();
                      Get.snackbar('Berhasil', 'Profil berhasil diperbarui', backgroundColor: const Color(0xFF1F9975), colorText: Colors.white);
                    } catch (e) {
                      Get.snackbar('Gagal', e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
                    } finally {
                      isLoading.value = false;
                    }
                  },
                  child: isLoading.value 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                      : const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  // State untuk Switch (Toggle)
  var isNotificationOn = true.obs;
  var isAppLockOn = false.obs;

  // Fungsi toggle
  void toggleNotification(bool value) {
    isNotificationOn.value = value;
  }

  void toggleAppLock(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final storedPin = prefs.getString('security_pin') ?? '';
    
    if (value) {
      if (storedPin.isEmpty) {
        // No PIN registered yet, redirect to CHANGE_PIN
        Get.snackbar(
          'Buat PIN', 
          'Silakan buat PIN keamanan Anda terlebih dahulu', 
          backgroundColor: Colors.orange[100], 
          colorText: Colors.orange[900]
        );
        Get.toNamed(Routes.PIN);
        isAppLockOn.value = false;
      } else {
        isAppLockOn.value = true;
        await prefs.setBool('is_app_lock_enabled', true);
      }
    } else {
      isAppLockOn.value = false;
      await prefs.setBool('is_app_lock_enabled', false);
    }
  }

  // Aksi navigasi & aksi khusus
  void showPairingCode() {
    print("Tampilkan Modal QR Code");
  }

  void unpairAccount() {
    print("Putuskan Tautan (Tampilkan Pop-up Peringatan)");
  }

  void logout() {
    // Navigasi ke Login dan hapus seluruh history navigasi
    Get.offAllNamed(Routes.LOGIN);
  }

  Future<void> refreshProfile() async {
    await Future.wait([
      _authService.checkCurrentSession(),
      _familyService.fetchFamilyInfo(),
    ]);
  }
}
