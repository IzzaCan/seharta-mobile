import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/scan_receipt_controller.dart';

class ScanReceiptView extends GetView<ScanReceiptController> {
  const ScanReceiptView({Key? key}) : super(key: key);

  final Color primaryDark = const Color(0xFF0A1A1F); // Warna background gelap
  final Color greenNeon = const Color(0xFF4CFF8B); // Hijau neon untuk scanner

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDark,
      body: Stack(
        children: [
          
          // 1. BACKGROUND GAMBAR (SIMULASI KAMERA)
          
          Positioned.fill(
            child: Image.asset(
              'assets/images/struk.jpg', // Gambar struk Indomaret Anda
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Tampilan darurat jika gambar belum terdaftar di pubspec.yaml
                return Container(
                  color: Colors.grey[800],
                  child: const Center(
                    child: Text(
                      'Simulasi Kamera Berjalan',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),

          
          // 2. OVERLAY GELAP & BOUNDING BOX (KOTAK SCAN)
          
          Positioned.fill(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        // Kotak Utama (Viewfinder)
                        Container(
                          width: Get.width * 0.85,
                          height: Get.height * 0.55,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: greenNeon, width: 2.5),
                            // Trik membuat area luar kotak menjadi gelap transparan
                            boxShadow: [
                              BoxShadow(
                                color: primaryDark.withValues(alpha: 0.85),
                                spreadRadius: 2000,
                              ),
                            ],
                          ),
                        ),

                        // Badge Atas: Instruksi
                        Positioned(
                          top: 24,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Posisikan struk di dalam kotak',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        // Badge Bawah: Auto-fokus Aktif
                        Positioned(
                          bottom:
                              -15, // Dibuat menabrak garis bawah sesuai desain
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: greenNeon,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: greenNeon.withValues(alpha: 0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.document_scanner,
                                  color: primaryDark,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Auto-fokus aktif',
                                  style: TextStyle(
                                    color: primaryDark,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          
          // 3. TOP BAR (HEADER & IKON)
          
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Text
                    Row(
                      children: [
                        const Icon(
                          Icons.receipt_long,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Kamera Scan Struk',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Tombol Close & Flash
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 44), // Ruang kosong pengganti tombol close
                        Obx(
                          () => _buildGlassButton(
                            icon: controller.isFlashOn.value
                                ? Icons.flash_on
                                : Icons.flash_off,
                            iconColor: controller.isFlashOn.value
                                ? Colors.amber
                                : Colors.white,
                            onTap: controller.toggleFlash,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          
          // 4. BOTTOM BAR (TOMBOL ACTION)
          
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 24.0,
                  left: 32.0,
                  right: 32.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Tombol Galeri
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildGlassButton(
                          icon: Icons.photo_library_outlined,
                          onTap: controller.pickFromGallery,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Galeri',
                          style: TextStyle(color: Colors.white54, fontSize: 10),
                        ),
                      ],
                    ),

                    // Tombol Shutter Utama
                    GestureDetector(
                      onTap: controller.captureReceipt,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: Center(
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Tombol Batal
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildGlassButton(
                          icon: Icons.close,
                          onTap: controller.closeCamera,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Batal',
                          style: TextStyle(color: Colors.white54, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Komponen Reusable untuk tombol bulat dengan efek kaca (Glassmorphism)
  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }
}
