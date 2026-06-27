import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../routes/app_pages.dart';
import '../../../data/providers/api_provider.dart';
import '../../wallet/models/wallet_model.dart';
class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  final Color primaryColor = const Color(0xFF0D2B33); // Dark Teal
  final Color greenAccent = const Color(0xFF1F9975); // Emerald Green
  final Color bgLightGreen = const Color(0xFFE8F5EE);
  final Color backgroundColor = const Color(0xFFF8F9FF);
  final Color cardBackgroundColor = Colors.white;
  final Color borderColor = const Color(0xFFE0E5E9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      
      // BOTTOM NAVIGATION BAR DENGAN TOMBOL TENGAH
      
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(Routes.ADD_TRANSACTION);
        },
        backgroundColor: primaryColor,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        elevation: 10,
        child: Obx(
          () => SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: controller.currentIndex.value == 0
                      ? Icons.home
                      : Icons.home_outlined,
                  label: 'HOME',
                  index: 0,
                  isActive: controller.currentIndex.value == 0,
                ),
                _buildNavItem(
                  icon: controller.currentIndex.value == 1
                      ? Icons.account_balance_wallet
                      : Icons.account_balance_wallet_outlined,
                  label: 'HARTA',
                  index: 1,
                  isActive: controller.currentIndex.value == 1,
                ),
                const SizedBox(
                  width: 48,
                ), // Ruang kosong untuk Floating Action Button
                _buildNavItem(
                  icon: controller.currentIndex.value == 2
                      ? Icons.bar_chart_rounded
                      : Icons.bar_chart_rounded,
                  label: 'ANALYTICS',
                  index: 2,
                  isActive: controller.currentIndex.value == 2,
                ),
                _buildNavItem(
                  icon: controller.currentIndex.value == 3
                      ? Icons.person
                      : Icons.person_outline,
                  label: 'PROFILE',
                  index: 3,
                  isActive: controller.currentIndex.value == 3,
                ),
              ],
            ),
          ),
        ),
      ),

      
      // BODY / KONTEN UTAMA
      
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Custom Header (Logo & Avatar)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Seharta',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.notifications_none,
                        color: Colors.grey[600],
                        size: 24,
                      ),
                      const SizedBox(width: 16),
                      // Stack Avatar Pasangan
                      SizedBox(
                        width: 45,
                        child: Stack(
                          children: [
                            Obx(() => CircleAvatar(
                              radius: 14,
                              backgroundImage: controller.avatarUrl != null
                                  ? NetworkImage('${ApiProvider.baseDomain}${controller.avatarUrl!}')
                                  : const NetworkImage('https://ui-avatars.com/api/?name=Anda&background=0D2B33&color=fff'),
                            )),
                            Positioned(
                              left: 16,
                              child: Obx(() => CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundImage: controller.partnerAvatarUrl != null
                                      ? NetworkImage('${ApiProvider.baseDomain}${controller.partnerAvatarUrl!}')
                                      : NetworkImage(
                                          'https://ui-avatars.com/api/?name=${controller.partnerName ?? "Pasangan"}&background=1F9975&color=fff',
                                        ),
                                ),
                              )),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 2. Teks Sapaan
              Text(
                'SELAMAT PAGI',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[500],
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Obx(() {
                final name = controller.familyName.value;
                return Text(
                  'Halo, ${name.isEmpty ? "Keluarga Anda" : name}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    height: 1.2,
                  ),
                );
              }),
              const SizedBox(height: 20),

              // 3. Card Total Aset
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TOTAL SALDO BERSAMA',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        GestureDetector(
                          onTap: controller.toggleAssetVisibility,
                          child: Obx(
                            () => Icon(
                              controller.isAssetVisible.value
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.white.withOpacity(0.7),
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => Text(
                        controller.isAssetVisible.value
                            ? controller.formatRupiah(controller.totalSaldoBersama).replaceAll('Rp ', 'Rp\n')
                            : 'Rp\n••••••••',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Seluruh dompet · ${_getFormattedMonth()}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(() {
                      if (controller.isLoadingDashboard.value) {
                        return Row(
                          children: [
                            SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white.withOpacity(0.5)),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Memuat data...',
                              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
                            ),
                          ],
                        );
                      }

                      final income = controller.incomeThisMonth.value;
                      final expense = controller.expenseThisMonth.value;
                      
                      return Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: greenAccent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Pemasukan',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '+${controller.formatRupiah(income)}',
                                  style: TextStyle(
                                    color: greenAccent,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Colors.redAccent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Pengeluaran',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '-${controller.formatRupiah(expense)}',
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. Banner AI Insight
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: bgLightGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.lightbulb_outline,
                        color: greenAccent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Insight',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Obx(() {
                            if (controller.isLoadingInsight.value) {
                              return Row(
                                children: [
                                  SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: greenAccent,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Menganalisis pengeluaran Anda...',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              );
                            }
                            return Text(
                              controller.aiInsightText.value,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                                height: 1.4,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 5. Section: Dompet Bersama
              _buildSectionHeader(
                title: 'Dompet Bersama',
                actionText: 'Lihat Semua',
                onTap: () => Get.toNamed(Routes.WALLET),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 110,
                child: Obx(() {
                  if (controller.isLoadingDashboard.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.wallets.isEmpty) {
                    return Center(
                      child: Text(
                        'Belum ada dompet bersama terdaftar.',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    );
                  }
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: controller.wallets.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final wallet = controller.wallets[index];
                      return _buildWalletCard(
                        icon: Icons.account_balance_wallet,
                        title: wallet.walletName,
                        balance: controller.formatRupiah(wallet.balance),
                        onTap: () => Get.toNamed(Routes.WALLET),
                      );
                    },
                  );
                }),
              ),
              const SizedBox(height: 24),

              // 6. Section: Riwayat Transaksi
              _buildSectionHeader(
                title: 'Riwayat Transaksi',
                actionText: 'Filter',
              ),
              const SizedBox(height: 12),

              Obx(() {
                if (controller.isLoadingDashboard.value) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ));
                }
                if (controller.transactions.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Text(
                        'Belum ada riwayat transaksi.',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.transactions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final tx = controller.transactions[index];
                    final isExpense = tx.transactionType.toUpperCase() == 'EXPENSE' || tx.transactionType.toUpperCase() == 'TRANSFER';
                    final isTransfer = tx.transactionType.toUpperCase() == 'TRANSFER';
                    return _buildTransactionItem(
                      icon: isTransfer
                          ? Icons.swap_horiz
                          : (isExpense ? Icons.shopping_basket_outlined : Icons.account_balance_wallet_outlined),
                      title: tx.notes != null && tx.notes!.isNotEmpty 
                          ? tx.notes! 
                          : (isTransfer ? 'Transfer Goal' : (isExpense ? 'Pengeluaran' : 'Pemasukan')),
                      category: isTransfer ? 'Transfer' : (isExpense ? 'Pengeluaran' : 'Pemasukan'),
                      amount: '${isExpense ? "- " : "+ "}Rp ${tx.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}',
                      wallet: tx.walletName != null && tx.walletName!.isNotEmpty
                          ? tx.walletName!
                          : controller.wallets
                              .firstWhere((w) => w.id == tx.walletId, orElse: () => WalletModel(id: '', walletName: 'Dompet', balance: 0, isActive: false))
                              .walletName,
                      avatarUrl: tx.creatorAvatarUrl != null
                          ? '${ApiProvider.baseDomain}${tx.creatorAvatarUrl}'
                          : 'https://ui-avatars.com/api/?name=${tx.creatorName ?? "User"}&background=1F9975&color=fff',
                    );
                  },
                );
              }),
              const SizedBox(
                height: 80,
              ), // Padding ekstra di bawah agar tidak tertutup BottomNav
            ],
          ),
        ),
      ),
    ),
  );
}

  
  // REUSABLE WIDGETS
  

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: () => controller.changePage(index),
      child: Container(
        padding: isActive
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
            : null,
        decoration: isActive
            ? BoxDecoration(
                color: bgLightGreen,
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? primaryColor : Colors.grey[400],
              size: 24,
            ),
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
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String actionText,
    VoidCallback? onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: greenAccent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWalletCard({
    required IconData icon,
    required String title,
    required String balance,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: primaryColor, size: 20),
            ),
            const Spacer(),
            Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
            const SizedBox(height: 4),
            Text(
              balance,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required String title,
    required String category,
    required String amount,
    required String wallet,
    required String avatarUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          // Icon Box dengan Contributor Avatar Badge
          SizedBox(
            width: 46,
            height: 46,
            child: Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: primaryColor, size: 20),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 8,
                      backgroundImage: NetworkImage(avatarUrl),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Info Transaksi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          // Nominal & Wallet
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                wallet,
                style: TextStyle(fontSize: 10, color: Colors.grey[400]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getFormattedMonth() {
    final now = DateTime.now();
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return "${months[now.month - 1]} ${now.year}";
  }
}
