import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/select_status_controller.dart';

class SelectStatusView extends GetView<SelectStatusController> {
  const SelectStatusView({Key? key}) : super(key: key);

  final Color primaryColor = const Color(0xFF0D2B33); // Deep Teal
  final Color accentColor = const Color(0xFF2ECC71); // Mint Green
  final Color backgroundColor = const Color(0xFFF8F9FF);
  final Color cardBackgroundColor = Colors.white;
  final Color borderColor = const Color(0xFFE0E5E9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Pilih Status Anda',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Langkah pertama untuk mencapai kemapanan finansial bersama. Tentukan bagaimana Anda ingin memulai perjalanan ini.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Option 1: Buat Group Baru
              _buildOptionCard(
                title: 'Buat Group Baru',
                subtitle:
                    'Mulai kelola keuangan dari nol dan undang pasangan. Cocok untuk Anda yang baru memulai rencana anggaran mandiri.',
                onTap: controller.createNewGroup,
              ),
              const SizedBox(height: 16),

              // Option 2: Gabung Group
              _buildOptionCard(
                title: 'Gabung Group',
                subtitle:
                    'Masukkan kode dari pasangan untuk melihat dompet bersama. Hubungkan data secara instan dan mulai berkolaborasi.',
                onTap: controller.joinGroup,
              ),
              
              const Spacer(),

              // Footer Links
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Navigate to Kebijakan Privasi
                      },
                      child: Text(
                        'Kebijakan Privasi',
                        style: TextStyle(
                          fontSize: 12,
                          color: primaryColor,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        // Navigate to Syarat & Ketentuan
                      },
                      child: Text(
                        'Syarat & Ketentuan',
                        style: TextStyle(
                          fontSize: 12,
                          color: primaryColor,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
