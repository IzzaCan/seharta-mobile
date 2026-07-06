import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../data/models/analytics_model.dart';

class ExpenseDonutChart extends StatelessWidget {
  final List<AnalyticsCategoryBreakdown> categoryBreakdown;

  const ExpenseDonutChart({
    Key? key,
    required this.categoryBreakdown,
  }) : super(key: key);

  final Color primaryDark = const Color(0xFF0D2B33);
  final Color cardColor = Colors.white;

  final List<Color> chartColors = const [
    Color(0xFF3B82F6), // Blue
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFF8B5CF6), // Violet
    Color(0xFF64748B), // Slate
    Color(0xFFEC4899), // Pink
  ];

  String formatCurrency(double value) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(value);
  }

  @override
  Widget build(BuildContext context) {
    final hasData = categoryBreakdown.isNotEmpty;
    final double totalExpense = categoryBreakdown.fold(0.0, (sum, item) => sum + item.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.shopping_bag_outlined, color: Color(0xFFA5C5CB), size: 20),
            const SizedBox(width: 8),
            Text(
              'Rincian Pengeluaran',
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
          width: double.infinity,
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
          child: !hasData
              ? _buildEmptyState()
              : Column(
                  children: [
                    SizedBox(
                      height: 180,
                      child: Stack(
                        children: [
                          RepaintBoundary(
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 50,
                                sections: categoryBreakdown.asMap().entries.map((entry) {
                                  int idx = entry.key;
                                  var cat = entry.value;
                                  return PieChartSectionData(
                                    color: chartColors[idx % chartColors.length],
                                    value: cat.amount,
                                    title: '',
                                    radius: 20,
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Total',
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.5),
                                    fontSize: 12,
                                  ),
                                ),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    formatCurrencyCompact(totalExpense),
                                    style: TextStyle(
                                      color: primaryDark,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Column(
                      children: categoryBreakdown.asMap().entries.map((entry) {
                        int idx = entry.key;
                        var cat = entry.value;
                        return _buildLegendItem(
                          color: chartColors[idx % chartColors.length],
                          title: cat.categoryName,
                          percentage: cat.percentage,
                          amount: cat.amount,
                        );
                      }).toList(),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined, color: primaryDark.withOpacity(0.3), size: 48),
          const SizedBox(height: 12),
          Text(
            'Belum ada pengeluaran tercatat',
            style: TextStyle(
              color: primaryDark.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String title,
    required double percentage,
    required double amount,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: primaryDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatCurrency(amount),
            style: TextStyle(
              color: primaryDark,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String formatCurrencyCompact(double value) {
    if (value >= 1e9) {
      return '${(value / 1e9).toStringAsFixed(1)} M';
    } else if (value >= 1e6) {
      return '${(value / 1e6).toStringAsFixed(1)} Jt';
    } else {
      return value.toStringAsFixed(0);
    }
  }
}
