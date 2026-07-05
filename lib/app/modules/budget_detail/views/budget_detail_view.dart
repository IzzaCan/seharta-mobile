import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/budget_detail_controller.dart';
import '../../../data/models/budget_model.dart';

class BudgetDetailView extends GetView<BudgetDetailController> {
  const BudgetDetailView({Key? key}) : super(key: key);

  final Color primaryDark = const Color(0xFF0D2B33);
  final Color greenAccent = const Color(0xFF1F9975);
  final Color bgLightGreen = const Color(0xFFE8F5EE);
  final Color backgroundColor = const Color(0xFFF8F9FF);
  final Color cardBackgroundColor = Colors.white;
  final Color borderColor = const Color(0xFFE0E5E9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryDark),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.budget.categoryName,
              style: TextStyle(color: primaryDark, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              _getPeriodString(controller.budget),
              style: TextStyle(color: Colors.grey[500], fontSize: 11),
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final txList = controller.transactions;
        final spentFormatted = controller.formatRupiah(controller.budget.spentAmount).replaceAll('Rp ', 'Rp');

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Big Card at Top (Dark Teal)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: primaryDark,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primaryDark.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Category Icon box
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            _getCategoryIcon(controller.budget.categoryName),
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.budget.categoryName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${txList.length} transaksi',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      controller.budget.spentAmount > 0
                          ? '-$spentFormatted'
                          : spentFormatted,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // 2. Transactions section title
              Row(
                children: [
                  Text(
                    'Transaksi',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: primaryDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryDark.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${txList.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 3. Transactions List
              if (txList.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text(
                          'Belum ada transaksi di kategori ini\nuntuk bulan ini.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[400], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: txList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final tx = txList[index];
                    final amountFormatted = controller.formatRupiah(tx.amount).replaceAll('Rp ', 'Rp');
                    
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBackgroundColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          // Left Icon Container (Expense Icon)
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBEE), // light red
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.north_east,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // Transaction Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tx.notes != null && tx.notes!.isNotEmpty
                                      ? tx.notes!
                                      : controller.budget.categoryName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: primaryDark,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Text(
                                      _formatTxDate(tx.transactionDate),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.account_balance_wallet_outlined, size: 12, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      tx.walletName ?? 'Cash',
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
                          
                          // Transaction Amount
                          Text(
                            '-$amountFormatted',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      }),
    );
  }

  String _getPeriodString(BudgetModel budget) {
    final monthsShort = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final monthName = monthsShort[budget.month - 1];
    final lastDay = DateTime(budget.year, budget.month + 1, 0).day;
    return "1 $monthName - $lastDay $monthName ${budget.year}";
  }

  String _formatTxDate(String dateStr) {
    try {
      final parsed = DateTime.parse(dateStr).toLocal();
      return DateFormat('d MMM yyyy, HH:mm', 'id').format(parsed);
    } catch (_) {
      try {
        final parsed = DateTime.parse(dateStr).toLocal();
        return DateFormat('d MMM yyyy, HH:mm').format(parsed);
      } catch (e) {
        return dateStr;
      }
    }
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
