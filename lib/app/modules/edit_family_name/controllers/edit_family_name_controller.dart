import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditFamilyNameController extends GetxController {
  late TextEditingController familyNameController;

  @override
  void onInit() {
    super.onInit();
    // Inisialisasi dengan nama keluarga saat ini
    familyNameController = TextEditingController(text: 'Keluarga Adit & Sarah');
  }

  @override
  void onClose() {
    familyNameController.dispose();
    super.onClose();
  }

  void saveChanges() {
    print("Menyimpan nama keluarga baru: ${familyNameController.text}");
    Get.back();
    Get.snackbar(
      "Berhasil",
      "Nama keluarga Anda telah diperbarui.",
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF1F9975),
      colorText: Colors.white,
    );
  }
}
