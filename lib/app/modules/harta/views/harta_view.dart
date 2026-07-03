import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';
import '../controllers/harta_controller.dart';
import '../models/asset_model.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/asset_helper.dart';

class HartaView extends GetView<HartaController> {
  const HartaView({Key? key}) : super(key: key);

  // Palet Warna
  final Color primaryDark = const Color(0xFF0D2B33); // Dark Teal
  final Color greenAccent = const Color(0xFF1F9975); // Emerald Green
  final Color greenBright = const Color(0xFF047857); // Chart Green
  final Color backgroundColor = const Color(0xFFF8F9FF);
  final Color cardColor = Colors.white;
  final Color borderColor = const Color(0xFFE0E5E9);
  final Color bgLightGreen = const Color(0xFFE8F5EE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      // BOTTOM NAVIGATION BAR
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(Routes.ADD_TRANSACTION);
        },
        backgroundColor: primaryDark,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
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
              // Item HARTA aktif
              _buildNavItem(
                icon: Icons.account_balance_wallet,
                label: 'HARTA',
                isActive: true,
                onTap: () {},
              ),
              const SizedBox(width: 48), // Ruang kosong untuk FAB
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
        child: RefreshIndicator(
          onRefresh: controller.refreshHarta,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header (Logo & Avatar)
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
                                'https://ui-avatars.com/api/?name=Anda&background=0D2B33&color=fff',
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
                                    'https://ui-avatars.com/api/?name=Pasangan&background=1F9975&color=fff',
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
                          color: primaryDark,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.notifications_none, color: primaryDark, size: 20),
                ],
              ),
              const SizedBox(height: 24),

              // 2. Card Total Kekayaan
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL KEKAYAAN BERSIH',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(() {
                      final total = controller.totalKekayaan;
                      final formatted = total.toStringAsFixed(0).replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]}.',
                      );
                      return Text(
                        'Rp $formatted',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }),
                    Obx(() {
                      final assetCount = controller.assets.length;
                      final activeWalletCount = controller.wallets.where((w) => w.isActive).length;
                      return Row(
                        children: [
                          Icon(Icons.info_outline, color: greenAccent, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'Terdiri dari $assetCount aset & $activeWalletCount rekening aktif',
                            style: TextStyle(
                              color: greenAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. Tab Navigasi (Aset Tetap vs Goals)
              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => _buildCustomTab(
                        title: 'ASET TETAP',
                        icon: Icons.account_balance_wallet_outlined,
                        isActive: controller.activeTab.value == 0,
                        onTap: () => controller.switchTab(0),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Obx(
                      () => _buildCustomTab(
                        title: 'GOALS',
                        icon: Icons.track_changes,
                        isActive: controller.activeTab.value == 1,
                        onTap: () => controller.switchTab(1),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // KONTEN DINAMIS BERDASARKAN TAB YANG DIPILIH
              Obx(() {
                if (controller.activeTab.value == 0) {
                  // TAMPILAN TAB ASET TETAP
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 4. Section: Aset Tetap
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Aset Tetap',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: primaryDark,
                            ),
                          ),
                          GestureDetector(
                            onTap: controller.addAsset,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.add_circle_outline,
                                  color: greenAccent,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Tambah Aset',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: greenAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Obx(() {
                        if (controller.isLoadingAssets.value) {
                          // Shimmer Loading Placeholder
                          return Column(
                            children: List.generate(2, (index) => _buildShimmerAssetItem()),
                          );
                        }
                        if (controller.assets.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Text(
                                'Belum ada aset tetap.\nYuk, tambahkan aset pertamamu!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        }
                        return Column(
                          children: controller.assets.map((asset) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildAssetItem(
                                id: asset.id,
                                icon: _getCategoryIcon(asset.categoryName),
                                title: asset.assetName,
                                subtitle: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 10,
                                      height: 1.4,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: translateAssetCategory(asset.categoryName),
                                        style: TextStyle(
                                          color: Colors.blueGrey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const TextSpan(
                                        text: '  •  ',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      TextSpan(
                                        text: asset.ownershipType == 'PERSONAL' ? asset.ownerName : 'Bersama',
                                        style: TextStyle(
                                          color: asset.ownershipType == 'PERSONAL'
                                              ? const Color(0xFF1F9975)
                                              : const Color(0xFFD97706),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                amount: 'Rp ${asset.purchasePrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                asset: asset,
                                canEdit: asset.ownershipType == 'JOINT' || controller.currentUserId == asset.ownerUserId,
                              ),
                            );
                          }).toList(),
                        );
                      }),
                    ],
                  );
                } else {
                  // TAMPILAN TAB GOALS
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 5. Section: Financial Goals
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Financial Goals',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: primaryDark,
                            ),
                          ),
                          GestureDetector(
                            onTap: controller
                                .addGoal, // Memanggil fungsi addGoal di controller
                            child: Row(
                              children: [
                                Icon(
                                  Icons.add_circle_outline,
                                  color: greenAccent,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Tambah Goals',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: greenAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Obx(() {
                        if (controller.isLoadingGoals.value) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (controller.goals.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Text(
                                'Belum ada Financial Goals.\nYuk, buat target pertamamu!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        }
                        return Column(
                          children: controller.goals.map((goal) {
                            return GestureDetector(
                              onTap: () => Get.toNamed(Routes.GOAL_DETAIL, arguments: goal.id),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFF0F4F8),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.school_outlined, // Bisa dinamis jika ada ikon
                                            color: Colors.blueGrey,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                goal.name,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: primaryDark,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Target: ${goal.formattedDeadline}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey[500],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              'STATUS',
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[400],
                                              ),
                                            ),
                                            Text(
                                              goal.progressPercentage >= 100 
                                                  ? 'Selesai' 
                                                  : (goal.progressPercentage > 0 ? 'Progres' : 'Belum\nMulai'),
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: greenAccent,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Progres Tabungan',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          '${goal.progressPercentage.toStringAsFixed(1)}%',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: primaryDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: goal.progressPercentage / 100.0,
                                        backgroundColor: Colors.grey[200],
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          greenBright,
                                        ),
                                        minHeight: 6,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Rp ${goal.currentAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: primaryDark,
                                          ),
                                        ),
                                        Text(
                                          'dari Rp ${goal.targetAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[400],
                                          ),
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
                    ],
                  );
                }
              }),
              const SizedBox(height: 40), // Padding ekstra untuk Bottom Nav
            ],
          ),
        ),
      ),
    ),
  );
}

  // WIDGET REUSABLE
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
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
              color: isActive ? primaryDark : Colors.grey[400],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 8,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? primaryDark : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTab({
    required String title,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? primaryDark : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? primaryDark : Colors.grey[400],
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isActive ? primaryDark : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerAssetItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 120, height: 14, color: Colors.grey[300]),
                const SizedBox(height: 8),
                Container(width: 80, height: 10, color: Colors.grey[300]),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(width: 80, height: 14, color: Colors.grey[300]),
              const SizedBox(height: 8),
              Container(width: 40, height: 10, color: Colors.grey[300]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAssetItem({
    required String id,
    required IconData icon,
    required String title,
    required Widget subtitle,
    required String amount,
    required AssetModel asset,
    required bool canEdit,
  }) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.DETAIL_ASSET, arguments: asset),
      child: Container(
        padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.blueGrey,
              size: 24,
            ),
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
                subtitle,
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: primaryDark,
                ),
              ),
              const SizedBox(height: 6),
              if (canEdit)
                GestureDetector(
                  onTap: () {
                    Get.bottomSheet(
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: Icon(Icons.edit, color: primaryDark),
                              title: Text('Edit Aset', style: TextStyle(color: primaryDark, fontWeight: FontWeight.bold)),
                              onTap: () {
                                Get.back();
                                Get.toNamed(Routes.ADD_ASSET, arguments: id); // Or edit asset route
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.delete, color: Colors.red),
                              title: const Text('Hapus Aset', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                              onTap: () {
                                Get.back();
                                controller.deleteAsset(id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Icon(Icons.more_vert, size: 16, color: Colors.grey[600]),
                ),
            ],
          ),
        ],
      ),
    ),
  );
}

  IconData _getCategoryIcon(String? categoryName) {
    if (categoryName == null) return Icons.category_outlined;
    final name = categoryName.toLowerCase();
    if (name.contains('kendaraan') || name.contains('car') || name.contains('brio') || name.contains('transport')) {
      return Icons.directions_car_outlined;
    } else if (name.contains('emas') || name.contains('gold') || name.contains('komoditas') || name.contains('precious') || name.contains('logam')) {
      return Icons.hexagon_outlined;
    } else if (name.contains('elektronik') || name.contains('electronics') || name.contains('gadget') || name.contains('ps5') || name.contains('device')) {
      return Icons.devices_other;
    } else if (name.contains('properti') || name.contains('property') || name.contains('rumah') || name.contains('house') || name.contains('tanah')) {
      return Icons.home_work_outlined;
    } else if (name.contains('investasi') || name.contains('investment') || name.contains('saham') || name.contains('stock')) {
      return Icons.trending_up_outlined;
    }
    return Icons.category_outlined;
  }

  Widget _buildChartLegend({
    required Color color,
    required String title,
    required String percentage,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        Text(
          percentage,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: primaryDark,
          ),
        ),
      ],
    );
  }
}

// CUSTOM PAINTER UNTUK DONUT CHART (HARTA)
class AssetDonutPainter extends CustomPainter {
  final List<Color> colors;
  final List<double> percentages;

  AssetDonutPainter({required this.colors, required this.percentages});

  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 20.0;
    Rect rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    double startAngle = -pi / 2;

    for (int i = 0; i < percentages.length; i++) {
      double sweepAngle = percentages[i] * 2 * pi;

      Paint paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
