import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../routes/app_pages.dart';
import '../../../data/services/family_service.dart';
import '../../../data/services/auth_service.dart';
import '../../wallet/models/wallet_model.dart';
import '../../wallet/providers/wallet_provider.dart';
import '../../../data/providers/api_provider.dart';

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
  var isLoadingWallets = true.obs;

  double get totalSaldoBersama {
    return wallets.fold(0.0, (sum, wallet) => sum + wallet.balance);
  }

  // State untuk AI Insight
  var aiInsightText = ''.obs;
  var isLoadingInsight = true.obs;
  final ApiProvider _apiProvider = ApiProvider();

  // State untuk riwayat transaksi
  var transactions = <TransactionModel>[].obs;
  var isLoadingTransactions = true.obs;

  // State untuk Balance Summary
  var percentageChange = 0.0.obs;
  var isPositiveChange = true.obs;
  var isLoadingSummary = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWallets();
    fetchTransactionHistory();
    fetchAiInsight();
    fetchAnalyticsSummary();
  }

  Future<void> fetchWallets() async {
    try {
      isLoadingWallets(true);
      final fetchedWallets = await _walletProvider.fetchWallets();
      wallets.assignAll(fetchedWallets);
    } catch (e) {
      Get.snackbar(
        'Gagal Memuat Dompet',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoadingWallets(false);
    }
  }

  Future<void> fetchTransactionHistory() async {
    try {
      isLoadingTransactions(true);
      final fetchedTransactions = await _walletProvider.fetchTransactions();
      transactions.assignAll(fetchedTransactions);
    } catch (e) {
      Get.snackbar(
        'Gagal Memuat Transaksi',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoadingTransactions(false);
    }
  }

  Future<void> fetchAiInsight() async {
    try {
      isLoadingInsight(true);
      final token = _authService.accessToken.value;
      if (token.isEmpty) return;

      final response = await _apiProvider.get('/analytics/insight', token: token);
      if (response != null && response['insight'] != null) {
        aiInsightText.value = response['insight'];
      } else {
        aiInsightText.value = "Pengeluaran Anda bulan ini stabil. Terus pertahankan pengelolaan keuangan yang baik!";
      }
    } catch (e) {
      aiInsightText.value = "Tetap semangat mengatur keuangan keluarga Anda minggu ini!";
    } finally {
      isLoadingInsight(false);
    }
  }

  Future<void> fetchAnalyticsSummary() async {
    try {
      isLoadingSummary(true);
      final token = _authService.accessToken.value;
      if (token.isEmpty) return;

      final response = await _apiProvider.get('/analytics/summary', token: token);
      if (response != null) {
        percentageChange.value = response['percentage_change']?.toDouble() ?? 0.0;
        isPositiveChange.value = response['is_positive'] ?? true;
      }
    } catch (e) {
      percentageChange.value = 0.0;
      isPositiveChange.value = true;
    } finally {
      isLoadingSummary(false);
    }
  }

  Future<void> refreshData() async {
    await Future.wait([
      fetchWallets(),
      fetchTransactionHistory(),
      fetchAiInsight(),
      fetchAnalyticsSummary(),
    ]);
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
