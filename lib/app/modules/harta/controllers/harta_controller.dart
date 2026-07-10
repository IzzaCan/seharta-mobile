import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/goal_model.dart';
import '../models/asset_model.dart';
import '../../../data/providers/wallet_provider.dart';
import '../../../data/models/wallet_model.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';

List<AssetModel> _parseAssets(List<dynamic> data) {
  return data.map((json) => AssetModel.fromJson(json)).toList();
}

class HartaController extends GetxController {
  final WalletProvider _walletProvider = WalletProvider();
  final ApiProvider _apiProvider = ApiProvider();
  final AuthService _authService = Get.find<AuthService>();

  // 0 = Aset Tetap, 1 = Goals
  var activeTab = 0.obs;

  String get currentUserId => _authService.currentUser.value?.id ?? '';
  
  var goals = <GoalModel>[].obs;
  var isLoadingGoals = false.obs;

  var assets = <AssetModel>[].obs;
  var isLoadingAssets = false.obs;

  var wallets = <WalletModel>[].obs;
  var isLoadingWallets = false.obs;

  double get totalKekayaan {
    double totalAssets = assets.fold(0.0, (sum, item) => sum + item.purchasePrice);
    double totalWallets = wallets.fold(0.0, (sum, item) => item.isActive ? sum + item.balance : sum);
    return totalAssets + totalWallets;
  }

  @override
  void onInit() {
    super.onInit();
    fetchAssets();
    fetchWallets();
  }

  void switchTab(int index) {
    activeTab.value = index;
    if (index == 0 && assets.isEmpty) {
      fetchAssets();
      fetchWallets();
    } else if (index == 1 && goals.isEmpty) {
      fetchGoals();
    }
  }

  Future<void> fetchAssets() async {
    try {
      isLoadingAssets(true);
      final token = _authService.accessToken.value;
      if (token.isEmpty) throw 'Sesi telah berakhir';
      
      final response = await _apiProvider.getAssets(token: token);
      final List<dynamic> data = response['data'] as List<dynamic>? ?? [];
      
      final fetchedAssets = await compute(_parseAssets, data);
      assets.assignAll(fetchedAssets);
    } catch (e) {
      Get.snackbar(
        'Gagal Memuat Aset',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoadingAssets(false);
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
    Get.toNamed(Routes.ADD_ASSET);
  }

  Future<void> deleteAsset(String id) async {
    try {
      final token = _authService.accessToken.value;
      await _apiProvider.deleteAsset(id: id, token: token);
      assets.removeWhere((a) => a.id == id);
      Get.snackbar('Sukses', 'Aset berhasil dihapus', backgroundColor: const Color(0xFF1F9975), colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Gagal Menghapus Aset', e.toString(), backgroundColor: Colors.red[100], colorText: Colors.red[900]);
    }
  }

  void addGoal() {
    Get.toNamed(Routes.ADD_GOAL);
  }

  Future<void> fetchWallets() async {
    try {
      isLoadingWallets(true);
      final fetchedWallets = await _walletProvider.fetchWallets();
      wallets.assignAll(fetchedWallets);
    } catch (e) {
      print("Gagal memuat dompet untuk kalkulasi harta: $e");
    } finally {
      isLoadingWallets(false);
    }
  }

  Future<void> refreshHarta() async {
    if (activeTab.value == 0) {
      await Future.wait([
        fetchAssets(),
        fetchWallets(),
      ]);
    } else {
      await fetchGoals();
    }
  }

  void askAISuggestion() {
    print("Minta saran AI untuk Dana Pendidikan Anak...");
  }
}
