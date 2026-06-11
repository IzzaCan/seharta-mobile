import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/family_service.dart';

class EditFamilyNameController extends GetxController {
  late TextEditingController familyNameController;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Inisialisasi dengan nama keluarga saat ini
    final currentName = FamilyService.to.familyName.value;
    familyNameController = TextEditingController(text: currentName);
  }

  @override
  void onClose() {
    familyNameController.dispose();
    super.onClose();
  }

  Future<void> saveChanges() async {
    if (familyNameController.text.isEmpty) return;
    
    try {
      isLoading.value = true;
      await FamilyService.to.updateFamilyName(familyNameController.text);
      
      Get.back();
      Get.snackbar(
        "Berhasil",
        "Nama keluarga Anda telah diperbarui.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF1F9975),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Gagal",
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
