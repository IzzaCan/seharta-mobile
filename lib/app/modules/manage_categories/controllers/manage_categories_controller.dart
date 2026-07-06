import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../providers/category_provider.dart';
import '../../add_transaction/controllers/add_transaction_controller.dart';

class ManageCategoriesController extends GetxController {
  final CategoryProvider _categoryProvider = CategoryProvider();

  bool isExpense = true;
  String selectedCategory = '';
  List<Map<String, dynamic>> categories = []; 
  bool isLoading = false;

  // Tambahkan controller untuk Input Text Form
  final categoryNameController = TextEditingController();
  final editCategoryNameController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      isLoading = true;
      update();
      final fetchedCategories = await _categoryProvider.fetchCategories();
      
      final mappedCategories = fetchedCategories.map<Map<String, dynamic>>((c) {
        final isExp = c.type == 'expense';
        return <String, dynamic>{
          'id': c.id,
          'title': c.name,
          'subtitle': c.isDefault ? 'Kategori Bawaan' : 'Kategori Khusus',
          'icon': isExp ? Icons.category : Icons.account_balance_wallet,
          'color': c.isDefault ? Colors.blueGrey : (isExp ? Colors.orange : Colors.green),
          'isExpense': isExp,
          'isDefault': c.isDefault,
        };
      }).toList();

      categories = mappedCategories;
    } catch (e) {
      Get.snackbar(
        'Gagal Memuat Kategori',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading = false;
      update();
    }
  }

  void toggleCategoryType(bool expense) {
    isExpense = expense;
    selectedCategory = '';
    update();
  }

  void selectCategory(String title) {
    if (selectedCategory == title) {
      selectedCategory = '';
    } else {
      selectedCategory = title;
    }
    update();
  }

  // Ubah fungsi addCategory menjadi seperti ini
  void addCategory() {
    // Reset input text setiap kali membuka form baru
    categoryNameController.clear();

    Get.bottomSheet(
      Builder(
        builder: (context) {
          return Align(
            alignment: Alignment.bottomCenter,
            child: Container(
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
                    'Tambah Kategori Baru (${isExpense ? "Pengeluaran" : "Pemasukan"})',
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
          );
        }
      ),
      isScrollControlled: true, // Agar keyboard tidak menutupi textfield
    );
  }

  void submitNewCategory() async {
    String name = categoryNameController.text.trim();
    if (name.isEmpty) return;

    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      
      final type = isExpense ? 'expense' : 'income';
      await _categoryProvider.createCategory(name, type);
      
      if (Get.isDialogOpen == true) Get.back(); // Tutup loading
      await Future.delayed(Duration.zero);
      Get.back(); // Menutup bottom sheet
      
      Get.snackbar(
        'Sukses', 
        'Kategori $name berhasil ditambahkan!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFE8F5EE),
        colorText: const Color(0xFF0D2B33),
      );

      await loadCategories();
      _syncAddTransactionController();

    } catch (e) {
      if (Get.isDialogOpen == true) Get.back(); // Tutup loading
      Get.snackbar(
        'Gagal', 
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  void editCategory(String title) {
    final category = categories.firstWhere((c) => c['title'] == title, orElse: () => <String, dynamic>{});
    if (category.isEmpty) return;
    
    if (category['isDefault'] == true) {
      Get.snackbar('Perhatian', 'Kategori bawaan tidak dapat diedit.', snackPosition: SnackPosition.TOP);
      return;
    }

    editCategoryNameController.text = title;

    Get.bottomSheet(
      Builder(
        builder: (context) {
          return Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 24),
                  const Text('Edit Kategori', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D2B33))),
                  const SizedBox(height: 16),
                  TextField(
                    controller: editCategoryNameController,
                    autofocus: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF8F9FF),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: const Color(0xFFE0E5E9))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1F9975), width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => _submitEditCategory(category['id'], editCategoryNameController.text.trim()),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D2B33), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        }
      ),
      isScrollControlled: true,
    );
  }

  void _submitEditCategory(String id, String newName) async {
    if (newName.isEmpty) return;

    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      
      await _categoryProvider.updateCategory(id, name: newName);
      
      if (Get.isDialogOpen == true) Get.back(); // Tutup loading
      await Future.delayed(Duration.zero);
      Get.back(); // Tutup bottom sheet
      
      Get.snackbar('Sukses', 'Kategori berhasil diperbarui!', snackPosition: SnackPosition.TOP, backgroundColor: const Color(0xFFE8F5EE), colorText: const Color(0xFF0D2B33));
      
      selectedCategory = ''; // Reset selection
      await loadCategories();
      _syncAddTransactionController();
      
    } catch (e) {
      if (Get.isDialogOpen == true) Get.back(); // Tutup loading
      Get.snackbar('Gagal', e.toString().replaceAll('Exception: ', ''), snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red[100], colorText: Colors.red[900]);
    }
  }

  void deleteCategory(String title) async {
    final category = categories.firstWhere((c) => c['title'] == title, orElse: () => <String, dynamic>{});
    if (category.isEmpty) return;

    if (category['isDefault'] == true) {
      Get.snackbar('Perhatian', 'Kategori bawaan tidak dapat dihapus.', snackPosition: SnackPosition.TOP);
      return;
    }

    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      
      await _categoryProvider.deleteCategory(category['id']);
      
      if (Get.isDialogOpen == true) Get.back(); // Tutup loading
      
      Get.snackbar('Sukses', 'Kategori $title berhasil dihapus!', snackPosition: SnackPosition.TOP, backgroundColor: const Color(0xFFE8F5EE), colorText: const Color(0xFF0D2B33));
      
      if (selectedCategory == title) selectedCategory = '';
      await loadCategories();
      _syncAddTransactionController();

    } catch (e) {
      if (Get.isDialogOpen == true) Get.back(); // Tutup loading
      Get.snackbar('Gagal', e.toString().replaceAll('Exception: ', ''), snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red[100], colorText: Colors.red[900]);
    }
  }

  void _syncAddTransactionController() {
    if (Get.isRegistered<AddTransactionController>()) {
      final controller = Get.find<AddTransactionController>();
      
      // Jika kategori yang dipilih pengguna saat ini terhapus, kita kosongkan
      final stillExists = categories.any((c) => c['title'] == controller.selectedCategory.value);
      if (!stillExists) {
        controller.selectedCategory.value = '';
      }
    }
  }

  @override
  void onClose() {
    categoryNameController.dispose();
    editCategoryNameController.dispose();
    super.onClose();
  }
}