import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../routes/app_pages.dart';
import '../../../data/services/family_service.dart';
import '../../../data/services/auth_service.dart';
import '../../wallet/models/wallet_model.dart';
import '../../wallet/providers/wallet_provider.dart';

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

  // State untuk riwayat transaksi
  var transactions = <TransactionModel>[].obs;
  var isLoadingTransactions = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWallets();
    fetchTransactionHistory();
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

  Future<void> refreshData() async {
    await Future.wait([
      fetchWallets(),
      fetchTransactionHistory(),
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
