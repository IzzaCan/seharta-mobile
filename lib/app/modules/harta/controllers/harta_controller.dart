import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/goal_model.dart';
import '../../wallet/providers/wallet_provider.dart';
import '../../../routes/app_pages.dart';

class HartaController extends GetxController {
  final WalletProvider _walletProvider = WalletProvider();

  // 0 = Aset Tetap, 1 = Goals
  var activeTab = 0.obs;
  
  var goals = <GoalModel>[].obs;
  var isLoadingGoals = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchGoals();
  }

  void switchTab(int index) {
    activeTab.value = index;
    if (index == 1 && goals.isEmpty) {
      fetchGoals();
    }
  }

  Future<void> fetchGoals() async {
    try {
      isLoadingGoals(true);
      final fetchedGoals = await _walletProvider.fetchGoals();
      goals.assignAll(fetchedGoals);
    } catch (e) {
      Get.snackbar(
        'Gagal Memuat Goals',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoadingGoals(false);
    }
  }

  void addAsset() {
    print("Membuka form tambah aset...");
  }

  void addGoal() {
    Get.toNamed(Routes.ADD_GOAL);
  }

  Future<void> refreshHarta() async {
    if (activeTab.value == 1) {
      await fetchGoals();
    } else {
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  void askAISuggestion() {
    print("Minta saran AI untuk Dana Pendidikan Anak...");
  }
}
