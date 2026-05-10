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

  void askAISuggestion() {
    print("Minta saran AI untuk Dana Pendidikan Anak...");
  }
}
