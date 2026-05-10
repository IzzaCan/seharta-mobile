import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/manage_categories_controller.dart';

class ManageCategoriesView extends GetView<ManageCategoriesController> {
  const ManageCategoriesView({Key? key}) : super(key: key);

  // Palet Warna
  final Color primaryDark = const Color(0xFF0D2B33);
  final Color greenAccent = const Color(0xFF1F9975);
  final Color backgroundColor = const Color(0xFFF8F9FF);
  final Color cardColor = Colors.white;
  final Color borderColor = const Color(0xFFE0E5E9);
  final Color dangerRed = const Color(0xFFD32F2F); // Merah untuk tombol hapus
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
          'Kelola Kategori',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: primaryDark,
          ),
        ),
        centerTitle: false,
      ),

      
      // BODY UTAMA
      
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Toggle Switch (Pengeluaran vs Pemasukan)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Obx(
                      () => Row(
                        children: [
                          Expanded(
                            child: _buildToggleItem(
                              title: 'Pengeluaran',
                              isActive: controller.isExpense.value,
                              onTap: () => controller.toggleCategoryType(true),
                            ),
                          ),
                          Expanded(
                            child: _buildToggleItem(
                              title: 'Pemasukan',
                              isActive: !controller.isExpense.value,
                              onTap: () => controller.toggleCategoryType(false),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. Judul Section
                  Text(
                    'Kategori Default',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 3. List Kategori

                  // Item 1: Simulasi Sedang Di-Swipe (Sesuai Desain)
                  _buildSwipedItemMockup(
                    title: 'Makan',
                    subtitle: '12 Transaksi bulan ini',
                  ),
                  const SizedBox(height: 12),

                  // Item 2: Normal
                  _buildCategoryItem(
                    icon: Icons.lightbulb,
                    iconColor: Colors.amber,
                    iconBgColor: Colors.amber.withValues(alpha: 0.1),
                    title: 'Tagihan',
                    subtitle: '4 Transaksi bulan ini',
                  ),
                  const SizedBox(height: 12),

                  // Item 3: Normal
                  _buildCategoryItem(
                    icon: Icons.school,
                    iconColor: Colors.black87,
                    iconBgColor: Colors.grey[200]!,
                    title: 'Pendidikan',
                    subtitle: '1 Transaksi bulan ini',
                  ),
                  const SizedBox(height: 32),

                  // 4. Info Card: Tips Kelola Kategori
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: primaryDark,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            color: Colors.white54,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tips Kelola Kategori',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Geser kategori ke kiri untuk mengedit atau menghapus. Urutkan kategori dengan menekan lama (long press) lalu drag.',
                                style: TextStyle(
                                  fontSize: 10,
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
                  const SizedBox(height: 100), // Padding untuk Floating Button
                ],
              ),
            ),

            // 5. Floating Action Button (Tambah Kategori Baru) di tengah bawah
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: controller.addCategory,
                  icon: const Icon(Icons.add, color: Colors.white, size: 18),
                  label: const Text(
                    'Tambah Kategori Baru',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryDark,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 6,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  // WIDGET REUSABLE
  

  // Item Toggle (Pemasukan/Pengeluaran)
  Widget _buildToggleItem({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? bgLightGreen
              : Colors.transparent, // Warna hijau sangat pudar jika aktif
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isActive ? primaryDark : Colors.grey[500],
            ),
          ),
        ),
      ),
    );
  }

  // Item Kategori Normal
  Widget _buildCategoryItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
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
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
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
                  subtitle,
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
        ],
      ),
    );
  }

  // Simulasi UI Item yang Sedang Di-Swipe (Hanya Visual)
  Widget _buildSwipedItemMockup({
    required String title,
    required String subtitle,
  }) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
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
          // Bagian Kiri (Item Tergeser)
          Expanded(
            flex: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
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
                          subtitle,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[400],
                          ),
                        ), // Warna sedikit lebih pudar
                      ],
                    ),
                  ),
                  Icon(
                    Icons.drag_indicator,
                    color: Colors.grey[300],
                    size: 20,
                  ), // Drag handle
                ],
              ),
            ),
          ),
          // Tombol Edit (Abu-abu)
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: controller.editCategory,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0), // Abu-abu terang
                  border: const Border.symmetric(
                    horizontal: BorderSide(color: Color(0xFFE0E5E9)),
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.edit_outlined,
                    color: Color(0xFF4A5568),
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          // Tombol Hapus (Merah)
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: controller.deleteCategory,
              child: Container(
                decoration: BoxDecoration(
                  color: dangerRed,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
