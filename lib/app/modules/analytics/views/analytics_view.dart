import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';
import '../controllers/analytics_controller.dart';
import '../../../routes/app_pages.dart';

class AnalyticsView extends GetView<AnalyticsController> {
  const AnalyticsView({Key? key}) : super(key: key);

  // Palet Warna
  final Color primaryDark = const Color(0xFF0D2B33); // Dark Teal
  final Color greenAccent = const Color(0xFF4ADE80); // Bright Green
  final Color lightBlue = const Color(0xFFA5C5CB); // Rent Color
  final Color greyAccent = const Color(0xFFE2E8F0); // Others Color
  final Color backgroundColor = const Color(0xFFF8F9FF);
  final Color cardColor = Colors.white;
  final Color borderColor = const Color(0xFFE0E5E9);

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
              _buildNavItem(
                icon: Icons.account_balance_wallet_outlined,
                label: 'HARTA',
                isActive: false,
                onTap: () => Get.offAllNamed(Routes.HARTA),
              ),
              const SizedBox(width: 48), // Ruang kosong untuk FAB
              // Item Analytics aktif (dengan background hijau pudar)
              _buildNavItem(
                icon: Icons.bar_chart_rounded,
                label: 'ANALYTICS',
                isActive: true,
                onTap: () {},
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
          onRefresh: controller.refreshAnalytics,
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

              // 2. Judul Halaman
              Text(
                'Analisis AI & Laporan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ringkasan kesehatan finansial keluarga Anda bulan ini.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // 3. Card Pengeluaran (Pie Chart)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pengeluaran',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryDark,
                          ),
                        ),
                        Icon(
                          Icons.pie_chart_outline,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Donut Chart Custom
                    SizedBox(
                      height: 160,
                      width: 160,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(160, 160),
                            painter: DonutChartPainter(
                              colors: [
                                primaryDark,
                                greenAccent,
                                lightBlue,
                                greyAccent,
                              ],
                              // Persentase: Bills 40%, Food 30%, Rent 15%, Others 15%
                              percentages: [0.40, 0.30, 0.15, 0.15],
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'TOTAL',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[500],
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rp 8.2M',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: primaryDark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Legend Grafik
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildLegendItem(
                          color: primaryDark,
                          title: 'Bills',
                          value: '40%',
                        ),
                        _buildLegendItem(
                          color: greenAccent,
                          title: 'Food',
                          value: '30%',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildLegendItem(
                          color: lightBlue,
                          title: 'Rent',
                          value: '15%',
                        ),
                        _buildLegendItem(
                          color: greyAccent,
                          title: 'Others',
                          value: '15%',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. Card Tren Bulanan (Line Chart Placeholder)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tren Bulanan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryDark,
                          ),
                        ),
                        // Dropdown Bulan
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F4F8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Obx(
                            () => DropdownButton<String>(
                              value: controller.selectedMonth.value,
                              underline: const SizedBox(),
                              icon: Icon(
                                Icons.keyboard_arrow_down,
                                size: 16,
                                color: primaryDark,
                              ),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: primaryDark,
                              ),
                              items: controller.months.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: controller.changeMonth,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildDotLegend(color: primaryDark, label: 'Bulan Ini'),
                        const SizedBox(width: 16),
                        _buildDotLegend(
                          color: Colors.grey[400]!,
                          label: 'Bulan Lalu',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Grid / Area Line Chart Kosong (Sesuai Mockup)
                    SizedBox(
                      height: 120,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Divider(color: Colors.grey[200], thickness: 1),
                          Divider(color: Colors.grey[200], thickness: 1),
                          Divider(color: Colors.grey[200], thickness: 1),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Sumbu X
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          'W1',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                        Text(
                          'W2',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                        Text(
                          'W3',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                        Text(
                          'W4',
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
              const SizedBox(height: 16),

              // 5. Card Laporan AI (Warna Gelap)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: primaryDark,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryDark.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.smart_toy_outlined,
                        color: greenAccent,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Laporan AI Seharta',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: greenAccent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Keluarga Anda dalam\nkondisi sehat finansial.',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Paragraf Laporan dengan Highlights
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                          height: 1.6,
                        ),
                        children: [
                          const TextSpan(
                            text:
                                'Analisis otomatis kami menunjukkan penghematan sebesar ',
                          ),
                          TextSpan(
                            text: '12% lebih tinggi ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: greenAccent,
                            ),
                          ),
                          const TextSpan(
                            text:
                                'dibandingkan bulan lalu. Namun, ada lonjakan pada kategori ',
                          ),
                          const TextSpan(
                            text: 'Hiburan ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const TextSpan(
                            text:
                                'sebesar 25% di minggu ketiga. Kami menyarankan untuk memindahkan sisa anggaran makan ke dana darurat untuk mencapai target liburan akhir tahun Anda lebih cepat.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tombol Aksi AI
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: controller.optimizeBudget,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: greenAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Optimalkan Anggaran',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: primaryDark,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: controller.viewCategoryDetails,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey[600]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Lihat Detail Kategori',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
            ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
            : null,
        decoration: isActive
            ? BoxDecoration(
                color: const Color(0xFFE8F5EE),
                borderRadius: BorderRadius.circular(12),
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

  Widget _buildLegendItem({
    required Color color,
    required String title,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: primaryDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDotLegend({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }
}


// CUSTOM PAINTER UNTUK DONUT CHART

class DonutChartPainter extends CustomPainter {
  final List<Color> colors;
  final List<double> percentages;

  DonutChartPainter({required this.colors, required this.percentages});

  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 18.0;
    Rect rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    double startAngle = -pi / 2; // Mulai dari arah jam 12

    for (int i = 0; i < percentages.length; i++) {
      double sweepAngle = percentages[i] * 2 * pi;

      Paint paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt; // Ujung datar seperti mockup

      // Menggambar busur (arc)
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);

      // Update titik awal untuk segmen berikutnya
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
