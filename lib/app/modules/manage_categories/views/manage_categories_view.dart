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
  final Color dangerRed = const Color(0xFFD32F2F);
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
                    child: GetBuilder<ManageCategoriesController>(
                      builder: (controller) => Row(
                        children: [
                          Expanded(
                            child: _buildToggleItem(
                              title: 'Pengeluaran',
                              isActive: controller.isExpense,
                              onTap: () => controller.toggleCategoryType(true),
                            ),
                          ),
                          Expanded(
                            child: _buildToggleItem(
                              title: 'Pemasukan',
                              isActive: !controller.isExpense,
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
                    'Daftar Kategori',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

// 3. List Kategori Dinamis Obx (Diperbarui menggunakan Column Mapping)
                  GetBuilder<ManageCategoriesController>(
                    builder: (controller) {
                    // Menyaring kategori berdasarkan tipe yang dipilih (Expense/Income)
                    final filteredCategories = controller.categories
                        .where((c) => c['isExpense'] == controller.isExpense)
                        .toList();

                    if (filteredCategories.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            'Belum ada kategori.',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }

                    // Menggunakan Column + Map untuk menjamin kelancaran sistem Gesture/Tap Detector
                    return Column(
                      children: filteredCategories.map((category) {
                        final isSelected = controller.selectedCategory == category['title'];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0), // Sebagai pengganti separatorBuilder
                          child: _buildDynamicCategoryItem(
                            icon: category['icon'],
                            iconColor: category['color'],
                            title: category['title'],
                            subtitle: category['subtitle'],
                            isSelected: isSelected,
                            onTap: () {
                              controller.selectCategory(category['title']);
                            },
                          ),
                        );
                      }).toList(),
                    );
                  }),
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
                                'Tekan salah satu kategori di atas untuk memunculkan opsi Edit dan Hapus dengan cepat.',
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
                  const SizedBox(height: 100),
                ],
              ),
            ),

            // 5. Floating Action Button (Tambah Kategori Baru)
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
          color: isActive ? bgLightGreen : Colors.transparent,
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

  Widget _buildDynamicCategoryItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    double itemHeight = 72.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        double actionsWidth = width * 0.4; // Lebar area tombol Edit + Hapus

        return Container(
          height: itemHeight,
          decoration: BoxDecoration(
            color: const Color(
              0xFFE2E8F0,
            ), // Background dasar tombol di belakang
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            clipBehavior: Clip.antiAlias,
            children: [
              // 1. LAPISAN BELAKANG: Tombol Aksi (Edit & Hapus)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: actionsWidth,
                child: Row(
                  children: [
                    // Tombol Edit
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          controller.editCategory(title);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          color: const Color(0xFFE2E8F0),
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
                    // Tombol Hapus
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          controller.deleteCategory(title);
                        },
                        behavior: HitTestBehavior.opaque,
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
              ),

              // 2. LAPISAN DEPAN: Konten Utama (Bisa Bergeser)
              // Kita ganti AnimatedPositioned menjadi menggunakan Width yang pasti agar deteksi gesture tidak hilang saat bergeser
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                left: isSelected ? -actionsWidth : 0,
                width: width, // Lebarnya dikunci sesuai lebar maksimal layar
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap:
                      onTap, // Menekan bagian mana saja pada card akan membuka/menutup menu
                  behavior: HitTestBehavior
                      .opaque, // Memastikan area kosong di card tetap bisa di-tap
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? primaryDark.withOpacity(0.3)
                            : borderColor,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(icon, color: iconColor, size: 20),
                        ),
                        const SizedBox(width: 16),
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
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedRotation(
                          turns: isSelected ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.chevron_right,
                            color: isSelected ? primaryDark : Colors.grey[400],
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
