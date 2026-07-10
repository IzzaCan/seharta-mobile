import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/add_transaction_controller.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/rupiah_formatter.dart';
import '../../manage_categories/controllers/manage_categories_controller.dart';
import '../../manage_wallets/controllers/manage_wallets_controller.dart';
import '../../wallet/models/wallet_model.dart';

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
      

      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              icon: Icons.home_outlined,
              label: 'Beranda',
              isActive: false,
              onTap: () => Get.offAllNamed(Routes.HOME),
            ),
            _buildNavItem(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Harta',
              isActive: false,
              onTap: () => Get.offAllNamed(Routes.HARTA),
            ),
            _buildNavItem(
              icon: Icons.analytics_outlined,
              label: 'Analytics',
              isActive: false,
              onTap: () => Get.offAllNamed(Routes.ANALYTICS),
            ),
            _buildNavItem(
              icon: Icons.person_outline,
              label: 'Profile',
              isActive: false,
              onTap: () => Get.offAllNamed(Routes.PROFILE),
            ),
          ],
        ),
      ),

      
      // BODY / KONTEN UTAMA
      
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header (Identitas Aplikasi)
              Text(
                'Seharta',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
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
                        focusNode: controller.amountFocusNode,
                        keyboardType: TextInputType.number,
                        inputFormatters: [RupiahInputFormatter()],
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
              GestureDetector(
                onTap: () => _showCategoryPicker(context),
                child: _buildInputContainer(
                  label: 'KATEGORI',
                  child: Row(
                    children: [
                      Obx(() => Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: bgLightGreen,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getSelectedCategoryIcon(controller.selectedCategory.value),
                          color: greenAccent,
                          size: 16,
                        ),
                      )),
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
              ),
              const SizedBox(height: 16),

              // 7. Input Card: DOMPET
              GestureDetector(
                onTap: () => _showWalletPicker(context),
                child: _buildInputContainer(
                  label: 'DOMPET',
                  child: Row(
                    children: [
                      Obx(() => Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getSelectedWalletIcon(controller.selectedWallet.value),
                          color: Colors.blueGrey,
                          size: 16,
                        ),
                      )),
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
              ),
              const SizedBox(height: 16),

              // 8. Input Card: CATATAN
              _buildInputContainer(
                label: 'CATATAN (OPSIONAL)',
                child: TextFormField(
                  controller: controller.noteController,
                  focusNode: controller.noteFocusNode,
                  maxLines: 8,
                  minLines: 5,
                  keyboardType: TextInputType.multiline,
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
                    _getFormattedRealTimeDate(),
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
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? bgLightGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: isActive ? primaryColor : Colors.grey[400],
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive ? primaryColor : Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
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

  // Helper untuk mencari dan mengambil ikon kategori yang dibuat user secara dinamis
  IconData _getSelectedCategoryIcon(String selectedTitle) {
    final categoryController = Get.put(ManageCategoriesController());
    final cat = categoryController.categories.firstWhere(
      (c) => c['title'] == selectedTitle,
      orElse: () => <String, dynamic>{},
    );
    if (cat.isNotEmpty && cat['icon'] is IconData) {
      return cat['icon'] as IconData;
    }
    return Icons.category_outlined;
  }

  // Helper untuk mencari dan mengambil ikon dompet yang dibuat user secara dinamis
  IconData _getSelectedWalletIcon(String selectedTitle) {
    final walletController = Get.put(ManageWalletsController());
    final w = walletController.wallets.firstWhere(
      (wallet) => wallet.walletName == selectedTitle,
      orElse: () => WalletModel(id: '', walletName: '', balance: 0.0, isActive: false),
    );
    if (w.id.isNotEmpty) {
      return Icons.account_balance_wallet;
    }
    return Icons.account_balance_wallet_outlined;
  }

  // Menampilkan Bottom Sheet pilihan kategori belanja (mengambil data kategori dinamis buatan user)
  void _showCategoryPicker(BuildContext context) {
    controller.amountFocusNode.unfocus();
    controller.noteFocusNode.unfocus();
    final categoryController = Get.put(ManageCategoriesController());
    
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih Kategori',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: Obx(() {
                // Filter kategori berdasarkan tipe transaksi pengeluaran vs pemasukan
                final list = categoryController.categories.where((cat) {
                  return cat['isExpense'] == controller.isExpense.value;
                }).toList();
                
                if (list.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Text('Belum ada kategori. Silakan buat di menu Profile.'),
                    ),
                  );
                }
                
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final cat = list[index];
                    final String title = cat['title'] ?? '';
                    final IconData icon = cat['icon'] is IconData ? cat['icon'] : Icons.category;
                    
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: bgLightGreen,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          color: greenAccent,
                          size: 18,
                        ),
                      ),
                      title: Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      trailing: controller.selectedCategory.value == title
                          ? Icon(Icons.check_circle, color: greenAccent)
                          : const SizedBox.shrink(),
                      onTap: () {
                        controller.selectedCategory.value = title;
                        Get.back();
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          controller.amountFocusNode.unfocus();
                          controller.noteFocusNode.unfocus();
                        });
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Menampilkan Bottom Sheet pilihan dompet (mengambil data dompet dinamis buatan user)
  void _showWalletPicker(BuildContext context) {
    controller.amountFocusNode.unfocus();
    controller.noteFocusNode.unfocus();
    final walletController = Get.put(ManageWalletsController());
    
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih Dompet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: Obx(() {
                final list = walletController.wallets;
                
                if (list.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Text('Belum ada dompet. Silakan buat di menu Profile.'),
                    ),
                  );
                }
                
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final w = list[index];
                    final String title = w.walletName;
                    final IconData icon = Icons.account_balance_wallet;
                    
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          color: Colors.blueGrey,
                          size: 18,
                        ),
                      ),
                      title: Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      subtitle: Text(
                        'Rp${w.balance.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                      trailing: controller.selectedWallet.value == title
                          ? const Icon(Icons.check_circle, color: Colors.blue)
                          : const SizedBox.shrink(),
                      onTap: () {
                        controller.selectedWallet.value = title;
                        Get.back();
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          controller.amountFocusNode.unfocus();
                          controller.noteFocusNode.unfocus();
                        });
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  String _getFormattedRealTimeDate() {
    final now = DateTime.now();
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return "Hari ini, ${now.day} ${months[now.month - 1]} ${now.year}";
  }
}
