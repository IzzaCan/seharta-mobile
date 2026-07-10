import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../manage_categories/controllers/manage_categories_controller.dart';
import '../../manage_wallets/controllers/manage_wallets_controller.dart';
import '../../../data/providers/wallet_provider.dart';
import '../../home/controllers/home_controller.dart';
import '../../wallet/controllers/wallet_controller.dart';
import '../../../data/models/wallet_model.dart';

class AddTransactionController extends GetxController {
  // State untuk Tab Pengeluaran vs Pemasukan (True = Pengeluaran)
  var isExpense = true.obs;

  // Controller dan FocusNode untuk Text Input
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  final amountFocusNode = FocusNode();
  final noteFocusNode = FocusNode();

  // State untuk Dropdown/Pilihan (Bisa diubah nantinya sesuai model database)
  var selectedCategory = 'Pilih Kategori'.obs;
  var selectedWallet = 'Pilih Dompet'.obs;
  
  var isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Reset state saat halaman dibuka (jika controller digunakan kembali)
    selectedWallet.value = 'Pilih Dompet';
    selectedCategory.value = 'Pilih Kategori';
    amountController.clear();
    noteController.clear();
  }

  void toggleTransactionType(bool isExpenseType) {
    isExpense.value = isExpenseType;
    selectedCategory.value = 'Pilih Kategori'; // Reset selected category when switching types
  }

  Future<void> openOcrScanner() async {
    await Get.toNamed(Routes.OCR);
  }

  Future<void> saveTransaction() async {
    if (amountController.text.isEmpty || amountController.text == '0') {
      Get.snackbar('Validasi', 'Jumlah transaksi tidak boleh kosong', backgroundColor: Colors.red[100]);
      return;
    }
    if (selectedWallet.value == 'Pilih Dompet') {
      Get.snackbar('Validasi', 'Silakan pilih dompet', backgroundColor: Colors.red[100]);
      return;
    }
    if (selectedCategory.value == 'Pilih Kategori') {
      Get.snackbar('Validasi', 'Silakan pilih kategori', backgroundColor: Colors.red[100]);
      return;
    }

    final amountStr = amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = double.tryParse(amountStr) ?? 0.0;

    // Lookup IDs
    final walletController = Get.put(ManageWalletsController());
    final wallet = walletController.wallets.firstWhere(
      (w) => w.walletName == selectedWallet.value,
      orElse: () => WalletModel(id: '', walletName: '', balance: 0.0, isActive: false),
    );
    if (wallet.id.isEmpty) {
      Get.snackbar('Error', 'Dompet tidak ditemukan', backgroundColor: Colors.red[100]);
      return;
    }

    final categoryController = Get.put(ManageCategoriesController());
    final category = categoryController.categories.firstWhere(
      (c) => c['title'] == selectedCategory.value,
      orElse: () => <String, dynamic>{},
    );
    final categoryId = category['id'] as String?;
    if (categoryId == null || categoryId.isEmpty) {
      Get.snackbar('Error', 'Kategori tidak valid', backgroundColor: Colors.red[100]);
      return;
    }

    try {
      isSaving.value = true;
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      
      final provider = WalletProvider();
      await provider.createTransaction(
        walletId: wallet.id,
        categoryId: categoryId,
        amount: amount,
        description: noteController.text.trim(),
      );
      
      // Reactive Sync
      if (Get.isRegistered<HomeController>()) {
        final homeCtrl = Get.find<HomeController>();
        homeCtrl.fetchDashboardData();
      }
      
      if (Get.isRegistered<WalletController>()) {
        final walletCtrl = Get.find<WalletController>();
        walletCtrl.loadWalletData();
      }
      
      if (Get.isRegistered<ManageWalletsController>()) {
        final manageWalletsCtrl = Get.find<ManageWalletsController>();
        manageWalletsCtrl.fetchWallets();
      }

      Get.back(); // close dialog
      Get.offAllNamed(Routes.HOME);
      Get.snackbar('Sukses', 'Transaksi berhasil disimpan', backgroundColor: Colors.green[100]);
    } catch (e) {
      Get.back(); // close dialog
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''), backgroundColor: Colors.red[100]);
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    amountController.dispose();
    noteController.dispose();
    amountFocusNode.dispose();
    noteFocusNode.dispose();
    super.onClose();
  }
}
