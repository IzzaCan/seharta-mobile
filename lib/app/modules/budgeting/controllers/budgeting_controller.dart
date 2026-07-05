import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/budget_model.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/services/auth_service.dart';
import '../../home/controllers/home_controller.dart';
import '../../manage_categories/models/category_model.dart';
import '../../manage_categories/providers/category_provider.dart';

class BudgetingController extends GetxController {
  final ApiProvider _apiProvider = ApiProvider();
  final AuthService _authService = Get.find<AuthService>();
  final CategoryProvider _categoryProvider = CategoryProvider();
  
  var budgets = <BudgetModel>[].obs;
  var allBudgets = <BudgetModel>[].obs;
  var isLoading = true.obs;
  var selectedTab = 0.obs; // 0 = Aktif, 1 = Riwayat
  
  // State untuk Kategori Transaksi
  var categories = <CategoryModel>[].obs;
  var isLoadingCategories = false.obs;
  var selectedCategory = Rxn<CategoryModel>();
  var isRecurring = false.obs;

  // Getters untuk ringkasan anggaran
  double get totalLimitAmount => budgets.fold(0.0, (sum, item) => sum + item.limitAmount);
  double get totalSpentAmount => budgets.fold(0.0, (sum, item) => sum + item.spentAmount);
  double get totalRemainingAmount => budgets.fold(0.0, (sum, item) => sum + item.remainingAmount);
  double get totalProgressPercentage {
    final limit = totalLimitAmount;
    if (limit == 0) return 0.0;
    return (totalSpentAmount / limit) * 100;
  }

  String _getFormattedMonthName(int month, int year) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    if (month < 1 || month > 12) return '';
    return "${months[month - 1]} $year";
  }

  List<MapEntry<String, List<BudgetModel>>> get groupedHistoryBudgets {
    final Map<String, List<BudgetModel>> groups = {};
    final now = DateTime.now();

    for (var b in allBudgets) {
      if (b.month == now.month && b.year == now.year) continue;

      final key = _getFormattedMonthName(b.month, b.year);
      if (!groups.containsKey(key)) {
        groups[key] = [];
      }
      groups[key]!.add(b);
    }

    // Urutkan berdasarkan tahun & bulan DESC
    final sortedEntries = groups.entries.toList()
      ..sort((a, b) {
        if (a.value.isEmpty || b.value.isEmpty) return 0;
        final aFirst = a.value.first;
        final bFirst = b.value.first;
        if (aFirst.year != bFirst.year) {
          return bFirst.year.compareTo(aFirst.year);
        }
        return bFirst.month.compareTo(aFirst.month);
      });

    return sortedEntries;
  }

  @override
  void onInit() {
    super.onInit();
    fetchBudgets();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      isLoadingCategories(true);
      final list = await _categoryProvider.fetchCategories();
      // Filter kategori untuk pengeluaran (expense) saja karena budgeting untuk pengeluaran
      categories.assignAll(list.where((cat) => cat.type == 'expense').toList());
      if (categories.isNotEmpty) {
        selectedCategory.value = categories.first;
      }
    } catch (e) {
      debugPrint("Failed to fetch categories: $e");
    } finally {
      isLoadingCategories(false);
    }
  }

  Future<void> fetchBudgets() async {
    try {
      isLoading(true);
      final token = _authService.accessToken.value;
      if (token.isEmpty) return;

      final response = await _apiProvider.getBudgets(token: token);
      if (response != null && response['data'] != null) {
        final data = response['data'] as List;
        final list = data.map((e) => BudgetModel.fromJson(e)).toList();
        
        allBudgets.assignAll(list);
        
        final now = DateTime.now();
        // Filter anggaran hanya untuk bulan dan tahun berjalan
        budgets.assignAll(list.where((b) => b.month == now.month && b.year == now.year).toList());
      }
      
      // Update HomeController if registered
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().budgets.assignAll(budgets);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat anggaran: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> addBudget(String categoryId, double limitAmount) async {
    try {
      // Show loading
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      
      final token = _authService.accessToken.value;
      final now = DateTime.now();
      
      final data = {
        'category_id': categoryId,
        'budget_amount': limitAmount,
        'month': now.month,
        'year': now.year,
      };
      
      await _apiProvider.storeBudget(data: data, token: token);
      
      Get.back(); // close loading
      Get.back(); // close bottom sheet
      
      Get.snackbar(
        'Sukses',
        'Anggaran berhasil ditambahkan',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
      );
      
      fetchBudgets(); // refresh list
    } catch (e) {
      Get.back(); // close loading
      Get.snackbar(
        'Error',
        'Gagal menambahkan anggaran: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  Future<void> editBudget(String budgetId, double limitAmount) async {
    try {
      // Show loading
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      
      final token = _authService.accessToken.value;
      final data = {
        'budget_amount': limitAmount,
      };
      
      await _apiProvider.updateBudget(id: budgetId, data: data, token: token);
      
      Get.back(); // close loading
      
      Get.snackbar(
        'Sukses',
        'Anggaran berhasil diperbarui',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
      );
      
      fetchBudgets(); // refresh list
    } catch (e) {
      Get.back(); // close loading
      Get.snackbar(
        'Error',
        'Gagal memperbarui anggaran: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  Future<void> deleteBudget(String budgetId) async {
    try {
      // Show loading
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      
      final token = _authService.accessToken.value;
      
      await _apiProvider.deleteBudget(id: budgetId, token: token);
      
      Get.back(); // close loading
      
      Get.snackbar(
        'Sukses',
        'Anggaran berhasil dihapus',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
      );
      
      fetchBudgets(); // refresh list
    } catch (e) {
      Get.back(); // close loading
      Get.snackbar(
        'Error',
        'Gagal menghapus anggaran: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  Future<void> deleteBudgetsForMonth(int month, int year) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      final token = _authService.accessToken.value;
      final budgetsToDelete = allBudgets.where((b) => b.month == month && b.year == year).toList();
      for (var b in budgetsToDelete) {
        await _apiProvider.deleteBudget(id: b.id, token: token);
      }
      Get.back(); // close loading dialog
      fetchBudgets();
    } catch (e) {
      Get.back(); // close loading dialog
      Get.snackbar(
        'Error',
        'Gagal menghapus riwayat anggaran: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  String formatRupiah(double amount) {
    return "Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }
}
