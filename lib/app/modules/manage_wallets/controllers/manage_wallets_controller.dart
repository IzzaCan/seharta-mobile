import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../wallet/models/wallet_model.dart';
import '../../wallet/providers/wallet_provider.dart';
import '../../wallet/controllers/wallet_controller.dart';

class ManageWalletsController extends GetxController {
  final WalletProvider _walletProvider = WalletProvider();

  // Menyimpan ID dompet yang sedang di-tap untuk memunculkan tombol aksi geser
  var selectedWalletId = ''.obs;

  // List data dompet reaktif
  var wallets = <WalletModel>[].obs;
  var isLoading = false.obs;

  // Controller untuk Form Input di Bottom Sheet
  final walletNameController = TextEditingController();
  final walletBalanceController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchWallets();
  }

  Future<void> fetchWallets() async {
    try {
      isLoading.value = true;
      final data = await _walletProvider.fetchWallets();
      wallets.assignAll(data);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat dompet: $e',
          backgroundColor: const Color(0xFFFFEBEE), colorText: const Color(0xFFD32F2F));
    } finally {
      isLoading.value = false;
    }
  }

  void selectWallet(String id) {
    if (selectedWalletId.value == id) {
      selectedWalletId.value = '';
    } else {
      selectedWalletId.value = id;
    }
  }

  void addWallet() {
    walletNameController.clear();
    walletBalanceController.clear();

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
            const Text(
              'Tambah Dompet Baru',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D2B33),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: walletNameController,
              decoration: InputDecoration(
                hintText: 'Nama Dompet (cth: Mandiri, Jago)',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                filled: true,
                fillColor: const Color(0xFFF8F9FF),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E5E9)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF1F9975),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: walletBalanceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Saldo Awal (cth: 100000)',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                filled: true,
                fillColor: const Color(0xFFF8F9FF),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E5E9)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF1F9975),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => submitNewWallet(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D2B33),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Simpan Dompet',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> submitNewWallet() async {
    String name = walletNameController.text.trim();
    String balanceText = walletBalanceController.text.trim();

    if (name.isNotEmpty && balanceText.isNotEmpty) {
      double? balance = double.tryParse(balanceText);
      if (balance == null) {
        Get.snackbar('Error', 'Saldo harus berupa angka valid',
            backgroundColor: const Color(0xFFFFEBEE), colorText: const Color(0xFFD32F2F));
        return;
      }

      try {
        Get.back(); // Tutup bottom sheet
        await _walletProvider.createWallet(name, balance);
        
        Get.snackbar(
          'Sukses',
          'Dompet $name berhasil ditambahkan!',
          backgroundColor: const Color(0xFFE8F5EE),
          colorText: const Color(0xFF0D2B33),
        );
        
        await fetchWallets(); // Refresh data diri sendiri
        
        // Refresh WalletController agar UI utama ikut terupdate
        if (Get.isRegistered<WalletController>()) {
          Get.find<WalletController>().loadWalletData();
        }
      } catch (e) {
        Get.snackbar('Error', 'Gagal menambahkan dompet: $e',
            backgroundColor: const Color(0xFFFFEBEE), colorText: const Color(0xFFD32F2F));
      }
    }
  }

  void editWallet(String id, String currentName) {
    print("Mengedit dompet: $currentName");
    // TODO: Implementasi form dialog atau bottom sheet edit dompet
  }

  Future<void> deleteWallet(String id, String name) async {
    try {
      await _walletProvider.deleteWallet(id);
      wallets.removeWhere((w) => w.id == id);
      selectedWalletId.value = '';
      
      Get.snackbar(
        'Hapus',
        'Dompet $name berhasil dihapus/dinonaktifkan.',
        backgroundColor: const Color(0xFFFFEBEE),
        colorText: const Color(0xFFD32F2F),
      );
      
      // Refresh WalletController
      if (Get.isRegistered<WalletController>()) {
        Get.find<WalletController>().loadWalletData();
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus dompet: $e',
          backgroundColor: const Color(0xFFFFEBEE), colorText: const Color(0xFFD32F2F));
    }
  }

  @override
  void onClose() {
    walletNameController.dispose();
    walletBalanceController.dispose();
    super.onClose();
  }
}
