import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/budgeting_controller.dart';
import '../../../utils/rupiah_formatter.dart';
import '../../../data/models/budget_model.dart';
import '../../../routes/app_pages.dart';

class BudgetingView extends GetView<BudgetingController> {
  const BudgetingView({Key? key}) : super(key: key);

  final Color primaryColor = const Color(0xFF0D2B33);
  final Color greenAccent = const Color(0xFF1F9975);
  final Color backgroundColor = const Color(0xFFF8F9FF);
  final Color cardBackgroundColor = Colors.white;
  final Color borderColor = const Color(0xFFE0E5E9);
  Color get bgLightGreen => const Color(0xFFE8F5EE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: primaryColor, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Anggaran Bersama',
              style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 2),
            Text(
              _getFormattedMonth(),
              style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Segmented Control (Aktif / Riwayat)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.selectedTab(0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: controller.selectedTab.value == 0 ? primaryColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'Aktif',
                              style: TextStyle(
                                color: controller.selectedTab.value == 0 ? Colors.white : Colors.grey[600],
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.selectedTab(1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: controller.selectedTab.value == 1 ? primaryColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'Riwayat',
                              style: TextStyle(
                                color: controller.selectedTab.value == 1 ? Colors.white : Colors.grey[600],
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.fetchBudgets,
                child: controller.selectedTab.value == 0
                    ? _buildActiveTab(context)
                    : _buildHistoryTab(context),
              ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddBudgetSheet(context),
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Anggaran', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showAddBudgetSheet(BuildContext context) {
    final limitAmountController = TextEditingController();
    // Reset selected category to first item if available
    if (controller.categories.isNotEmpty) {
      controller.selectedCategory.value = controller.categories.first;
    }
    controller.isRecurring.value = false; // default false

    Get.bottomSheet(
      GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Title with back icon look
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F3F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.chevron_left, color: primaryColor, size: 24),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Tambah Anggaran',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // 1. Kategori
                  Text(
                    'Kategori',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    if (controller.isLoadingCategories.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (controller.categories.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Tidak ada kategori pengeluaran tersedia. Silakan buat kategori pengeluaran terlebih dahulu.',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      );
                    }
                    return DropdownButtonFormField<String>(
                      value: controller.selectedCategory.value?.id,
                      items: controller.categories.map((cat) {
                        return DropdownMenuItem<String>(
                          value: cat.id,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5EE),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.restaurant, color: greenAccent, size: 16),
                              ),
                              const SizedBox(width: 12),
                              Text(cat.name, style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        controller.selectedCategory.value = controller.categories.firstWhere((cat) => cat.id == val);
                      },
                      icon: Icon(Icons.chevron_right, color: Colors.grey[400]),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey[200]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey[200]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: primaryColor),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),

                  // 2. Jumlah Anggaran
                  Text(
                    'Jumlah Anggaran',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: limitAmountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [RupiahInputFormatter()],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor),
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                        child: Text(
                          'Rp',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor),
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FF),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      hintText: '0',
                      hintStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[300]),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 3. Periode Indicator
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey[700]),
                        const SizedBox(width: 8),
                        Text(
                          _getCurrentMonthPeriodString(),
                          style: TextStyle(color: Colors.grey[800], fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 4. Berulang Otomatis Switch
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F0FE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.sync, color: Colors.blue, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Berulang otomatis',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Anggaran dibuat ulang otomatis setiap periode baru berakhir',
                                style: TextStyle(fontSize: 11, color: Colors.grey[500], height: 1.2),
                              ),
                            ],
                          ),
                        ),
                        Obx(() => Switch(
                          value: controller.isRecurring.value,
                          onChanged: (val) {
                            controller.isRecurring.value = val;
                          },
                          activeColor: Colors.blue,
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Button: Simpan Anggaran
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        final cleanAmount = limitAmountController.text.replaceAll(RegExp(r'[^0-9]'), '');
                        final limit = double.tryParse(cleanAmount) ?? 0;
                        final selected = controller.selectedCategory.value;
                        if (selected != null && limit > 0) {
                          controller.addBudget(
                            selected.id,
                            limit,
                          );
                        } else {
                          Get.snackbar('Validasi', 'Mohon isi nominal batas anggaran dengan benar dan pilih kategori');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text('Simpan Anggaran', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      isScrollControlled: true,
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

  String _getCurrentMonthPeriodString() {
    final now = DateTime.now();
    final monthsReal = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final monthName = monthsReal[now.month - 1];
    final lastDay = DateTime(now.year, now.month + 1, 0).day;
    return "${now.day} $monthName ${now.year} -> $lastDay $monthName ${now.year}";
  }

  void _showEditBudgetSheet(BuildContext context, BudgetModel budget) {
    final initialText = NumberFormat.decimalPattern('id').format(budget.limitAmount);
    final limitAmountController = TextEditingController(text: initialText);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit Anggaran - ${budget.categoryName}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
            const SizedBox(height: 20),
            TextField(
              controller: limitAmountController,
              keyboardType: TextInputType.number,
              inputFormatters: [RupiahInputFormatter()],
              decoration: InputDecoration(
                labelText: 'Batas Nominal Baru',
                hintText: 'Cth: 1.000.000',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixText: 'Rp ',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  final cleanAmount = limitAmountController.text.replaceAll(RegExp(r'[^0-9]'), '');
                  final limit = double.tryParse(cleanAmount) ?? 0;
                  if (limit > 0) {
                    controller.editBudget(budget.id, limit);
                  } else {
                    Get.snackbar('Validasi', 'Mohon isi nominal batas anggaran dengan benar');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, BudgetModel budget) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus Anggaran', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin menghapus anggaran kategori "${budget.categoryName}" untuk bulan ini?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // close dialog
              controller.deleteBudget(budget.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- TAB BUILDERS & HELPERS ---
  Widget _buildActiveTab(BuildContext context) {
    if (controller.budgets.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Belum ada anggaran bulan ini',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: controller.budgets.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL ANGGARAN',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        controller.formatRupiah(controller.totalLimitAmount),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${controller.totalProgressPercentage.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: Colors.white.withOpacity(0.2), height: 1),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Terpakai',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              controller.formatRupiah(controller.totalSpentAmount),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sisa',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              controller.formatRupiah(controller.totalRemainingAmount),
                              style: TextStyle(
                                color: greenAccent,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        final budgetIndex = index - 1;
        final budget = controller.budgets[budgetIndex];
        final progress = budget.limitAmount > 0 ? (budget.spentAmount / budget.limitAmount) : 0.0;
        final progressClamped = progress.clamp(0.0, 1.0);
        final isOverBudget = progress >= 0.8;
        
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: budgetIndex == 0 ? 20 : 16,
            bottom: budgetIndex == controller.budgets.length - 1 ? 20 : 0,
          ),
          child: GestureDetector(
            onTap: () => Get.toNamed(Routes.BUDGET_DETAIL, arguments: budget),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBackgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                          const SizedBox(width: 4),
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
                                        leading: Icon(Icons.edit, color: primaryColor),
                                        title: Text('Edit Anggaran', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                                        onTap: () {
                                          Get.back();
                                          _showEditBudgetSheet(context, budget);
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.delete, color: Colors.red),
                                        title: const Text('Hapus Anggaran', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                        onTap: () {
                                          Get.back();
                                          _showDeleteConfirmDialog(context, budget);
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
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progressClamped,
                      backgroundColor: Colors.grey[200],
                      color: isOverBudget ? Colors.orange : greenAccent,
                      minHeight: 10,
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
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab(BuildContext context) {
    final groups = controller.groupedHistoryBudgets;
    if (groups.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history_toggle_off_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Belum ada riwayat anggaran',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: groups.length,
      itemBuilder: (context, groupIndex) {
        final entry = groups[groupIndex];
        final monthName = entry.key;
        final budgetList = entry.value;
        
        final firstItem = budgetList.first;
        final monthInt = firstItem.month;
        final yearInt = firstItem.year;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group Header: "April 2026 2" + Trash Icon
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  Text(
                    monthName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${budgetList.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _showDeleteMonthConfirmDialog(context, monthName, monthInt, yearInt),
                  ),
                ],
              ),
            ),
            
            // History Cards List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: budgetList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, budgetIndex) {
                final budget = budgetList[budgetIndex];
                return GestureDetector(
                  onTap: () => Get.toNamed(Routes.BUDGET_DETAIL, arguments: budget),
                  child: _buildHistoryCard(context, budget),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildHistoryCard(BuildContext context, BudgetModel budget) {
    final progress = budget.limitAmount > 0 ? (budget.spentAmount / budget.limitAmount) : 0.0;
    final progressClamped = progress.clamp(0.0, 1.0);
    final isOverBudget = progress >= 1.0;
    
    final spentFormatted = controller.formatRupiah(budget.spentAmount);
    final limitFormatted = controller.formatRupiah(budget.limitAmount);
    final diff = (budget.limitAmount - budget.spentAmount).abs();
    final diffFormatted = controller.formatRupiah(diff);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Circular Progress & Icon
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[100],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 52,
                      height: 52,
                      child: CircularProgressIndicator(
                        value: progressClamped,
                        strokeWidth: 3,
                        backgroundColor: Colors.grey[200]!,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isOverBudget ? Colors.red : greenAccent,
                        ),
                      ),
                    ),
                    Icon(
                      _getCategoryIcon(budget.categoryName),
                      color: primaryColor,
                      size: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              
              // Center/Right Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Name & Limit Amount & More Vert
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          budget.categoryName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              limitFormatted,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(width: 4),
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
                                          leading: Icon(Icons.edit, color: primaryColor),
                                          title: Text('Edit Anggaran', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                                          onTap: () {
                                            Get.back();
                                            _showEditBudgetSheet(context, budget);
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.delete, color: Colors.red),
                                          title: const Text('Hapus Anggaran', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                          onTap: () {
                                            Get.back();
                                            _showDeleteConfirmDialog(context, budget);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              child: Icon(Icons.more_vert, size: 20, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    
                    // Badges
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Bulanan · ${_getFormattedMonthName(budget.month, budget.year)}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check, size: 10, color: Colors.grey[600]),
                              const SizedBox(width: 2),
                              Text(
                                'Selesai',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressClamped,
              backgroundColor: Colors.grey[200],
              color: isOverBudget ? Colors.red : greenAccent,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),
          
          // Spent vs Remainder
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.account_balance_wallet_outlined, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    spentFormatted,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              if (isOverBudget)
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 14, color: Colors.red),
                    const SizedBox(width: 4),
                    Text(
                      '-$diffFormatted',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Icon(Icons.monetization_on_outlined, size: 14, color: greenAccent),
                    const SizedBox(width: 4),
                    Text(
                      '+$diffFormatted',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: greenAccent,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteMonthConfirmDialog(BuildContext context, String monthName, int month, int year) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Hapus Riwayat?',
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus semua anggaran untuk periode $monthName?',
            style: TextStyle(color: Colors.grey[700]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                controller.deleteBudgetsForMonth(month, year);
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('makan') || name.contains('food') || name.contains('kuliner')) {
      return Icons.restaurant;
    } else if (name.contains('transport') || name.contains('kendaraan') || name.contains('bensin')) {
      return Icons.directions_car_outlined;
    } else if (name.contains('belanja') || name.contains('shop')) {
      return Icons.shopping_bag_outlined;
    } else if (name.contains('tagihan') || name.contains('bill') || name.contains('listrik')) {
      return Icons.receipt_long_outlined;
    } else if (name.contains('hiburan') || name.contains('entertain') || name.contains('nonton')) {
      return Icons.movie_outlined;
    }
    return Icons.category_outlined;
  }
}
