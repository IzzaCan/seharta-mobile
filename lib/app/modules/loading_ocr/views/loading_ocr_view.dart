import 'dart:io';
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
          'Analisis Struk Belanja',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        centerTitle: false,
      ),

      // FLAT BOTTOM NAVIGATION (Sesuai mockup)
      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
              // 1. Ilustrasi dengan live preview gambar asli
              _buildReceiptPreview(),
              const SizedBox(height: 32),

              // 2. Teks Status Dinamis
              Obx(() => Text(
                    controller.progressStatus.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  )),
              const SizedBox(height: 8),
              Text(
                'Tunggu sebentar, Seharta sedang\nmengekstraksi data transaksi Anda.',
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
              // Dots loading tambahan
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDot(greenAccent),
                  const SizedBox(width: 4),
                  _buildDot(greenAccent.withOpacity(0.5)),
                  const SizedBox(width: 4),
                  _buildDot(greenAccent.withOpacity(0.2)),
                ],
              ),
              const SizedBox(height: 48),

              // 4. Kartu Informasi File & Model Dinamis
              _buildInfoCard(
                icon: Icons.insert_drive_file_outlined,
                title: 'NAMA FILE',
                value: controller.imagePath.split(Platform.pathSeparator).last,
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.memory_outlined,
                title: 'MODEL AI OCR',
                value: 'Gemini 3.5 Flash',
              ),
            ],
          ),
        ),
      ),
    );
  }

  
  // WIDGET REUSABLE
  

  // Widget untuk menampilkan preview gambar struk asli dengan neon scanning line
  Widget _buildReceiptPreview() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Live Receipt Image Preview dengan border dan shadow premium
        Container(
          width: 150,
          height: 200,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              File(controller.imagePath),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: Colors.grey[400],
                    size: 40,
                  ),
                );
              },
            ),
          ),
        ),
        
        // Efek garis hijau scanning (neon)
        Positioned(
          top: 25,
          left: -10,
          right: -10,
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              color: greenAccent,
              boxShadow: [
                BoxShadow(
                  color: greenAccent.withOpacity(0.6),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
        
        // Badge AI/Star (Pojok Kanan Atas)
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
          Expanded(
            child: Column(
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
