import 'package:get/get.dart';

class ManageCategoriesController extends GetxController {
  // true = Pengeluaran, false = Pemasukan
  var isExpense = true.obs;

  void toggleCategoryType(bool expense) {
    isExpense.value = expense;
  }

  void addCategory() {
    print("Membuka form tambah kategori baru...");
  }

  void editCategory() {
    print("Edit kategori...");
  }

  void deleteCategory() {
    print("Hapus kategori...");
  }
}
