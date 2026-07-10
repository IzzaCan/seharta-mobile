import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/providers/wallet_provider.dart';
import '../../harta/controllers/harta_controller.dart';

class AddGoalController extends GetxController {
  final WalletProvider _walletProvider = WalletProvider();
  
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  
  var selectedDate = Rxn<DateTime>();
  var isLoading = false.obs;

  @override
  void onClose() {
    nameController.dispose();
    amountController.dispose();
    noteController.dispose();
    super.onClose();
  }

  void pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D2B33),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0D2B33),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  String get formattedDate {
    if (selectedDate.value == null) return "Pilih Tanggal";
    return DateFormat('yyyy-MM-dd').format(selectedDate.value!);
  }

  String get displayDate {
    if (selectedDate.value == null) return "Pilih Tanggal (Opsional)";
    return DateFormat('dd MMMM yyyy').format(selectedDate.value!);
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    
    final name = nameController.text.trim();
    final amountText = amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = double.tryParse(amountText);
    
    if (amount == null || amount <= 0) {
      Get.snackbar(
        'Error',
        'Target uang tidak valid',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return;
    }

    try {
      isLoading(true);
      await _walletProvider.createGoal(
        name: name,
        targetAmount: amount,
        deadline: selectedDate.value != null ? DateFormat('yyyy-MM-dd').format(selectedDate.value!) : null,
        note: noteController.text.trim().isNotEmpty ? noteController.text.trim() : null,
      );
      
      // Refresh list
      if (Get.isRegistered<HartaController>()) {
        Get.find<HartaController>().fetchGoals();
      }
      
      Get.back(); // Pop the AddGoalView first
      Get.snackbar(
        'Berhasil',
        'Target tabungan berhasil dibuat',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
      );
    } catch (e) {
      Get.snackbar(
        'Gagal Menyimpan',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading(false);
    }
  }
}
