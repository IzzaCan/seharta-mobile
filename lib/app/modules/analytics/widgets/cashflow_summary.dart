import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/analytics_model.dart';

class CashflowSummary extends StatelessWidget {
  final AnalyticsIncomeVsExpense data;

  const CashflowSummary({
    Key? key,
    required this.data,
  }) : super(key: key);

  final Color primaryDark = const Color(0xFF0D2B33);
  final Color cardColor = Colors.white;
  final Color greenAccent = const Color(0xFF4ADE80);
  final Color redAccent = const Color(0xFFF43F5E);

  String formatCurrency(double value) {
    if (value >= 1e9) {
      return 'Rp ${(value / 1e9).toStringAsFixed(2).replaceAll('.', ',')} M';
    } else if (value >= 1e6) {
      return 'Rp ${(value / 1e6).toStringAsFixed(2).replaceAll('.', ',')} Jt';
    } else if (value >= 1e3) {
      return 'Rp ${(value / 1e3).toStringAsFixed(0)} Rb';
    } else {
      final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
      return format.format(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = data.totalIncome + data.totalExpense;
    final incomeRatio = total > 0 ? (data.totalIncome / total) : 0.0;
    final expenseRatio = total > 0 ? (data.totalExpense / total) : 0.0;
    
    final isSurplus = data.netSurplus >= 0;
    final surplusText = isSurplus ? '+${formatCurrency(data.netSurplus)}' : formatCurrency(data.netSurplus);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.swap_horiz_rounded, color: Color(0xFFA5C5CB), size: 20),
            const SizedBox(width: 8),
            Text(
              'Arus Kas',
              style: TextStyle(
                color: primaryDark,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Surplus Bersih',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        surplusText,
                        style: TextStyle(
                          color: isSurplus ? greenAccent : redAccent,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.circle, color: greenAccent, size: 8),
                          const SizedBox(width: 4),
                          Text(
                            'Pemasukan',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.circle, color: redAccent, size: 8),
                          const SizedBox(width: 4),
                          Text(
                            'Pengeluaran',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    if (incomeRatio > 0)
                      Expanded(
                        flex: (incomeRatio * 100).toInt(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: greenAccent,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(6),
                              bottomLeft: const Radius.circular(6),
                              topRight: expenseRatio == 0 ? const Radius.circular(6) : Radius.zero,
                              bottomRight: expenseRatio == 0 ? const Radius.circular(6) : Radius.zero,
                            ),
                          ),
                        ),
                      ),
                    if (expenseRatio > 0)
                      Expanded(
                        flex: (expenseRatio * 100).toInt(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: redAccent,
                            borderRadius: BorderRadius.only(
                              topRight: const Radius.circular(6),
                              bottomRight: const Radius.circular(6),
                              topLeft: incomeRatio == 0 ? const Radius.circular(6) : Radius.zero,
                              bottomLeft: incomeRatio == 0 ? const Radius.circular(6) : Radius.zero,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatCurrency(data.totalIncome),
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    formatCurrency(data.totalExpense),
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
