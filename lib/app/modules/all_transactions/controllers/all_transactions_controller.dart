import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/budget_model.dart';
import '../../../data/models/wallet_model.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/services/auth_service.dart';

class AllTransactionsController extends GetxController with StateMixin<List<TransactionModel>> {
  final ApiProvider _apiProvider = ApiProvider();
  final AuthService _authService = Get.find<AuthService>();

  // Filter State
  final selectedMonth = DateTime.now().month.obs;
  final selectedYear = DateTime.now().year.obs;
  
  // 'ALL', 'INCOME', 'EXPENSE', 'TRANSFER'
  final selectedType = 'ALL'.obs;

  // Custom Date Range
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    fetchTransactions();
  }

  void changeMonth(int month, int year) {
    // Bersihkan custom date range jika memilih filter bulan
    startDate.value = null;
    endDate.value = null;
    selectedMonth.value = month;
    selectedYear.value = year;
    fetchTransactions();
  }

  void changeType(String type) {
    selectedType.value = type;
    fetchTransactions();
  }

  void setDateRange(DateTime start, DateTime end) {
    startDate.value = start;
    endDate.value = end;
    fetchTransactions();
  }

  void clearDateRange() {
    startDate.value = null;
    endDate.value = null;
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    try {
      change(null, status: RxStatus.loading());

      final token = _authService.accessToken.value;
      if (token.isEmpty) {
        change(null, status: RxStatus.error("Unauthenticated"));
        return;
      }

      String dateFromStr;
      String dateToStr;

      if (startDate.value != null && endDate.value != null) {
        dateFromStr = DateFormat('yyyy-MM-dd').format(startDate.value!);
        dateToStr = DateFormat('yyyy-MM-dd').format(endDate.value!);
      } else {
        // Hitung date_from dan date_to berdasarkan selectedMonth dan selectedYear
        final dateFrom = DateTime(selectedYear.value, selectedMonth.value, 1);
        final nextMonth = selectedMonth.value == 12 ? 1 : selectedMonth.value + 1;
        final nextYear = selectedMonth.value == 12 ? selectedYear.value + 1 : selectedYear.value;
        final dateTo = DateTime(nextYear, nextMonth, 1).subtract(const Duration(days: 1));

        dateFromStr = DateFormat('yyyy-MM-dd').format(dateFrom);
        dateToStr = DateFormat('yyyy-MM-dd').format(dateTo);
      }

      String endpoint = '/transactions/?page=1&size=100&date_from=${dateFromStr}T00:00:00&date_to=${dateToStr}T23:59:59';
      
      if (selectedType.value != 'ALL') {
        endpoint += '&transaction_type=${selectedType.value}';
      }

      final response = await _apiProvider.get(endpoint, token: token);
      
      if (response != null && response['items'] != null) {
        final txData = response['items'] as List;
        final transactions = txData.map((e) => TransactionModel.fromJson(e)).toList();
        
        if (transactions.isEmpty) {
          change([], status: RxStatus.empty());
        } else {
          change(transactions, status: RxStatus.success());
        }
      } else {
        change(null, status: RxStatus.error("Gagal mengambil data"));
      }
    } catch (e) {
      change(null, status: RxStatus.error(e.toString()));
    }
  }

  // Format Helper
  String formatRupiah(double amount) {
    return "Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }
}
