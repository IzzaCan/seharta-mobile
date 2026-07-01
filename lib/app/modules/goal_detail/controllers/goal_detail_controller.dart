import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../wallet/providers/wallet_provider.dart';
import '../../harta/models/goal_model.dart';
import '../../harta/controllers/harta_controller.dart';
import '../../../utils/rupiah_formatter.dart';
import '../../manage_wallets/controllers/manage_wallets_controller.dart';

class GoalDetailController extends GetxController {
  final WalletProvider _walletProvider = WalletProvider();
  
  var isLoading = true.obs;
  var goalDetail = Rxn<GoalDetailModel>();
  late String goalId;

  var selectedWalletId = ''.obs;
  var selectedWalletName = 'Pilih Dompet'.obs;
  var useWallet = true.obs;

  @override
  void onInit() {
    super.onInit();
    goalId = Get.arguments as String;
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    try {
      isLoading(true);
      final detail = await _walletProvider.fetchGoalDetail(goalId);
      goalDetail.value = detail;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading(false);
    }
  }

  void _showWalletPicker(BuildContext context) {
    final walletController = Get.put(ManageWalletsController());
    
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Dompet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D2B33),
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: Obx(() {
                final list = walletController.wallets;
                
                if (list.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Text('Belum ada dompet. Silakan buat di menu Profile.'),
                    ),
                  );
                }
                
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final w = list[index];
                    final String title = w.walletName;
                    
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet,
                          color: Colors.blueGrey,
                          size: 18,
                        ),
                      ),
                      title: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D2B33),
                        ),
                      ),
                      subtitle: Text(
                        'Rp${w.balance.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                      trailing: selectedWalletId.value == w.id
                          ? const Icon(Icons.check_circle, color: Colors.blue)
                          : const SizedBox.shrink(),
                      onTap: () {
                        selectedWalletId.value = w.id;
                        selectedWalletName.value = title;
                        Get.back();
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void addContribution() {
    final amountController = TextEditingController();
    selectedWalletId.value = '';
    selectedWalletName.value = 'Pilih Dompet';
    useWallet.value = true;

    Get.bottomSheet(
      Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(Get.context!).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tambah Setoran',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D2B33),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [RupiahInputFormatter()],
                  decoration: InputDecoration(
                    prefixText: 'Rp ',
                    hintText: 'Mis. 50.000',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Gunakan Saldo Dompet', style: TextStyle(fontSize: 14)),
                    Obx(() => Switch(
                          value: useWallet.value,
                          onChanged: (val) => useWallet.value = val,
                          activeColor: const Color(0xFF1F9975),
                        )),
                  ],
                ),
                Obx(() {
                  if (useWallet.value) {
                    return Column(
                      children: [
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _showWalletPicker(Get.context!),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Obx(() => Text(
                                      selectedWalletName.value,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: selectedWalletId.value.isEmpty 
                                            ? Colors.grey[600] 
                                            : const Color(0xFF0D2B33),
                                      ),
                                    )),
                                Icon(Icons.keyboard_arrow_down, color: Colors.grey[500], size: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                }),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final amountText = amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
                      final amount = double.tryParse(amountText);
                      if (amount == null || amount <= 0) {
                        Get.snackbar('Validasi', 'Masukkan nominal setoran', backgroundColor: Colors.red[100]);
                        return;
                      }
                      if (useWallet.value && selectedWalletId.value.isEmpty) {
                        Get.snackbar('Validasi', 'Pilih dompet sumber setoran', backgroundColor: Colors.red[100]);
                        return;
                      }
                      Get.back(); // close modal
                      await _submitContribution(amount, useWallet.value ? selectedWalletId.value : null);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D2B33),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Simpan', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> _submitContribution(double amount, String? walletId) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      await _walletProvider.addGoalContribution(
        goalId: goalId,
        amount: amount,
        transactionType: 'DEPOSIT',
        walletId: walletId,
      );
      Get.back(); // close loading
      Get.snackbar('Berhasil', 'Setoran berhasil ditambahkan', backgroundColor: Colors.green[100], colorText: Colors.green[900]);
      fetchDetail(); // refresh
      if (Get.isRegistered<HartaController>()) {
        Get.find<HartaController>().fetchGoals();
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''), backgroundColor: Colors.red[100], colorText: Colors.red[900]);
    }
  }

  void confirmDeleteGoal() {
    Get.defaultDialog(
      title: 'Hapus Goal',
      middleText: 'Apakah Anda yakin ingin menghapus goal ini? Seluruh riwayat transaksi transfer yang berkaitan juga akan dibatalkan/dibalikkan saldonya.',
      textConfirm: 'Ya, Hapus',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF0D2B33),
      onConfirm: () async {
        Get.back(); // close dialog
        await _deleteGoal();
      },
    );
  }

  Future<void> _deleteGoal() async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      await _walletProvider.deleteGoal(goalId);
      Get.back(); // close loading
      Get.back(); // close GoalDetailView (back to Harta tab)
      Get.snackbar('Berhasil', 'Goal berhasil dihapus', backgroundColor: Colors.green[100], colorText: Colors.green[900]);
      if (Get.isRegistered<HartaController>()) {
        Get.find<HartaController>().fetchGoals();
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''), backgroundColor: Colors.red[100], colorText: Colors.red[900]);
    }
  }

  void editGoal() {
    final detail = goalDetail.value;
    if (detail == null) return;

    final nameCtrl = TextEditingController(text: detail.name);
    final amountCtrl = TextEditingController(text: detail.targetAmount.toStringAsFixed(0));
    final noteCtrl = TextEditingController(text: detail.note ?? '');
    var selectedEditDate = Rxn<DateTime>(detail.deadline);

    // Formatter for amount input
    amountCtrl.text = amountCtrl.text.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

    Get.bottomSheet(
      Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(Get.context!).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit Goal',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D2B33),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nama Target',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [RupiahInputFormatter()],
                  decoration: const InputDecoration(
                    labelText: 'Target Uang',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: Get.context!,
                      initialDate: selectedEditDate.value ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2050),
                    );
                    if (picked != null) {
                      selectedEditDate.value = picked;
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(() => Text(
                          selectedEditDate.value == null
                              ? 'Tanpa Target Tanggal'
                              : DateFormat('dd MMMM yyyy').format(selectedEditDate.value!),
                        )),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Catatan (Opsional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final name = nameCtrl.text.trim();
                      final amountText = amountCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
                      final amount = double.tryParse(amountText);
                      
                      if (name.isEmpty) {
                        Get.snackbar('Validasi', 'Nama target tidak boleh kosong', backgroundColor: Colors.red[100]);
                        return;
                      }
                      if (amount == null || amount <= 0) {
                        Get.snackbar('Validasi', 'Target uang tidak valid', backgroundColor: Colors.red[100]);
                        return;
                      }

                      Get.back(); // close modal
                      await _submitEditGoal(
                        name: name,
                        targetAmount: amount,
                        deadline: selectedEditDate.value != null 
                            ? DateFormat('yyyy-MM-dd').format(selectedEditDate.value!) 
                            : null,
                        note: noteCtrl.text.trim(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D2B33),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Simpan Perubahan', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> _submitEditGoal({
    required String name,
    required double targetAmount,
    String? deadline,
    String? note,
  }) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      await _walletProvider.updateGoal(
        goalId: goalId,
        name: name,
        targetAmount: targetAmount,
        deadline: deadline,
        note: note,
      );
      Get.back(); // close loading
      Get.snackbar('Berhasil', 'Goal berhasil diperbarui', backgroundColor: Colors.green[100], colorText: Colors.green[900]);
      fetchDetail(); // refresh detail page
      if (Get.isRegistered<HartaController>()) {
        Get.find<HartaController>().fetchGoals();
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''), backgroundColor: Colors.red[100], colorText: Colors.red[900]);
    }
  }

  String formatRupiah(double amount) {
    return "Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }
}
