import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class AddTransactionController extends GetxController {
  // State untuk Tab Pengeluaran vs Pemasukan (True = Pengeluaran)
  var isExpense = true.obs;

  // Controller untuk Text Input
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  // State untuk Dropdown/Pilihan (Bisa diubah nantinya sesuai model database)
  var selectedCategory = 'Makan'.obs;
  var selectedWallet = 'BCA Keluarga'.obs;

  void toggleTransactionType(bool isExpenseType) {
    isExpense.value = isExpenseType;
  }

  Future<void> openOcrScanner() async {
    await Get.toNamed(Routes.OCR);
  }

  void saveTransaction() {
    print("Menyimpan transaksi...");
    print("Tipe: ${isExpense.value ? 'Pengeluaran' : 'Pemasukan'}");
    print("Jumlah: ${amountController.text}");
    // Logika simpan ke database di sini
  }

  @override
  void onClose() {
    amountController.dispose();
    noteController.dispose();
    super.onClose();
  }
}
