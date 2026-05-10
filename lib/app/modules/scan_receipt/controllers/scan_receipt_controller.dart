import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class ScanReceiptController extends GetxController {
  // State untuk flash kamera
  var isFlashOn = false.obs;

  void toggleFlash() {
    isFlashOn.value = !isFlashOn.value;
    print("Flash status: ${isFlashOn.value ? 'ON' : 'OFF'}");
  }

  void pickFromGallery() {
    print("Membuka galeri HP...");
    // Simulasi langsung ke loading ocr
    Get.offNamed(Routes.LOADING_OCR);
  }

  void captureReceipt() {
    print("Mengambil foto struk...");
    // Navigasi ke halaman loading OCR
    Get.offNamed(Routes.LOADING_OCR);
  }

  void closeCamera() {
    Get.back();
  }
}
