import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/add_transaction_controller.dart';
import '../../../routes/app_pages.dart';

class AddTransactionView extends GetView<AddTransactionController> {
  const AddTransactionView({Key? key}) : super(key: key);

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
      
      // BOTTOM NAVIGATION BAR (Sesuai desain)
      

      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                label: 'HOME',
                isActive: false,
                onTap: () => Get.offAllNamed(Routes.HOME),
              ),
              _buildNavItem(
                icon: Icons.account_balance_wallet_outlined,
                label: 'HARTA',
                isActive: false,
                onTap: () => Get.offAllNamed(Routes.HARTA),
              ),

              _buildNavItem(
                icon: Icons.bar_chart_rounded,
                label: 'ANALYTICS',
                isActive: false,
                onTap: () => Get.offAllNamed(Routes.ANALYTICS),
              ),
              _buildNavItem(
                icon: Icons.person_outline,
                label: 'PROFILE',
                isActive: false,
                onTap: () => Get.offAllNamed(Routes.PROFILE),
              ),
            ],
          ),
        ),
      ),

      
      // BODY / KONTEN UTAMA
      
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header (Identitas Pasangan)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Stack(
                          children: [
                            const CircleAvatar(
                              radius: 12,
                              backgroundImage: NetworkImage(
                                'https://i.pravatar.cc/100?img=11',
                              ),
                            ),
                            Positioned(
                              left: 14,
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.white,
                                child: const CircleAvatar(
                                  radius: 10,
                                  backgroundImage: NetworkImage(
                                    'https://i.pravatar.cc/100?img=5',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Seharta',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.notifications_none, color: primaryColor, size: 20),
                ],
              ),
              const SizedBox(height: 32),

              // 2. Judul Halaman
              Text(
                'Input Transaksi',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Catat pengeluaran atau pemasukan Anda secara detail.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // 3. Tombol Scan Struk (AI)
              GestureDetector(
                onTap: controller.openOcrScanner,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    // Catatan: Gunakan package dotted_border jika ingin garis putus-putus
                    border: Border.all(
                      color: greenAccent.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: bgLightGreen,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt_outlined,
                          color: greenAccent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Scan Struk (AI)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Catat otomatis dari foto struk',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 4. Toggle Pengeluaran vs Pemasukan
              Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: _buildToggleButton(
                        title: 'PENGELUARAN',
                        icon: Icons.arrow_downward,
                        isActive: controller.isExpense.value,
                        onTap: () => controller.toggleTransactionType(true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildToggleButton(
                        title: 'PEMASUKAN',
                        icon: Icons.arrow_upward,
                        isActive: !controller.isExpense.value,
                        onTap: () => controller.toggleTransactionType(false),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 5. Input Card: JUMLAH (RP)
              _buildInputContainer(
                label: 'JUMLAH (RP)',
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Rp',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: controller.amountController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                        decoration: const InputDecoration(
                          hintText: '0',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 6. Input Card: KATEGORI
              _buildInputContainer(
                label: 'KATEGORI',
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: bgLightGreen,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.restaurant,
                        color: greenAccent,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Obx(
                      () => Expanded(
                        child: Text(
                          controller.selectedCategory.value,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 7. Input Card: DOMPET
              _buildInputContainer(
                label: 'DOMPET',
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_outlined,
                        color: Colors.blueGrey,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Obx(
                      () => Expanded(
                        child: Text(
                          controller.selectedWallet.value,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 8. Input Card: CATATAN
              _buildInputContainer(
                label: 'CATATAN (OPSIONAL)',
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.notes, color: Colors.grey[400], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: controller.noteController,
                        style: TextStyle(fontSize: 14, color: primaryColor),
                        decoration: InputDecoration(
                          hintText: 'Tulis keterangan di sini...',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 9. Tanggal & Waktu
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    color: greenAccent,
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Hari ini, 24 Mei 2024 • 14:20',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 10. Tombol Simpan Transaksi
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: controller.saveTransaction,
                  icon: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: const Text(
                    'Simpan Transaksi',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 40), // Ruang ekstra untuk Bottom Nav
            ],
          ),
        ),
      ),
    );
  }

  
  // REUSABLE WIDGETS
  

  // Komponen Navigasi Bawah
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              color: isActive ? primaryColor : Colors.grey[400], size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? primaryColor : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // Toggle Button (Pengeluaran / Pemasukan)
  Widget _buildToggleButton({
    required String title,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? bgLightGreen : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isActive ? greenAccent : borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? greenAccent : Colors.grey[500],
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isActive ? greenAccent : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Container Standar untuk Kolom Input
  Widget _buildInputContainer({required String label, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey[500],
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
