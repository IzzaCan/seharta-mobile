import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/wallet_model.dart';
import '../providers/wallet_provider.dart';

class WalletController extends GetxController {
  final WalletProvider _walletProvider = Get.find<WalletProvider>();

  var isLoading = true.obs;
  var totalBalance = 0.0.obs;
  var wallets = <WalletModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadWalletData();
  }

  Future<void> loadWalletData() async {
    try {
      isLoading(true);
      
      // Ambil data dompet dari API
      final fetchedWallets = await _walletProvider.fetchWallets();

      // Hitung total saldo dari semua dompet keluarga yang aktif
      double balance = 0.0;
      for (var w in fetchedWallets) {
        if (w.isActive) {
          balance += w.balance;
        }
      }
      totalBalance.value = balance;

      // Assign daftar dompet ke reactive list
      wallets.assignAll(fetchedWallets);
      
    } catch (e) {
      Get.snackbar(
        'Gagal Memuat Data',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading(false);
    }
  }

  // Helper untuk format rupiah (tampilan)
  String formatRupiah(double amount) {
    return "Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }
}
