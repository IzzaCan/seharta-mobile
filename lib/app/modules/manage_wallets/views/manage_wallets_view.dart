import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/manage_wallets_controller.dart';

class ManageWalletsView extends GetView<ManageWalletsController> {
  const ManageWalletsView({Key? key}) : super(key: key);

  // Palet Warna
  final Color primaryDark = const Color(0xFF0D2B33); // Dark Teal
  final Color greenAccent = const Color(0xFF1F9975); // Emerald Green
  final Color backgroundColor = const Color(0xFFF8F9FF);
  final Color cardColor = Colors.white;
  final Color borderColor = const Color(0xFFE0E5E9);
  final Color bgLightGreen = const Color(0xFFE8F5EE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      // APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryDark, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Kelola Dompet Keluarga',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: primaryDark,
          ),
        ),
        centerTitle: false,
      ),

      // FLOATING ACTION BUTTON (Pill Shaped)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.addWallet,
        backgroundColor: primaryDark,
        elevation: 4,
        icon: Icon(Icons.add, color: greenAccent, size: 20),
        label: Text(
          'Tambah Dompet',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: greenAccent,
          ),
        ),
      ),

      // BODY UTAMA
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Card: Ringkasan Aset (Dengan Watermark Icon)
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: primaryDark,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryDark.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Watermark Ikon Dompet di Kanan
                    Positioned(
                      right: -15,
                      bottom: -20,
                      child: Transform.rotate(
                        angle: -0.2, // Sedikit dimiringkan
                        child: Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 100,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    // Teks Konten
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Ringkasan Aset',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: greenAccent,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Kelola sumber dana keluarga Anda\ndengan transparan dan teratur.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 2. Section Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'DOMPET AKTIF',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    '2 Terdaftar',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: greenAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 3. List Dompet
              _buildWalletItem(
                icon: Icons.credit_card,
                title: 'BCA Keluarga',
                balance: 'Rp5.000.000',
                onEdit: () => controller.editWallet('BCA Keluarga'),
              ),
              const SizedBox(height: 12),
              _buildWalletItem(
                icon: Icons.money,
                iconBgColor: const Color(0xFFE3F2FD), // Biru sangat muda
                iconColor: Colors.blueGrey,
                title: 'Kas Tunai',
                balance: 'Rp500.000',
                onEdit: () => controller.editWallet('Kas Tunai'),
              ),
              const SizedBox(height: 24),

              // 4. Info Card Bawah
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bgLightGreen,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: greenAccent.withValues(alpha: 0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: greenAccent, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Anda dapat memisahkan dompet untuk pengeluaran rutin dan tabungan masa depan keluarga.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 80,
              ), // Ruang ekstra agar list tidak tertutup FAB
            ],
          ),
        ),
      ),
    );
  }

  // WIDGET REUSABLE

  Widget _buildWalletItem({
    required IconData icon,
    required String title,
    required String balance,
    Color? iconBgColor,
    Color? iconColor,
    required VoidCallback onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: primaryDark.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor ?? const Color(0xFFF0F4F8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor ?? primaryDark, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: primaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  balance,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: greenAccent,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, color: Colors.grey[400], size: 20),
            onPressed: onEdit,
            constraints:
                const BoxConstraints(), // Mengurangi padding bawaan IconButton
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
