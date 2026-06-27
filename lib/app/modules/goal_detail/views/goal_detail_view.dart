import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/goal_detail_controller.dart';

class GoalDetailView extends GetView<GoalDetailController> {
  const GoalDetailView({Key? key}) : super(key: key);

  final Color primaryDark = const Color(0xFF0D2B33);
  final Color greenAccent = const Color(0xFF1F9975);
  final Color greenBright = const Color(0xFF047857);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDark,
      floatingActionButton: FloatingActionButton(
        onPressed: controller.addContribution,
        backgroundColor: primaryDark,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }

        final goal = controller.goalDetail.value;
        if (goal == null) {
          return const Center(child: Text('Data tidak ditemukan', style: TextStyle(color: Colors.white)));
        }

        return SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER TOP (Dark Teal)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${goal.progressPercentage.toStringAsFixed(1)}% · ${controller.formatRupiah(goal.targetAmount)}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onSelected: (value) {
                        if (value == 'edit') {
                          controller.editGoal();
                        } else if (value == 'delete') {
                          controller.confirmDeleteGoal();
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit, color: Colors.blue),
                            title: Text('Edit Goal'),
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete, color: Colors.red),
                            title: Text('Hapus Goal'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // CIRCULAR PROGRESS & CURRENT AMOUNT
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: goal.progressPercentage / 100,
                            strokeWidth: 8,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(greenAccent),
                          ),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 24),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${goal.progressPercentage.toStringAsFixed(1)}% ${goal.progressPercentage >= 100 ? 'Selesai' : 'Terkumpul'}',
                              style: const TextStyle(color: Colors.white, fontSize: 10),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            controller.formatRupiah(goal.currentAmount),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'dari ${controller.formatRupiah(goal.targetAmount)}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // ESTIMATIONS
              Builder(
                builder: (context) {
                  int daysRemaining = 0;
                  double perHari = 0.0;
                  double perMinggu = 0.0;
                  double perBulan = 0.0;

                  if (goal.remainingAmount > 0) {
                    if (goal.deadline != null) {
                      final difference = goal.deadline!.difference(DateTime.now());
                      daysRemaining = difference.inDays;
                      if (daysRemaining < 0) {
                        daysRemaining = 0;
                      }
                    }

                    if (goal.deadline == null) {
                      // Assume a default 30 days if no deadline set
                      perHari = goal.remainingAmount / 30.0;
                      perMinggu = (perHari * 7).clamp(0.0, goal.remainingAmount);
                      perBulan = goal.remainingAmount;
                    } else if (daysRemaining > 0) {
                      perHari = goal.remainingAmount / daysRemaining;
                      perMinggu = (perHari * 7).clamp(0.0, goal.remainingAmount);
                      perBulan = (perHari * 30).clamp(0.0, goal.remainingAmount);
                    } else {
                      // Deadline is today or has passed
                      perHari = goal.remainingAmount;
                      perMinggu = goal.remainingAmount;
                      perBulan = goal.remainingAmount;
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: _buildEstimationItem('per hari', perHari)),
                          Container(width: 1, height: 32, color: Colors.white.withOpacity(0.15)),
                          Expanded(child: _buildEstimationItem('per minggu', perMinggu)),
                          Container(width: 1, height: 32, color: Colors.white.withOpacity(0.15)),
                          Expanded(child: _buildEstimationItem('per bulan', perBulan)),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              
              // BOTTOM WHITE SECTION
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F9FF),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildWhiteCard(
                            icon: Icons.account_balance_wallet_outlined,
                            iconColor: Colors.orange,
                            title: 'Sisa',
                            value: controller.formatRupiah(goal.remainingAmount),
                          ),
                          const SizedBox(height: 16),
                          _buildWhiteCard(
                            icon: Icons.calendar_month_outlined,
                            iconColor: Colors.blue,
                            title: 'Target Tanggal',
                            value: goal.formattedDeadline,
                          ),
                          const SizedBox(height: 16),
                          _buildWhiteCard(
                            icon: Icons.schedule_outlined,
                            iconColor: Colors.green,
                            title: 'Hari Tersisa',
                            value: goal.deadline != null 
                              ? '${goal.deadline!.difference(DateTime.now()).inDays} hari'
                              : '-',
                          ),
                          if (goal.note != null && goal.note!.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _buildWhiteCard(
                              icon: Icons.note_outlined,
                              iconColor: Colors.purple,
                              title: 'Catatan',
                              value: goal.note!,
                            ),
                          ],
                          const SizedBox(height: 32),
                          Text(
                            'Riwayat Setoran',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primaryDark,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (goal.contributions.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text('Belum ada setoran', style: TextStyle(color: Colors.grey[500])),
                              ),
                            ),
                          ...goal.contributions.map((c) {
                            bool isDeposit = c.transactionType == 'DEPOSIT';
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
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
                                      color: isDeposit ? Colors.green[50] : Colors.red[50],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isDeposit ? Icons.add : Icons.remove,
                                      color: isDeposit ? greenAccent : Colors.red,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isDeposit
                                              ? (c.walletName != null && c.walletName!.isNotEmpty
                                                  ? 'Setoran (${c.walletName})'
                                                  : 'Setoran')
                                              : 'Tarik',
                                          style: TextStyle(
                                            color: isDeposit ? greenAccent : Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          DateFormat('dd MMM yyyy, HH:mm').format(c.contributionDate),
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${isDeposit ? '+' : '-'}${controller.formatRupiah(c.amount)}',
                                    style: TextStyle(
                                      color: isDeposit ? greenAccent : Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEstimationItem(String label, double amount) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wb_sunny_outlined, color: Colors.white70, size: 12),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          controller.formatRupiah(amount),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildWhiteCard({required IconData icon, required Color iconColor, required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF0D2B33),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
