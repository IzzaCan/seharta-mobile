import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../routes/app_pages.dart';
import '../../../data/services/family_service.dart';
import '../../../data/services/auth_service.dart';
import '../../wallet/models/wallet_model.dart';
import '../../wallet/providers/wallet_provider.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/models/budget_model.dart';

List<WalletModel> _parseWallets(List<dynamic> data) {
  return data.map((e) => WalletModel.fromJson(e)).toList();
}

List<TransactionModel> _parseTransactions(List<dynamic> data) {
  return data.map((e) => TransactionModel.fromJson(e)).toList();
}

List<BudgetModel> _parseBudgets(List<dynamic> data) {
  return data.map((e) => BudgetModel.fromJson(e)).toList();
}

class HomeController extends GetxController {
  final FamilyService _familyService = Get.find<FamilyService>();
  final AuthService _authService = Get.find<AuthService>();
  final WalletProvider _walletProvider = WalletProvider();
  
  RxString get familyName => _familyService.familyName;
  String? get avatarUrl => _authService.currentUser.value?.avatarUrl;
  
  String? get partnerName => _familyService.partner?.fullName;
  String? get partnerAvatarUrl => _familyService.partner?.avatarUrl;

  // State untuk Bottom Navigation Bar
  var currentIndex = 0.obs;

  // State untuk menyembunyikan/menampilkan nominal aset
  var isAssetVisible = true.obs;

  // State untuk daftar dompet
  var wallets = <WalletModel>[].obs;

  double get totalSaldoBersama {
    return wallets.fold(0.0, (sum, wallet) => sum + wallet.balance);
  }

  // State untuk AI Insight
  var aiInsightText = ''.obs;
  var isLoadingInsight = true.obs;
  final ApiProvider _apiProvider = ApiProvider();

  // State untuk riwayat transaksi
  var transactions = <TransactionModel>[].obs;

  // State untuk Dashboard (Pemasukan & Pengeluaran)
  var incomeThisMonth = 0.0.obs;
  var expenseThisMonth = 0.0.obs;
  var isLoadingDashboard = true.obs;

  // State untuk Budgeting
  var budgets = <BudgetModel>[].obs;
  var isLoadingBudgets = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCachedInsight();
    fetchDashboardData();
    fetchAiInsight();
    fetchBudgets();
  }

  Future<void> _loadCachedInsight() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('cached_ai_insight') ?? '';
      if (cached.isNotEmpty) {
        aiInsightText.value = cached;
        isLoadingInsight(false);
      }
    } catch (e) {
      debugPrint("Failed to load cached insight: $e");
    }
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoadingDashboard(true);
      final token = _authService.accessToken.value;
      if (token.isEmpty) return;

      final response = await _apiProvider.get('/dashboard/', token: token);
      if (response != null) {
        incomeThisMonth.value = response['income_this_month'] is String
            ? (double.tryParse(response['income_this_month']) ?? 0.0)
            : (response['income_this_month'] ?? 0).toDouble();
        expenseThisMonth.value = response['expense_this_month'] is String
            ? (double.tryParse(response['expense_this_month']) ?? 0.0)
            : (response['expense_this_month'] ?? 0).toDouble();

        final walletsData = response['wallets'] as List? ?? [];
        final parsedWallets = await compute(_parseWallets, walletsData);
        wallets.assignAll(parsedWallets);

        final txData = response['recent_transactions'] as List? ?? [];
        final parsedTx = await compute(_parseTransactions, txData);
        transactions.assignAll(parsedTx);
      }
    } catch (e) {
      Get.snackbar(
        'Gagal Memuat Dashboard',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoadingDashboard(false);
    }
  }

  Future<void> fetchAiInsight() async {
    try {
      if (aiInsightText.value.isEmpty) {
        isLoadingInsight(true);
      }
      final token = _authService.accessToken.value;
      if (token.isEmpty) return;

      final response = await _apiProvider.get('/analytics/insight', token: token);
      if (response != null && response['insight'] != null) {
        final newInsight = response['insight'];
        aiInsightText.value = newInsight;
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_ai_insight', newInsight);
      } else {
        if (aiInsightText.value.isEmpty) {
          aiInsightText.value = "Pengeluaran Anda bulan ini stabil. Terus pertahankan pengelolaan keuangan yang baik!";
        }
      }
    } catch (e) {
      if (aiInsightText.value.isEmpty) {
        aiInsightText.value = "Tetap semangat mengatur keuangan keluarga Anda minggu ini!";
      }
    } finally {
      isLoadingInsight(false);
    }
  }

  Future<void> refreshData() async {
    await Future.wait([
      fetchDashboardData(),
      fetchAiInsight(),
      fetchBudgets(),
    ]);
  }

  Future<void> fetchBudgets() async {
    try {
      isLoadingBudgets(true);
      final token = _authService.accessToken.value;
      if (token.isEmpty) return;

      final response = await _apiProvider.getBudgets(token: token);
      if (response != null && response['data'] != null) {
        final data = response['data'] as List;
        final list = await compute(_parseBudgets, data);
        
        final now = DateTime.now();
        // Filter anggaran hanya untuk bulan dan tahun berjalan
        budgets.assignAll(list.where((b) => b.month == now.month && b.year == now.year).toList());
      }
    } catch (e) {
      debugPrint("Failed to fetch budgets: $e");
    } finally {
      isLoadingBudgets(false);
    }
  }

  void changePage(int index) {
    currentIndex.value = index;
    switch (index) {
      case 0:
        Get.offAllNamed(Routes.HOME);
        break;
      case 1:
        Get.offAllNamed(Routes.HARTA);
        break;
      case 2:
        Get.offAllNamed(Routes.ANALYTICS);
        break;
      case 3:
        Get.offAllNamed(Routes.PROFILE);
        break;
    }
  }

  void toggleAssetVisibility() {
    isAssetVisible.value = !isAssetVisible.value;
  }

  // Helper untuk format rupiah (tampilan)
  String formatRupiah(double amount) {
    return "Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }
}
