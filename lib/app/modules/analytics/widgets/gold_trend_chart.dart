import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../data/models/gold_model.dart';

class GoldTrendChart extends StatelessWidget {
  final List<GoldPriceModel> history;
  final bool isLoading;

  const GoldTrendChart({
    Key? key,
    required this.history,
    this.isLoading = false,
  }) : super(key: key);

  static const Color _primaryDark = Color(0xFF0D2B33);
  static const Color _tealDark = Color(0xFF004D40);
  static const Color _tealMid = Color(0xFF00695C);
  static const Color _goldAccent = Color(0xFFD4A843);
  static const Color _greenUp = Color(0xFF00C853);
  static const Color _redDown = Color(0xFFFF1744);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            const Icon(Icons.hexagon_outlined, color: _goldAccent, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Tren Harga Emas',
              style: TextStyle(
                color: _primaryDark,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (history.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _tealDark.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${history.length} hari',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _tealDark,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        // Chart container
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(4, 20, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white,
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
          child: isLoading
              ? _buildShimmer()
              : history.isEmpty
                  ? _buildEmptyState()
                  : _buildChart(),
        ),
        // Price summary row
        if (history.length >= 2) ...[
          const SizedBox(height: 12),
          _buildPriceSummary(),
        ],
      ],
    );
  }

  Widget _buildChart() {
    // History comes in desc order (newest first), reverse for chart (oldest → newest on x-axis)
    final sortedHistory = history.reversed.toList();

    // Calculate min/max for y-axis with padding
    final prices = sortedHistory.map((e) => e.buyPrice.toDouble()).toList();
    final minPrice = prices.reduce((a, b) => a < b ? a : b);
    final maxPrice = prices.reduce((a, b) => a > b ? a : b);
    final priceRange = maxPrice - minPrice;
    final yPadding = priceRange > 0 ? priceRange * 0.15 : maxPrice * 0.05;

    // Determine trend direction for gradient coloring
    final isUptrend = sortedHistory.last.buyPrice >= sortedHistory.first.buyPrice;
    final trendColor = isUptrend ? _greenUp : _redDown;

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: priceRange > 0 ? (priceRange / 4) : maxPrice / 4,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.withOpacity(0.1),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 52,
                interval: priceRange > 0 ? (priceRange / 3) : maxPrice / 3,
                getTitlesWidget: (value, meta) {
                  // Format as compact currency
                  final formatted = _formatCompactPrice(value);
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      formatted,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: sortedHistory.length > 7
                    ? (sortedHistory.length / 5).ceilToDouble()
                    : 1,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= sortedHistory.length) {
                    return const SizedBox.shrink();
                  }
                  final date = sortedHistory[idx].marketDate;
                  try {
                    final parsed = DateTime.parse(date);
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        DateFormat('d/M').format(parsed),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  } catch (_) {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minY: minPrice - yPadding,
          maxY: maxPrice + yPadding,
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                sortedHistory.length,
                (i) => FlSpot(i.toDouble(), sortedHistory[i].buyPrice.toDouble()),
              ),
              isCurved: true,
              curveSmoothness: 0.25,
              color: trendColor,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  // Only show dots at first & last point
                  if (index == 0 || index == sortedHistory.length - 1) {
                    return FlDotCirclePainter(
                      radius: 3.5,
                      color: Colors.white,
                      strokeWidth: 2,
                      strokeColor: trendColor,
                    );
                  }
                  return FlDotCirclePainter(
                    radius: 0,
                    color: Colors.transparent,
                    strokeWidth: 0,
                    strokeColor: Colors.transparent,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    trendColor.withOpacity(0.15),
                    trendColor.withOpacity(0.02),
                  ],
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipRoundedRadius: 12,
              getTooltipItems: (spots) {
                return spots.map((spot) {
                  final idx = spot.x.toInt();
                  final item = sortedHistory[idx];
                  final formatted = NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: 'Rp ',
                    decimalDigits: 0,
                  ).format(item.buyPrice);
                  return LineTooltipItem(
                    '$formatted\n',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    children: [
                      TextSpan(
                        text: item.marketDate,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceSummary() {
    final newest = history.first; // desc order: index 0 = newest
    final oldest = history.last;  // last = oldest
    final diff = newest.buyPrice - oldest.buyPrice;
    final isUp = diff >= 0;
    final pct = oldest.buyPrice > 0 ? (diff.abs() / oldest.buyPrice * 100) : 0.0;

    return Row(
      children: [
        // Latest price
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _tealDark.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Harga Terbaru',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  newest.formattedBuyPrice,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _primaryDark,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Change
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isUp ? _greenUp : _redDown).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Perubahan',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                      color: isUp ? _greenUp : _redDown,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${pct.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isUp ? _greenUp : _redDown,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmer() {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(_tealMid.withOpacity(0.5)),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Memuat data harga emas...',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart_rounded, size: 32, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'Data historis belum tersedia',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCompactPrice(double value) {
    if (value >= 1e6) {
      return '${(value / 1e6).toStringAsFixed(1)} Jt';
    } else if (value >= 1e3) {
      return '${(value / 1e3).toStringAsFixed(0)} Rb';
    }
    return value.toStringAsFixed(0);
  }
}
