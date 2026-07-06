import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/analytics_model.dart';
import '../../../routes/app_pages.dart';
import '../controllers/analytics_controller.dart';

import '../widgets/overview_grid.dart';
import '../widgets/cashflow_summary.dart';
import '../widgets/budget_analysis_card.dart';
import '../widgets/expense_donut_chart.dart';
import '../widgets/asset_bento_grid.dart';
import '../widgets/behavioral_insights.dart';

class AnalyticsView extends GetView<AnalyticsController> {
  const AnalyticsView({Key? key}) : super(key: key);

  final Color primaryDark = const Color(0xFF0D2B33);
  final Color backgroundColor = const Color(0xFFF8F9FF);
  final Color borderColor = const Color(0xFFE0E5E9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      // FAB & BottomNavigationBar ditambahkan kembali karena aplikasi menggunakan router individu per halaman
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(Routes.ADD_TRANSACTION);
        },
        backgroundColor: primaryDark,
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
            const SizedBox(width: 48), // Spacing for FAB
            _buildNavItem(
              icon: Icons.analytics,
              label: 'Analytics',
              isActive: true,
              onTap: () {},
            ),
            _buildNavItem(
              icon: Icons.person_outline,
              label: 'Profil',
              isActive: false,
              onTap: () => Get.offAllNamed(Routes.PROFILE),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refreshAnalytics,
          color: primaryDark,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 120.0),
            child: controller.obx(
              (data) => _buildSuccessState(data!),
              onLoading: _buildLoadingState(),
              onError: (error) => _buildErrorState(error),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessState(AnalyticsResponse data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 24),
        OverviewGrid(overview: data.overview),
        const SizedBox(height: 24),
        CashflowSummary(data: data.incomeVsExpense),
        const SizedBox(height: 24),
        BudgetAnalysisCard(data: data.budgetAnalysis),
        const SizedBox(height: 24),
        ExpenseDonutChart(categoryBreakdown: data.categoryBreakdown),
        const SizedBox(height: 24),
        AssetBentoGrid(data: data.assetDistribution),
        const SizedBox(height: 24),
        BehavioralInsights(summary: data.behavioralAnalytics.summary),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Seharta',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: primaryDark,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => _showMonthPicker(Get.context!),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: primaryDark,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primaryDark.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Obx(() => Text(
                      controller.currentMonthName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    )),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Analisis & Laporan',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: primaryDark,
          ),
        ),
        const SizedBox(height: 4),
        Obx(() => Text(
          'Ringkasan finansial untuk ${controller.currentMonthName}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        )),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _shimmerBox(width: 120, height: 40),
            _shimmerBox(width: 24, height: 24),
          ],
        ),
        const SizedBox(height: 24),
        _shimmerBox(width: 200, height: 28),
        const SizedBox(height: 8),
        _shimmerBox(width: 250, height: 16),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _shimmerBox(height: 80, radius: 16)),
            const SizedBox(width: 12),
            Expanded(child: _shimmerBox(height: 80, radius: 16)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _shimmerBox(height: 80, radius: 16)),
            const SizedBox(width: 12),
            Expanded(child: _shimmerBox(height: 80, radius: 16)),
          ],
        ),
        const SizedBox(height: 24),
        _shimmerBox(height: 150, radius: 20),
        const SizedBox(height: 24),
        _shimmerBox(height: 200, radius: 20),
      ],
    );
  }

  Widget _buildErrorState(String? error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Gagal memuat analytics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error ?? 'Terjadi kesalahan tidak terduga',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => controller.fetchAnalytics(),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _shimmerBox({double width = double.infinity, double height = 100, double radius = 8}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300]?.withOpacity(0.5),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  void _showMonthPicker(BuildContext context) {
    int tempYear = controller.selectedYear.value;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Material(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pilih Periode',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryDark,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.chevron_left_rounded, color: primaryDark),
                              onPressed: () => setState(() => tempYear--),
                            ),
                            Text(
                              tempYear.toString(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryDark,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.chevron_right_rounded, color: primaryDark),
                              onPressed: () => setState(() => tempYear++),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 2.2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        final monthNum = index + 1;
                        final isSelected = monthNum == controller.selectedMonth.value && tempYear == controller.selectedYear.value;
                        
                        return GestureDetector(
                          onTap: () {
                            controller.changeMonth(monthNum, tempYear);
                            Get.back();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected ? primaryDark : Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? primaryDark : borderColor,
                              ),
                              boxShadow: isSelected ? [
                                BoxShadow(color: primaryDark.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
                              ] : [],
                            ),
                            child: Text(
                              controller.monthNames[index].substring(0, 3),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                color: isSelected ? Colors.white : Colors.grey[600],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final Color bgLightGreen = const Color(0xFFE8F5EE);
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
                  color: isActive ? primaryDark : Colors.grey[400],
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive ? primaryDark : Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
