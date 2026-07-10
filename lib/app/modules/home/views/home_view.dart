import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/home_controller.dart';
import '../../../routes/app_pages.dart';
import '../../../data/providers/api_provider.dart';
import '../../wallet/models/wallet_model.dart';
import '../../notifications/controllers/notification_controller.dart';
import '../../../data/models/notification_model.dart';
import '../../../utils/time_ago.dart';
import '../../../utils/notification_parser.dart';
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
    final notificationController = Get.find<NotificationController>();
    
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
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 24,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                icon: controller.currentIndex.value == 0
                    ? Icons.home
                    : Icons.home_outlined,
                label: 'Beranda',
                index: 0,
                isActive: controller.currentIndex.value == 0,
              ),
              _buildNavItem(
                icon: controller.currentIndex.value == 1
                    ? Icons.account_balance_wallet
                    : Icons.account_balance_wallet_outlined,
                label: 'Harta',
                index: 1,
                isActive: controller.currentIndex.value == 1,
              ),
              const SizedBox(width: 48), // Ruang kosong untuk Floating Action Button
              _buildNavItem(
                icon: controller.currentIndex.value == 2
                    ? Icons.analytics
                    : Icons.analytics_outlined,
                label: 'Analytics',
                index: 2,
                isActive: controller.currentIndex.value == 2,
              ),
              _buildNavItem(
                icon: controller.currentIndex.value == 3
                    ? Icons.person
                    : Icons.person_outline,
                label: 'Profile',
                index: 3,
                isActive: controller.currentIndex.value == 3,
              ),
            ],
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
                      GestureDetector(
                        onTap: () => _showNotificationDropdown(context, notificationController),
                        child: Obx(() {
                          final hasUnread = notificationController.hasUnread.value;
                          final unreadCount = notificationController.unreadCount.value;
                          
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(
                                Icons.notifications_none,
                                color: Colors.grey[600],
                                size: 24,
                              ),
                              if (hasUnread)
                                Positioned(
                                  right: -2,
                                  top: -2,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.redAccent,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 14,
                                      minHeight: 14,
                                    ),
                                    child: Center(
                                      child: Text(
                                        unreadCount > 9 ? '9+' : unreadCount.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        }),
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
                                  ? NetworkImage(ApiProvider.getImageUrl(controller.avatarUrl))
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
                                      ? NetworkImage(ApiProvider.getImageUrl(controller.partnerAvatarUrl))
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
                _getDynamicGreeting(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                  letterSpacing: 1.2,
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

              // 3. Card Total Aset (Redesigned)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
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
                          'Total Saldo Bersama',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          onTap: controller.toggleAssetVisibility,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Obx(
                              () => Icon(
                                controller.isAssetVisible.value
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Obx(
                      () => Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          if (controller.isAssetVisible.value)
                            const Text(
                              'Rp ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          Text(
                            controller.isAssetVisible.value
                                ? controller.formatRupiah(controller.totalSaldoBersama).replaceAll('Rp ', '')
                                : 'Rp ••••••••',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Seluruh dompet • ${_getFormattedMonth()}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Obx(() {
                      if (controller.isLoadingDashboard.value) {
                        return Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 8),
                            Container(width: 80, height: 10, decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(4))),
                          ],
                        );
                      }

                      final income = controller.incomeThisMonth.value;
                      final expense = controller.expenseThisMonth.value;
                      
                      return Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: greenAccent.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.arrow_downward, color: greenAccent, size: 10),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Pemasukan',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '+${controller.formatRupiah(income)}',
                                    style: TextStyle(
                                      color: greenAccent,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.arrow_upward, color: Colors.redAccent, size: 10),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Pengeluaran',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '-${controller.formatRupiah(expense)}',
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. Banner AI Insight (Redesigned)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bgLightGreen,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lightbulb_outline,
                        color: greenAccent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
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
                          const SizedBox(height: 6),
                          Obx(() {
                            if (controller.isLoadingInsight.value) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(width: double.infinity, height: 12, decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(4))),
                                  const SizedBox(height: 6),
                                  Container(width: 200, height: 12, decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(4))),
                                ],
                              );
                            }
                            return Text(
                              controller.aiInsightText.value,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                                height: 1.5,
                                fontWeight: FontWeight.w500,
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
                actionText: 'Lihat Semua →',
                onTap: () => Get.toNamed(Routes.WALLET),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 110,
                child: Obx(() {
                  if (controller.isLoadingDashboard.value) {
                    return Row(
                      children: List.generate(2, (index) => Container(
                        width: 140,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(width: 80, height: 12, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4))),
                            const SizedBox(height: 8),
                            Container(width: 50, height: 10, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4))),
                          ],
                        ),
                      )),
                    );
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

              // 5.5 Section: Anggaran Bulan Ini
              _buildSectionHeader(
                title: 'Anggaran',
                actionText: 'Lihat Semua →',
                onTap: () => Get.toNamed(Routes.BUDGETING),
              ),
              const SizedBox(height: 12),
              Obx(() {
                if (controller.isLoadingBudgets.value) {
                  return Column(
                    children: List.generate(2, (index) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(width: 80, height: 14, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4))),
                              Container(width: 100, height: 12, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4))),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    )),
                  );
                }
                if (controller.budgets.isEmpty) {
                  // Fallback ke border solid jika package dotted_border tidak digunakan
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: greenAccent.withOpacity(0.5), width: 1.5),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Belum ada anggaran bulan ini. Yuk, buat anggaran bersama pasanganmu agar keuangan terkontrol!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => Get.toNamed(Routes.BUDGETING),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            minimumSize: const Size(0, 36),
                          ),
                          child: const Text('[Buat Anggaran Sekarang]', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                }
                
                // Show max 3 budgets
                final topBudgets = controller.budgets.take(3).toList();
                return Column(
                  children: topBudgets.map((budget) {
                    final progress = budget.limitAmount > 0 ? (budget.spentAmount / budget.limitAmount) : 0.0;
                    final progressClamped = progress.clamp(0.0, 1.0);
                    final isOverBudget = progress >= 0.8;
                    
                    return GestureDetector(
                      onTap: () => Get.toNamed(Routes.BUDGET_DETAIL, arguments: budget),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardBackgroundColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor, width: 0.8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      budget.categoryName,
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getFormattedMonthName(budget.month, budget.year),
                                      style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isOverBudget ? Colors.red[50] : bgLightGreen,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Sisa ${controller.formatRupiah(budget.remainingAmount)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isOverBudget ? Colors.red : greenAccent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: progressClamped,
                                backgroundColor: Colors.grey[100],
                                color: isOverBudget ? Colors.orange : greenAccent,
                                minHeight: 8,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Terpakai', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                                    const SizedBox(height: 4),
                                    Text(
                                      controller.formatRupiah(budget.spentAmount),
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryColor),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('Batas Anggaran', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                                    const SizedBox(height: 4),
                                    Text(
                                      controller.formatRupiah(budget.limitAmount),
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryColor),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              }),
              const SizedBox(height: 24),

              // 6. Section: Riwayat Transaksi
              _buildSectionHeader(
                title: 'Riwayat Transaksi',
                actionText: 'Lihat Semua →',
                onTap: () => Get.toNamed(Routes.ALL_TRANSACTIONS),
              ),
              const SizedBox(height: 12),

              Obx(() {
                if (controller.isLoadingDashboard.value) {
                  return Column(
                    children: List.generate(3, (index) => Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: cardBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(width: 120, height: 12, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4))),
                                const SizedBox(height: 6),
                                Container(width: 60, height: 10, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4))),
                              ],
                            ),
                          ),
                          Container(width: 70, height: 14, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4))),
                        ],
                      ),
                    )),
                  );
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
                final displayTransactions = controller.transactions.take(5).toList();
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayTransactions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final tx = displayTransactions[index];
                    return _buildTransactionItem(tx, context);
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

  void _showNotificationDropdown(BuildContext context, NotificationController notifController) {
    showDialog(
      context: context,
      barrierColor: Colors.black12,
      builder: (context) {
        return Align(
          alignment: Alignment.topRight,
          child: Container(
            width: 320,
            margin: const EdgeInsets.only(top: 70, right: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Notifikasi Terakhir',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      Obx(() {
                        if (notifController.hasUnread.value) {
                          return GestureDetector(
                            onTap: () {
                              notifController.markAllAsRead();
                            },
                            child: Text(
                              'Tandai Dibaca',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: greenAccent,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    if (notifController.isLoadingRecent.value && notifController.recentNotifications.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    
                    if (notifController.recentNotifications.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'Belum ada notifikasi.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                      );
                    }
                    
                    return Column(
                      children: notifController.recentNotifications.take(3).map((notif) {
                        final isUnread = !notif.isRead;
                        return InkWell(
                          onTap: () {
                            if (isUnread) notifController.markAsRead(notif.id);
                            Navigator.of(context).pop();
                            _showNotificationDetail(context, notif);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey.shade100),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: isUnread ? greenAccent : Colors.transparent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        notif.title,
                                        style: TextStyle(
                                          fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
                                          fontSize: 13,
                                          color: isUnread ? Colors.black87 : Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        notif.message,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isUnread ? Colors.black87 : Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        formatTimeAgo(notif.createdAt),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      Get.toNamed(Routes.NOTIFICATIONS);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      child: Text(
                        'Lihat Semua Notifikasi →',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showNotificationDetail(BuildContext context, NotificationResponse item) {
    final parsed = parseNotification(item);
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.secondary;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              _buildModalHeader(theme, accentColor, parsed, item),
              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 20),
              
              _buildModalBody(theme, accentColor, parsed),
              
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Selesai',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalHeader(ThemeData theme, Color accentColor, ParsedNotification parsed, NotificationResponse item) {
    IconData iconData = Icons.notifications_none_rounded;
    Color iconColor = theme.primaryColor;
    Color bgColor = theme.primaryColor.withOpacity(0.1);
    
    switch (parsed.categoryType) {
      case 'TRANSACTION':
        iconData = Icons.receipt_long_rounded;
        iconColor = accentColor;
        bgColor = accentColor.withOpacity(0.1);
        break;
      case 'OCR':
        iconData = Icons.document_scanner_rounded;
        iconColor = Colors.blue.shade700;
        bgColor = Colors.blue.shade50;
        break;
      case 'BUDGET':
        iconData = parsed.isOverBudget ? Icons.error_outline_rounded : Icons.warning_amber_rounded;
        iconColor = parsed.isOverBudget ? Colors.red.shade700 : Colors.amber.shade700;
        bgColor = parsed.isOverBudget ? Colors.red.shade50 : Colors.amber.shade50;
        break;
      case 'WALLET':
        iconData = Icons.account_balance_wallet_rounded;
        iconColor = accentColor;
        bgColor = accentColor.withOpacity(0.1);
        break;
    }
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(iconData, color: iconColor, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                parsed.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formatFullDateTime(item.createdAt),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModalBody(ThemeData theme, Color accentColor, ParsedNotification parsed) {
    switch (parsed.categoryType) {
      case 'TRANSACTION':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (parsed.amount != null) ...[
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        parsed.transactionType == 'INCOME' ? 'Pemasukan' : 'Pengeluaran',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: parsed.transactionType == 'INCOME' ? accentColor : Colors.redAccent,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        parsed.amount!,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  _buildNotificationDetailRow('Kategori', parsed.categoryName ?? 'Umum'),
                  _buildNotificationDetailRow('Dompet', parsed.walletName ?? 'Dompet Bersama'),
                  _buildNotificationDetailRow('Keterangan', parsed.description ?? '-'),
                ],
              ),
            ),
          ],
        );
        
      case 'OCR':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.document_scanner_rounded, size: 40, color: Colors.blue.shade700),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              parsed.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            if (parsed.ocrMerchant != null || parsed.ocrTotal != null) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  children: [
                    if (parsed.ocrMerchant != null)
                      _buildNotificationDetailRow('Merchant', parsed.ocrMerchant!),
                    if (parsed.ocrTotal != null)
                      _buildNotificationDetailRow('Total Dideteksi', parsed.ocrTotal!),
                  ],
                ),
              ),
            ],
          ],
        );
        
      case 'BUDGET':
        final Color alertColor = parsed.isOverBudget ? Colors.red.shade700 : Colors.amber.shade700;
        final Color alertBg = parsed.isOverBudget ? Colors.red.shade50 : Colors.amber.shade50;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: alertBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: alertColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    parsed.isOverBudget ? Icons.error_outline_rounded : Icons.warning_amber_rounded,
                    color: alertColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      parsed.isOverBudget ? 'Segera evaluasi pengeluaran bersama!' : 'Hampir mencapai batas anggaran keluarga.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: alertColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              parsed.message,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            if (parsed.budgetPercentage != null || parsed.budgetRemaining != null) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  children: [
                    if (parsed.budgetPercentage != null)
                      _buildNotificationDetailRow('Penggunaan', parsed.budgetPercentage!),
                    if (parsed.budgetRemaining != null)
                      _buildNotificationDetailRow('Sisa Anggaran', parsed.budgetRemaining!),
                  ],
                ),
              ),
            ],
          ],
        );
        
      case 'WALLET':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 28),
                  SizedBox(height: 24),
                  Text(
                    'Dompet Bersama Keluarga',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Saldo Terupdate',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              parsed.message,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ],
        );
        
      default:
        return Text(
          parsed.message,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            height: 1.5,
          ),
        );
    }
  }

  Widget _buildNotificationDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 2,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changePage(index),
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
          border: Border.all(color: borderColor, width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1F9975).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF1F9975), size: 20),
            ),
            const Spacer(),
            Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(
              balance,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: primaryColor,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(TransactionModel tx, BuildContext context) {
    final isExpense = tx.transactionType.toUpperCase() == 'EXPENSE' || tx.transactionType.toUpperCase() == 'TRANSFER';
    final isTransfer = tx.transactionType.toUpperCase() == 'TRANSFER';
    
    final icon = isTransfer
        ? Icons.swap_horiz
        : (isExpense ? Icons.shopping_basket_outlined : Icons.account_balance_wallet_outlined);
        
    final title = _shortTitle(tx, isExpense, isTransfer);
        
    final category = isTransfer ? 'Transfer' : (isExpense ? 'Pengeluaran' : 'Pemasukan');
    
    final amount = '${isExpense ? "- " : "+ "}Rp ${tx.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}';
    
    final wallet = tx.walletName != null && tx.walletName!.isNotEmpty
        ? tx.walletName!
        : controller.wallets
            .firstWhere((w) => w.id == tx.walletId, orElse: () => WalletModel(id: '', walletName: 'Dompet', balance: 0, isActive: false))
            .walletName;
            
    final avatarUrl = tx.creatorAvatarUrl != null
        ? ApiProvider.getImageUrl(tx.creatorAvatarUrl)
        : 'https://ui-avatars.com/api/?name=${tx.creatorName ?? "User"}&background=1F9975&color=fff';

    return Material(
      color: cardBackgroundColor,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showTransactionDetailBottomSheet(context, tx),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 0.8),
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
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F5EE),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: const Color(0xFF1F9975), size: 20),
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
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isExpense ? Colors.red : const Color(0xFF1F9975),
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
        ),
      ),
    );
  }

  // Helper: judul pendek untuk kartu list (merchant dari hasil OCR),
  // menyembunyikan dump notes panjang agar tidak tampil di list.
  String _shortTitle(TransactionModel tx, bool isExpense, bool isTransfer) {
    final notes = tx.notes;
    if (notes != null && notes.isNotEmpty) {
      if (notes.startsWith('DETAIL SCAN STRUK')) {
        // Dump hasil OCR: ambil "Merchant : <nama>" sebagai judul singkat.
        final merchantMatch =
            RegExp(r'Merchant[ \t]*:[ \t]*([^\n]+)', caseSensitive: false).firstMatch(notes);
        if (merchantMatch != null) {
          final merchant = merchantMatch.group(1)!.trim();
          if (merchant.isNotEmpty) return merchant;
        }
      } else {
        // Catatan biasa (bukan dump OCR): gunakan baris pertamanya.
        final firstLine = notes.split('\n').first.trim();
        if (firstLine.isNotEmpty) return firstLine;
      }
    }
    return isTransfer ? 'Transfer' : (isExpense ? 'Pengeluaran' : 'Pemasukan');
  }

  void _showTransactionDetailBottomSheet(BuildContext context, TransactionModel tx) {
    final isExpense = tx.transactionType.toUpperCase() == 'EXPENSE' || tx.transactionType.toUpperCase() == 'TRANSFER';
    final isTransfer = tx.transactionType.toUpperCase() == 'TRANSFER';
    
    final typeText = isTransfer 
        ? 'Transfer' 
        : (isExpense ? 'Pengeluaran' : 'Pemasukan');
    final typeColor = isTransfer 
        ? const Color(0xFF007AFF) 
        : (isExpense ? Colors.red : const Color(0xFF1F9975));

    final amountText = '${isExpense ? "- " : "+ "}Rp ${tx.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}';
    final formattedDate = DateFormat('dd MMMM yyyy, HH:mm').format(DateTime.tryParse(tx.transactionDate) ?? DateTime.now());
    
    final avatarUrl = tx.creatorAvatarUrl != null
        ? ApiProvider.getImageUrl(tx.creatorAvatarUrl)
        : 'https://ui-avatars.com/api/?name=${tx.creatorName ?? "User"}&background=1F9975&color=fff';

    final walletName = tx.walletName != null && tx.walletName!.isNotEmpty
        ? tx.walletName!
        : controller.wallets
            .firstWhere((w) => w.id == tx.walletId, orElse: () => WalletModel(id: '', walletName: 'Dompet', balance: 0, isActive: false))
            .walletName;

    Get.bottomSheet(
      SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Detail Transaksi',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: primaryColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    InkWell(
                      onTap: () => Get.back(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, size: 20, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Amount Display Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: typeColor.withOpacity(0.15), width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          typeText,
                          style: TextStyle(
                            color: typeColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        amountText,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: typeColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (tx.notes != null && tx.notes!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          tx.notes!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Details List Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor, width: 0.8),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        icon: Icons.category_outlined,
                        label: 'Kategori',
                        value: tx.categoryName ?? (isTransfer ? 'Transfer' : (isExpense ? 'Pengeluaran' : 'Pemasukan')),
                      ),
                      const Divider(height: 24, thickness: 0.5),
                      _buildDetailRow(
                        icon: Icons.account_balance_wallet_outlined,
                        label: 'Dompet',
                        value: walletName,
                      ),
                      const Divider(height: 24, thickness: 0.5),
                      _buildDetailRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Tanggal',
                        value: formattedDate,
                      ),
                      const Divider(height: 24, thickness: 0.5),
                      _buildCreatorRow(
                        avatarUrl: avatarUrl,
                        name: tx.creatorName ?? 'User',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: Colors.grey[400]),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCreatorRow({
    required String avatarUrl,
    required String name,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.person_outline, size: 20, color: Colors.grey[400]),
        const SizedBox(width: 12),
        Text(
          'Dibuat Oleh',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 12,
              backgroundImage: NetworkImage(avatarUrl),
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 14,
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  
String _getFormattedMonth() {
    final now = DateTime.now();
    return _getFormattedMonthName(now.month, now.year);
  }

  String _getFormattedMonthName(int month, int year) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    if (month < 1 || month > 12) return '';
    return "${months[month - 1]} $year";
  }

  String _getDynamicGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 10) {
      return 'SELAMAT PAGI';
    } else if (hour >= 10 && hour < 14) {
      return 'SELAMAT SIANG';
    } else if (hour >= 14 && hour < 18) {
      return 'SELAMAT SORE';
    } else {
      return 'SELAMAT MALAM';
    }
  }
}