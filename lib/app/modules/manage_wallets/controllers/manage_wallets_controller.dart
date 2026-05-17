import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ManageWalletsController extends GetxController {
  // Menyimpan judul dompet yang sedang di-tap untuk memunculkan tombol aksi geser
  var selectedWallet = ''.obs;

  // List data dompet simulasi reaktif
  var wallets = <Map<String, dynamic>>[].obs;

  // Controller untuk Form Input di Bottom Sheet
  final walletNameController = TextEditingController();
  final walletBalanceController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Data awal dummy
    wallets.assignAll([
      {
        'title': 'BCA Keluarga',
        'balance': 'Rp5.000.000',
        'icon': Icons.credit_card,
        'iconColor': const Color(0xFF0D2B33),
        'iconBgColor': const Color(0xFFF0F4F8),
      },
      {
        'title': 'Kas Tunai',
        'balance': 'Rp500.000',
        'icon': Icons.money,
        'iconColor': Colors.blueGrey,
        'iconBgColor': const Color(0xFFE3F2FD),
      },
    ]);
  }

  void selectWallet(String title) {
    if (selectedWallet.value == title) {
      selectedWallet.value = '';
    } else {
      selectedWallet.value = title;
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

  void submitNewWallet() {
    String name = walletNameController.text.trim();
    String balance = walletBalanceController.text.trim();

    if (name.isNotEmpty && balance.isNotEmpty) {
      // Formatting sederhana ke mata uang lokal
      double? balanceVal = double.tryParse(balance);
      String formattedBalance = balanceVal != null
          ? 'Rp${balanceVal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}'
          : 'Rp$balance';

      wallets.add({
        'title': name,
        'balance': formattedBalance,
        'icon': Icons.account_balance_wallet,
        'iconColor': const Color(0xFF1F9975),
        'iconBgColor': const Color(0xFFE8F5EE),
      });

      Get.back();
      Get.snackbar(
        'Sukses',
        'Dompet $name berhasil ditambahkan!',
        backgroundColor: const Color(0xFFE8F5EE),
        colorText: const Color(0xFF0D2B33),
      );
    }
  }

  void editWallet(String title) {
    print("Mengedit dompet: $title");
    // TODO: Implementasi form dialog atau bottom sheet edit dompet
  }

  void deleteWallet(String title) {
    wallets.removeWhere((w) => w['title'] == title);
    selectedWallet.value = '';
    Get.snackbar(
      'Hapus',
      'Dompet $title berhasil dihapus.',
      backgroundColor: const Color(0xFFFFEBEE),
      colorText: const Color(0xFFD32F2F),
    );
  }

  @override
  void onClose() {
    walletNameController.dispose();
    walletBalanceController.dispose();
    super.onClose();
  }
}
