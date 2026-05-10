import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/loading_ocr_controller.dart';

class LoadingOcrView extends GetView<LoadingOcrController> {
  const LoadingOcrView({Key? key}) : super(key: key);

  // Palet Warna
  final Color primaryColor = const Color(0xFF0D2B33); // Dark Teal
  final Color greenAccent = const Color(0xFF2ECC71); // Emerald Green
  final Color bgLightGreen = const Color(0xFFE8F5EE);
  final Color backgroundColor = const Color(0xFFF8F9FF);
  final Color cardColor = Colors.white;
  final Color borderColor = const Color(0xFFE0E5E9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      
      // APP BAR Sederhana
      
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor, size: 20),
          onPressed: controller.cancelProcess,
        ),
        title: Text(
          'Tambah Transaksi',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        centerTitle: false,
      ),

      
      // FLAT BOTTOM NAVIGATION (Sesuai mockup spesifik ini)
      
      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(Icons.home_outlined, color: Colors.grey[400], size: 24),
            Icon(
              Icons.account_balance_wallet_outlined,
              color: Colors.grey[400],
              size: 24,
            ),
            // Tombol Add di tengah yang flat (tanpa notch/mengambang)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgLightGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_circle_outline,
                color: primaryColor,
                size: 24,
              ),
            ),
            Icon(Icons.bar_chart_rounded, color: Colors.grey[400], size: 24),
            Icon(Icons.person_outline, color: Colors.grey[400], size: 24),
          ],
        ),
      ),

      
      // BODY UTAMA
      
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Ilustrasi Animasi Struk (Dibuat murni dengan Widget)
              _buildReceiptIllustration(),
              const SizedBox(height: 32),

              // 2. Teks Status
              Text(
                'Sedang Membaca Struk...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tunggu sebentar, Seharta sedang\nmengekstraksi data Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // 3. Loading Indicator
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(greenAccent),
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              // Dots loading tambahan (Simulasi visual)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDot(greenAccent),
                  const SizedBox(width: 4),
                  _buildDot(greenAccent.withValues(alpha: 0.5)),
                  const SizedBox(width: 4),
                  _buildDot(greenAccent.withValues(alpha: 0.2)),
                ],
              ),
              const SizedBox(height: 48),

              // 4. Kartu Informasi File & Model
              _buildInfoCard(
                icon: Icons.insert_drive_file_outlined,
                title: 'NAMA FILE',
                value: 'receipt_2023_10.jpg',
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.memory_outlined,
                title: 'MODEL AI',
                value: 'Seharta OCR v2.4',
              ),
            ],
          ),
        ),
      ),
    );
  }

  
  // WIDGET REUSABLE
  

  // Widget untuk menggambar ilustrasi struk secara manual (tanpa aset gambar)
  Widget _buildReceiptIllustration() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Kertas Struk
        Container(
          width: 140,
          height: 180,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 6,
                width: double.infinity,
                color: Colors.grey[100],
              ),
              const SizedBox(height: 8),
              // Efek garis hijau scanning
              Container(
                height: 2,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: greenAccent.withValues(alpha: 0.5),
                  boxShadow: [
                    BoxShadow(
                      color: greenAccent.withValues(alpha: 0.3),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(height: 4, width: 80, color: Colors.grey[100]),
              const SizedBox(height: 8),
              Container(height: 4, width: 100, color: Colors.grey[100]),
              const SizedBox(height: 8),
              Container(height: 4, width: 90, color: Colors.grey[100]),
              const SizedBox(height: 8),
              Container(height: 4, width: 60, color: Colors.grey[100]),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(height: 8, width: 40, color: bgLightGreen),
                  Container(height: 8, width: 20, color: bgLightGreen),
                ],
              ),
            ],
          ),
        ),
        // Badge Bintang / AI (Pojok Kanan Atas)
        Positioned(
          top: -10,
          right: -10,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }

  // Titik loading kecil
  Widget _buildDot(Color color) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  // Kartu info (Nama File & Model AI)
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4F8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blueGrey, size: 18),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[500],
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
