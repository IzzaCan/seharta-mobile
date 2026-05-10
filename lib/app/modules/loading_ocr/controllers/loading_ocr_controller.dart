import 'package:get/get.dart';

class LoadingOcrController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _simulateLoading();
  }

  void _simulateLoading() {
    // Simulasi proses OCR dan AI selama 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      print("Proses OCR Selesai!");
      // Nanti ganti dengan Get.offNamed('/add-transaction', arguments: parsedData);
      Get.back(); // Kembali secara sementara untuk testing
      Get.snackbar(
        "Sukses",
        "Data struk berhasil diekstrak!",
        snackPosition: SnackPosition.TOP,
      );
    });
  }

  void cancelProcess() {
    print("Membatalkan proses scan...");
    Get.back();
  }
}
