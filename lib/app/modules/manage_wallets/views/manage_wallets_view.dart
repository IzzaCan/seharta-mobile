import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/manage_wallets_controller.dart';

class ManageWalletsView extends GetView<ManageWalletsController> {
  const ManageWalletsView({Key? key}) : super(key: key);

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
              // 1. Header Card: Ringkasan Aset
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
                    Positioned(
                      right: -15,
                      bottom: -20,
                      child: Transform.rotate(
                        angle: -0.2,
                        child: Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 100,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
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
              Obx(
                () => Row(
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
                      '${controller.wallets.length} Terdaftar',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: greenAccent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 3. List Dompet Dinamis Obx (Slide Actions Built-In)
              Obx(() {
                if (controller.isLoading.value) {
                  return Column(
                    children: List.generate(3, (index) => _buildShimmerWalletItem()),
                  );
                }

                if (controller.wallets.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'Belum ada dompet terdaftar.',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ),
                  );
                }

                return Column(
                  children: controller.wallets.map((wallet) {
                    final isSelected =
                        controller.selectedWalletId.value == wallet.id;

                    // Format balance
                    String formattedBalance = 'Rp${wallet.balance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildDynamicWalletItem(
                        id: wallet.id,
                        icon: Icons.account_balance_wallet,
                        iconBgColor: const Color(0xFFE8F5EE),
                        iconColor: const Color(0xFF1F9975),
                        title: wallet.walletName,
                        balance: formattedBalance,
                        isSelected: isSelected,
                        onTap: () => controller.selectWallet(wallet.id),
                      ),
                    );
                  }).toList(),
                );
              }),
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
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // WIDGET REUSABLE DINAMIS WITH SLIDE ACTION

  Widget _buildDynamicWalletItem({
    required String id,
    required IconData icon,
    required String title,
    required String balance,
    Color? iconBgColor,
    Color? iconColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    double itemHeight = 72.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        double actionsWidth =
            width * 0.4; // Lebar porsi tombol aksi di sisi kanan

        return Container(
          height: itemHeight,
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0), // Latar belakang tombol aksi
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            clipBehavior: Clip.antiAlias,
            children: [
              // LAPISAN BELAKANG: Tombol Opsi Edit & Hapus
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
                        onTap: () => controller.editWallet(id, title),
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
                        onTap: () => controller.deleteWallet(id, title),
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

              // LAPISAN DEPAN: Card Informasi Utama (Bergeser Mulus)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                left: isSelected ? -actionsWidth : 0,
                width: width,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: onTap,
                  behavior: HitTestBehavior.opaque,
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
                            color: iconBgColor ?? const Color(0xFFF0F4F8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            icon,
                            color: iconColor ?? primaryDark,
                            size: 20,
                          ),
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

  Widget _buildShimmerWalletItem() {
    return Container(
      height: 72,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[200]!.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey[200]!.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 80,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey[200]!.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
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

