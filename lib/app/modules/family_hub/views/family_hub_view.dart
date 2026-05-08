import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/family_hub_controller.dart';

class FamilyHubView extends GetView<FamilyHubController> {
  const FamilyHubView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF), // background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF006D37).withOpacity(0.1), // secondary/10
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.celebration, color: Color(0xFF006D37), size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'SELAMAT DATANG DI SEHARTA',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF006D37),
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Title
                const Text(
                  'Pilih Status Keuangan Anda',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0D2B33), // primary-container
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Subtitle
                const Text(
                  'Langkah pertama untuk mencapai kemapanan finansial bersama. Tentukan bagaimana Anda ingin memulai perjalanan ini.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18, // body-lg
                    color: Color(0xFF42484A), // on-surface-variant
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Cards
                _buildOptionCard(
                  title: 'Buat Keluarga Baru',
                  description: 'Mulai kelola keuangan dari nol dan undang pasangan. Cocok untuk Anda yang baru memulai rencana anggaran mandiri.',
                  imagePath: 'assets/buat_keluarga_baru.jpg',
                  topIcon: Icons.house,
                  bottomIcons: [Icons.person, Icons.add],
                  bottomText: 'Gunakan sebagai Admin',
                  onTap: () {
                    // TODO: Navigate to create family
                  },
                ),
                const SizedBox(height: 24),
                _buildOptionCard(
                  title: 'Gabung Keluarga',
                  description: 'Masukkan kode dari pasangan untuk melihat dompet bersama. Hubungkan data secara instan dan mulai berkolaborasi.',
                  imagePath: 'assets/gabung_keluarga.jpg',
                  topIcon: Icons.qr_code_scanner,
                  bottomIcons: [Icons.group],
                  bottomText: 'Hubungkan Akun Aktif',
                  onTap: () {
                    // TODO: Navigate to join family
                  },
                ),
                
                const SizedBox(height: 64),
                
                // Help Text
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.help_outline, color: Color(0xFF72787A), size: 18),
                  label: const Text(
                    'Butuh bantuan? Pelajari cara kerja Seharta',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12, // label-caps
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF72787A), // outline
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF00161C), // primary on hover
                  ),
                ),
                
                const SizedBox(height: 40),
                // Footer
                const Divider(color: Color(0xFFC1C7CA)), // outline-variant
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Seharta',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 24, // h3
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0D2B33),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 16,
                          color: const Color(0xFFC1C7CA),
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        const Text(
                          'ONBOARDING EXPERIENCE',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF72787A),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: const Color(0xFF006D37), // secondary on hover
                      ),
                      child: const Text(
                        'Kebijakan Privasi',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12, // label-caps
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF72787A), // outline
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: const Color(0xFF006D37), // secondary on hover
                      ),
                      child: const Text(
                        'Syarat & Ketentuan',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12, // label-caps
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF72787A), // outline
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String description,
    required String imagePath,
    required IconData topIcon,
    required List<IconData> bottomIcons,
    required String bottomText,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC1C7CA), width: 1), // outline-variant
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              Container(
                height: 180, // Aspect video approximate
                width: double.infinity,
                color: const Color(0xFFEFF4FF), // surface-container-low
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Icon(Icons.image_not_supported, color: Colors.grey));
                      },
                    ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.transparent,
                            Colors.white.withOpacity(0.4),
                          ],
                        ),
                      ),
                    ),
                    // Top Icon
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(topIcon, color: const Color(0xFF0D2B33), size: 32),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Text Content Section
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 24, // h3
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0D2B33), // primary-container
                          ),
                        ),
                        const Icon(Icons.arrow_forward, color: Color(0xFF006D37)), // secondary
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16, // body-md
                        color: Color(0xFF42484A), // on-surface-variant
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Bottom Section
                    Row(
                      children: [
                        // Stacked Icons
                        SizedBox(
                          width: 24.0 + (16.0 * (bottomIcons.length - 1)),
                          height: 32,
                          child: Stack(
                            children: List.generate(bottomIcons.length, (index) {
                              return Positioned(
                                left: index * 16.0,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: index == bottomIcons.length - 1 && bottomIcons.length > 1
                                        ? const Color(0xFF006D37).withOpacity(0.1) // secondary/10
                                        : const Color(0xFFDCE9FF), // surface-container-high
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: Icon(
                                    bottomIcons[index],
                                    size: 16,
                                    color: index == bottomIcons.length - 1 && bottomIcons.length > 1
                                        ? const Color(0xFF006D37)
                                        : const Color(0xFF0B1C30),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          bottomText,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12, // label-caps
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF72787A), // outline
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
