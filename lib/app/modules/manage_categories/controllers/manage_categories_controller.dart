import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ManageCategoriesController extends GetxController {
  var isExpense = true.obs;
  var selectedCategory = ''.obs;
  var categories = <Map<String, dynamic>>[].obs; // (List kategori Anda sebelumnya tetap di sini)

  // Tambahkan controller untuk Input Text Form
  final categoryNameController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Inisialisasi data awal simulasi jika diperlukan
    categories.assignAll([
      {
        'title': 'Makan',
        'subtitle': '0 Transaksi bulan ini',
        'icon': Icons.restaurant,
        'color': Colors.orange,
        'isExpense': true,
      },
      {
        'title': 'Tagihan',
        'subtitle': '0 Transaksi bulan ini',
        'icon': Icons.lightbulb,
        'color': Colors.amber,
        'isExpense': true,
      },
    ]);
  }

  void toggleCategoryType(bool expense) {
    isExpense.value = expense;
    selectedCategory.value = '';
  }

  void selectCategory(String title) {
    if (selectedCategory.value == title) {
      selectedCategory.value = '';
    } else {
      selectedCategory.value = title;
    }
  }

  // Ubah fungsi addCategory menjadi seperti ini
  void addCategory() {
    // Reset input text setiap kali membuka form baru
    categoryNameController.clear();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tambah Kategori Baru (${isExpense.value ? "Pengeluaran" : "Pemasukan"})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D2B33),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: categoryNameController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Nama Kategori (cth: Transportasi, Jajan)',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                filled: true,
                fillColor: const Color(0xFFF8F9FF),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: const Color(0xFFE0E5E9)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1F9975), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => submitNewCategory(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D2B33),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Simpan Kategori',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      isScrollControlled: true, // Agar keyboard tidak menutupi textfield
    );
  }

  void submitNewCategory() {
    String name = categoryNameController.text.trim();
    if (name.isNotEmpty) {
      // Tambahkan data baru secara dinamis ke list Rx
      categories.add({
        'title': name,
        'subtitle': '0 Transaksi bulan ini',
        'icon': isExpense.value ? Icons.category : Icons.account_balance_wallet,
        'color': isExpense.value ? Colors.blueGrey : Colors.green,
        'isExpense': isExpense.value,
      });

      Get.back(); // Menutup bottom sheet
      Get.snackbar(
        'Sukses', 
        'Kategori $name berhasil ditambahkan!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFE8F5EE),
        colorText: const Color(0xFF0D2B33),
      );
    }
  }

  void editCategory(String title) {
    print("Mengedit kategori: $title");
  }

  void deleteCategory(String title) {
    categories.removeWhere((element) => element['title'] == title);
    selectedCategory.value = '';
  }

  @override
  void onClose() {
    categoryNameController.dispose();
    super.onClose();
  }
}