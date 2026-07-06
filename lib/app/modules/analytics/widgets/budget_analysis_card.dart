import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/analytics_model.dart';

class BudgetAnalysisCard extends StatelessWidget {
  final AnalyticsBudgetAnalysis data;

  const BudgetAnalysisCard({
    Key? key,
    required this.data,
  }) : super(key: key);

  final Color primaryDark = const Color(0xFF0D2B33);
  final Color cardColor = Colors.white;
  final Color redAccent = const Color(0xFFF43F5E);
  final Color greenAccent = const Color(0xFF4ADE80);

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
    if (data.totalBudgeted == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black.withOpacity(0.05)),
            ),
            child: Column(
              children: [
                Icon(Icons.assignment_outlined, color: primaryDark.withOpacity(0.3), size: 40),
                const SizedBox(height: 12),
                Text(
                  'Belum ada anggaran yang dibuat',
                  style: TextStyle(
                    color: primaryDark.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final isOverBudget = data.overallAdherencePercentage > 100;
    final progressColor = isOverBudget ? redAccent : greenAccent;
    final displayPercentage = data.overallAdherencePercentage.clamp(0.0, 100.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextStat('Total Anggaran', formatCurrency(data.totalBudgeted)),
                    const SizedBox(height: 16),
                    _buildTextStat('Total Pengeluaran', formatCurrency(data.totalSpentOnBudget), 
                      valueColor: isOverBudget ? redAccent : Colors.white),
                    
                    if (data.overBudgetCategoriesCount > 0) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: redAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: redAccent.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.info_outline_rounded, color: redAccent, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              '${data.overBudgetCategoriesCount} Kategori Melebihi Anggaran',
                              style: TextStyle(color: redAccent, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ]
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: isOverBudget ? 1.0 : (displayPercentage / 100),
                          strokeWidth: 8,
                          backgroundColor: Colors.black.withOpacity(0.05),
                          color: progressColor,
                        ),
                        Center(
                          child: Text(
                            '${data.overallAdherencePercentage.toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: primaryDark,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isOverBudget ? 'Melebihi Anggaran' : 'Sesuai Rencana',
                    style: TextStyle(
                      color: progressColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.show_chart_rounded, color: Color(0xFFA5C5CB), size: 20),
        const SizedBox(width: 8),
        Text(
          'Analisis Anggaran',
          style: TextStyle(
            color: primaryDark,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTextStat(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? primaryDark,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
