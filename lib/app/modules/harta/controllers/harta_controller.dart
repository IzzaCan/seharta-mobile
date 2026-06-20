import 'package:get/get.dart';

class HartaController extends GetxController {
  // 0 = Aset Tetap, 1 = Goals
  var activeTab = 0.obs;

  void switchTab(int index) {
    activeTab.value = index;
  }

  void addAsset() {
    print("Membuka form tambah aset...");
  }

  // Tambahkan fungsi baru ini
  void addGoal() {
    print("Membuka form tambah goals...");
  }

  Future<void> refreshHarta() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  void askAISuggestion() {
    print("Minta saran AI untuk Dana Pendidikan Anak...");
  }
}
