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
  var selectedCategory = 'Makanan'.obs;
  var selectedWallet = 'Utama'.obs;

  void toggleTransactionType(bool isExpenseType) {
    isExpense.value = isExpenseType;
  }

  void openOcrScanner() {
    Get.toNamed(Routes.SCAN_RECEIPT);
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
