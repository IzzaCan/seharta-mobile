import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/select_status_controller.dart';

class SelectStatusView extends GetView<SelectStatusController> {
  const SelectStatusView({Key? key}) : super(key: key);

  final Color primaryColor = const Color(0xFF0F2C36);
  final Color greenAccent = const Color(0xFF1F9975);
  final Color bgLightGreen = const Color(0xFFE8F5EE);
  final Color bgColor = const Color(0xFFF4F7FB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Badge "Selamat Datang"
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: bgLightGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.spa, size: 14, color: greenAccent),
                    const SizedBox(width: 6),
                    Text(
                      'SELAMAT DATANG DI SEHARTA',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: greenAccent,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2. Judul & Subjudul
              Text(
                'Pilih Status\nKeuangan Anda',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Langkah pertama untuk mencapai\nkemapanan finansial bersama. Tentukan\nbagaimana Anda ingin memulai\nperjalanan ini.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // 3. Card 1: Buat Keluarga Baru
              // PASTIKAN path string di bawah ini sesuai dengan folder proyek Anda
              _buildStatusCard(
                onTap: controller.createNewGroup,
                imageUrl: 'images/buatkeluarga.png', // <--- Gunakan local asset
                floatingIcon: Icons.home_outlined,
                title: 'Buat Keluarga Baru',
                description:
                    'Mulai kelola keuangan dari nol dan undang pasangan. Cocok untuk Anda yang baru memulai rencana anggaran mandiri.',
                footerIcon: Icons.person_add_alt_1,
                footerText: 'Gunakan sebagai Admin',
              ),
              const SizedBox(height: 20),

              // 4. Card 2: Gabung Keluarga
              // PASTIKAN path string di bawah ini sesuai dengan folder proyek Anda
              _buildStatusCard(
                onTap: controller.joinGroup,
                imageUrl:
                    'images/gabungkeluarga.png', // <--- Gunakan local asset
                floatingIcon: Icons.qr_code_scanner,
                title: 'Gabung Keluarga',
                description:
                    'Masukkan kode dari pasangan untuk melihat dompet bersama. Hubungkan data secara instan dan mulai berkolaborasi.',
                footerIcon: Icons.people_alt_outlined,
                footerText: 'Hubungkan Akun Aktif',
              ),
              const SizedBox(height: 40),

              // 5. Bantuan & Footer
              GestureDetector(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Butuh bantuan? Pelajari cara kerja Seharta ',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                    Icon(Icons.help_outline, size: 14, color: Colors.grey[700]),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              const Divider(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Seharta',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text('|', style: TextStyle(color: Colors.grey[400])),
                  ),
                  Text(
                    'ONBOARDING EXPERIENCE',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Kebijakan Privasi',
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Syarat & Ketentuan',
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // WIDGET REUSABLE UNTUK CARD MENGGUNAKAN IMAGE.ASSET
  Widget _buildStatusCard({
    required String title,
    required String description,
    required String imageUrl,
    required IconData floatingIcon,
    required IconData footerIcon,
    required String footerText,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        // Tambahan Padding di sini agar gambar tidak menempel ke tepi card
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar Aset Lokal dan Ikon Melayang di pojok
              Stack(
                children: [
                  ClipRRect(
                    // Membuat semua pinggiran gambar melengkung (circular)
                    borderRadius: BorderRadius.circular(12),
                    // Menggunakan AspectRatio 2.0 agar tinggi gambar menjadi setengah dari lebar
                    child: AspectRatio(
                      aspectRatio: 1.29,
                      child: Container(
                        color: Colors
                            .grey[100], // Warna dasar jika gambar transparan
                        child: Image.asset(
                          imageUrl,
                          // BoxFit.cover memastikan gambar tidak gepeng, melainkan tercrop rapi sesuai kotak
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey[400],
                                size: 40,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(floatingIcon, color: primaryColor, size: 20),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Konten Teks di bawah gambar
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
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),

              // Footer Info
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(footerIcon, size: 14, color: primaryColor),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    footerText,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
