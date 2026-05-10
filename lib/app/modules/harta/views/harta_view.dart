import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';
import '../controllers/harta_controller.dart';
import '../../../routes/app_pages.dart';

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
        child: SingleChildScrollView(
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
                    const Text(
                      'Rp 130.000.000',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.trending_up, color: greenAccent, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '+2.4% dari bulan lalu',
                          style: TextStyle(
                            color: greenAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
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

              // Berdasarkan Mockup, seluruh section ditampilkan memanjang ke bawah.
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

              _buildAssetItem(
                icon: Icons.directions_car_outlined,
                title: 'Honda Brio 2020',
                subtitle: 'Transportasi • Diperbarui 2 hari yang lalu',
                amount: 'Rp 120.000.000',
                status: 'STABIL',
                statusColor: Colors.grey[600]!,
              ),
              const SizedBox(height: 12),
              _buildAssetItem(
                icon: Icons.hexagon_outlined, // Polygon icon placeholder
                title: 'Emas Antam 10g',
                subtitle: 'Komoditas • Diperbarui hari ini',
                amount: 'Rp 10.000.000',
                status: 'NAIK',
                statusColor: greenAccent,
              ),
              const SizedBox(height: 32),

              // 5. Section: Financial Goals
              Text(
                'Financial Goals',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryDark,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    // Header Goal
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F4F8),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.school_outlined,
                            color: Colors.blueGrey,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dana Pendidikan Anak',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: primaryDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Target: Desember 2028',
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
                              'Sesuai\nJalur',
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

                    // Progress Bar
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
                          '20%',
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
                        value: 0.2, // 20%
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(greenBright),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rp 10.000.000',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: primaryDark,
                          ),
                        ),
                        Text(
                          'dari Rp 50.000.000',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // AI Suggestion Banner
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F8FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: greenAccent,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Butuh strategi untuk mencapai target lebih cepat?',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: controller.askAISuggestion,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryDark,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Minta\nSaran AI',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 6. Section: Analisis Aset
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analisis Aset',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: primaryDark,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Donut Chart Custom
                    Center(
                      child: SizedBox(
                        height: 180,
                        width: 180,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: const Size(180, 180),
                              painter: AssetDonutPainter(
                                colors: [greenBright, primaryDark],
                                percentages: [
                                  0.923,
                                  0.077,
                                ], // 92.3% Kendaraan, 7.7% Emas
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'KOMPOSISI',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[400],
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '92%',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: primaryDark,
                                  ),
                                ),
                                Text(
                                  'Kendaraan',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Legend
                    _buildChartLegend(
                      color: greenBright,
                      title: 'Kendaraan',
                      percentage: '92.3%',
                    ),
                    const SizedBox(height: 12),
                    _buildChartLegend(
                      color: primaryDark,
                      title: 'Emas',
                      percentage: '7.7%',
                    ),
                    const SizedBox(height: 24),

                    // Image Placeholder & Quote
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?auto=format&fit=crop&q=80&w=600', // Gambar Koin/Investasi
                        height: 80,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(height: 80, color: Colors.grey[200]),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '"Cara terbaik untuk memprediksi masa depan adalah dengan menciptakannya."',
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40), // Padding ekstra untuk Bottom Nav
            ],
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

  Widget _buildAssetItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String amount,
    required String status,
    required Color statusColor,
  }) {
    return Container(
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
            child: Icon(icon, color: Colors.blueGrey, size: 24),
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
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                    height: 1.4,
                  ),
                ),
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
              Text(
                status,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
    double strokeWidth = 20.0; // Lebar cincin grafik
    Rect rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    double startAngle = -pi / 2; // Mulai dari jam 12 atas

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
