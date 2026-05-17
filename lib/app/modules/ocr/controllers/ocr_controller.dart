import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../../../routes/app_pages.dart';

class OcrController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  
  CameraController? cameraController;
  var isCameraInitialized = false.obs;
  var isFlashOn = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        // Gunakan kamera belakang utama
        cameraController = CameraController(
          cameras.first,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await cameraController!.initialize();
        isCameraInitialized.value = true;
      } else {
        Get.snackbar(
          'Kamera Tidak Ditemukan',
          'Perangkat tidak memiliki kamera aktif.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Gagal Inisialisasi Kamera',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void toggleFlash() async {
    if (cameraController == null || !isCameraInitialized.value) return;
    try {
      isFlashOn.value = !isFlashOn.value;
      await cameraController!.setFlashMode(
        isFlashOn.value ? FlashMode.torch : FlashMode.off,
      );
    } catch (e) {
      print("Gagal mengubah flash: $e");
    }
  }

  Future<void> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // Kompres sedikit untuk mempercepat upload jaringan
      );
      
      if (image != null) {
        // Hancurkan halaman kamera dan buka halaman loading (melepaskan semua resource)
        Get.offNamed(Routes.LOADING_OCR, arguments: image.path);
      }
    } catch (e) {
      Get.snackbar(
        'Gagal Membuka Galeri',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> captureReceipt() async {
    if (cameraController == null || !isCameraInitialized.value) {
      Get.snackbar(
        'Kamera Belum Siap',
        'Mohon tunggu hingga kamera selesai memuat.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      // Ambil foto langsung dari inline CameraPreview
      final XFile image = await cameraController!.takePicture();
      
      // Hancurkan halaman kamera dan buka halaman loading (melepaskan semua resource & file lock)
      Get.offNamed(Routes.LOADING_OCR, arguments: image.path);
    } catch (e) {
      Get.snackbar(
        'Gagal Mengambil Gambar',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void closeCamera() {
    Get.back();
  }

  @override
  void onClose() {
    // Matikan lampu flash jika menyala sebelum keluar
    if (cameraController != null && isFlashOn.value) {
      cameraController!.setFlashMode(FlashMode.off);
    }
    cameraController?.dispose();
    super.onClose();
  }
}
