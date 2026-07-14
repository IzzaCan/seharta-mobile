import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:seharta/app/data/providers/api_provider.dart';
import 'package:seharta/app/data/services/auth_service.dart';
import 'package:seharta/app/routes/app_pages.dart';
import 'package:seharta/app/data/models/user_model.dart';
import 'package:seharta/app/modules/harta/models/asset_model.dart';
import 'package:seharta/app/data/providers/wallet_provider.dart';

class DisconnectConfirmationController extends GetxController {
  final ApiProvider _apiProvider = ApiProvider();
  final AuthService _authService = Get.find<AuthService>();

  // Checkboxes state
  final isChecked1 = false.obs;
  final isChecked2 = false.obs;
  final isChecked3 = false.obs;

  // Summary state
  final totalJointAssets = 0.obs;
  final jointAssetValuation = 0.0.obs;
  final totalJointWallets = 0.obs;
  final jointWalletBalance = 0.0.obs;
  
  final isLoadingSummary = true.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchSummary();
  }

  bool get canProceed => isChecked1.value && isChecked2.value && isChecked3.value;

  Future<void> _fetchSummary() async {
    try {
      isLoadingSummary.value = true;
      final token = _authService.accessToken.value;
      if (token.isEmpty) return;

      // 1. Fetch Assets
      final assetsResponse = await _apiProvider.getAssets(token: token);
      final List<dynamic> assetsData = assetsResponse['data'] as List<dynamic>? ?? [];
      final fetchedAssets = assetsData.map((json) => AssetModel.fromJson(json)).toList();
      
      final jointAssets = fetchedAssets.where((a) => a.ownershipType == 'JOINT').toList();
      totalJointAssets.value = jointAssets.length;
      jointAssetValuation.value = jointAssets.fold(0.0, (sum, item) => sum + item.purchasePrice);

      // 2. Fetch Wallets
      final walletProvider = WalletProvider();
      final fetchedWallets = await walletProvider.fetchWallets();
      totalJointWallets.value = fetchedWallets.length;
      jointWalletBalance.value = fetchedWallets.fold(0.0, (sum, item) => sum + item.balance);

    } catch (e) {
      print("Error fetching summary: $e");
    } finally {
      isLoadingSummary.value = false;
    }
  }

  void toggleCheck1(bool? value) => isChecked1.value = value ?? false;
  void toggleCheck2(bool? value) => isChecked2.value = value ?? false;
  void toggleCheck3(bool? value) => isChecked3.value = value ?? false;

  Future<void> disconnectFamilyAccount() async {
    if (!canProceed) return;

    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );

    try {
      final response = await _apiProvider.unlinkFamilyAccount();
      
      // Close loading dialog
      Get.back();

      if (response != null && response['status'] == 'success') {
        // Update user state local storage directly since clearFamilyState doesn't exist
        final user = _authService.currentUser.value;
        if (user != null) {
          final updatedUser = UserModel(
            id: user.id,
            fullName: user.fullName,
            email: user.email,
            avatarUrl: user.avatarUrl,
            familyId: null,
            isActive: user.isActive,
            isVerified: user.isVerified,
            createdAt: user.createdAt,
            updatedAt: user.updatedAt,
          );
          _authService.currentUser.value = updatedUser;
        }

        Get.defaultDialog(
          title: "Berhasil Diputus",
          middleText: "Tautan keluarga berhasil diputus. Dokumen Berita Acara penyelesaian aset telah dikirim ke email masing-masing.",
          textConfirm: "Tutup & Keluar",
          confirmTextColor: Get.theme.colorScheme.onPrimary,
          onConfirm: () {
            // Logout and route to login
            _authService.logout();
            Get.offAllNamed(Routes.LOGIN);
          },
          barrierDismissible: false,
        );
      } else {
        Get.snackbar(
          'Gagal',
          response?['message'] ?? 'Terjadi kesalahan saat memutus tautan',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
      }
    } catch (e) {
      Get.back(); // Close loading
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }
}
