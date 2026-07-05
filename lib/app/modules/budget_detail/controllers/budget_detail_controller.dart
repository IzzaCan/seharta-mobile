import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/models/budget_model.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/services/auth_service.dart';
import '../../wallet/models/wallet_model.dart';

class BudgetDetailController extends GetxController {
  final ApiProvider _apiProvider = ApiProvider();
  final AuthService _authService = Get.find<AuthService>();

  late BudgetModel budget;
  var transactions = <TransactionModel>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    budget = Get.arguments as BudgetModel;
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    try {
      isLoading(true);
      final token = _authService.accessToken.value;
      if (token.isEmpty) return;

      // Ambil range tanggal awal bulan sampai akhir bulan
      final dateFrom = DateTime(budget.year, budget.month, 1);
      final dateTo = DateTime(budget.year, budget.month + 1, 1).subtract(const Duration(milliseconds: 1));

      final path = '/transactions/?category_id=${budget.categoryId}&date_from=${Uri.encodeComponent(dateFrom.toIso8601String())}&date_to=${Uri.encodeComponent(dateTo.toIso8601String())}';
      final response = await _apiProvider.get(path, token: token);
      if (response != null) {
        final data = response['items'] ?? response['data'] ?? [];
        transactions.assignAll((data as List).map((e) => TransactionModel.fromJson(e)).toList());
      }
    } catch (e) {
      debugPrint("Failed to fetch transactions for budget detail: $e");
      Get.snackbar(
        'Gagal Memuat Transaksi',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  String formatRupiah(double amount) {
    return "Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }
}
