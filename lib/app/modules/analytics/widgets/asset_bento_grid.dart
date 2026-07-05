import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../data/models/analytics_model.dart';

class AssetBentoGrid extends StatelessWidget {
  final AnalyticsAssetDistribution data;

  const AssetBentoGrid({
    Key? key,
    required this.data,
  }) : super(key: key);

  final Color primaryDark = const Color(0xFF0D2B33);
  final Color cardColor = const Color(0xFF0D2B33);

  // Colors based on the user's design image
  final Color walletsColor = const Color(0xFF3B82F6); // Blue
  final Color physicalAssetsColor = const Color(0xFF10B981); // Emerald
  final Color personalColor = const Color(0xFF8B5CF6); // Purple
  final Color jointColor = const Color(0xFFF59E0B); // Amber/Orange

  final List<Color> categoryColors = const [
    Color(0xFF10B981), // Emerald
    Color(0xFF3B82F6), // Blue
    Color(0xFFF59E0B), // Amber
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
  ];

  String formatCurrency(double value) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(value);
  }

  IconData _getIconForCategory(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'car':
      case 'kendaraan':
      case 'mobil':
      case 'vehicles':
        return Icons.directions_car_rounded;
      case 'home':
      case 'properti':
      case 'rumah':
      case 'property':
        return Icons.home_rounded;
      case 'savings':
      case 'tabungan':
      case 'reksadana':
      case 'saham':
        return Icons.savings_rounded;
      case 'devices':
      case 'elektronik':
      case 'electronics':
        return Icons.smartphone_rounded;
      case 'jewelry':
      case 'perhiasan':
        return Icons.diamond_rounded;
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCategoryData = data.byCategory.isNotEmpty;

    // Calculate Percentages for By Type
    final double totalType = data.byType.wallets + data.byType.physicalAssets;
    final double walletsPct = totalType > 0 ? (data.byType.wallets / totalType) * 100 : 0;
    final double physicalPct = totalType > 0 ? (data.byType.physicalAssets / totalType) * 100 : 0;

    // Calculate Percentages for By Ownership
    final double totalOwnership = data.byOwnership.joint + data.byOwnership.personal;
    final double personalPct = totalOwnership > 0 ? (data.byOwnership.personal / totalOwnership) * 100 : 0;
    final double jointPct = totalOwnership > 0 ? (data.byOwnership.joint / totalOwnership) * 100 : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.security_rounded, color: Color(0xFFA5C5CB), size: 20),
            const SizedBox(width: 8),
            Text(
              'Asset Distribution',
              style: TextStyle(
                color: primaryDark,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (!hasCategoryData && totalType == 0 && totalOwnership == 0)
          _buildEmptyState()
        else ...[
          // Row for By Type and By Ownership
          Row(
            children: [
              Expanded(
                child: _buildDonutCard(
                  title: 'By Type',
                  value1: data.byType.wallets,
                  value2: data.byType.physicalAssets,
                  pct1: walletsPct,
                  pct2: physicalPct,
                  label1: 'Wallets/Banks',
                  label2: 'Physical Assets',
                  color1: walletsColor,
                  color2: physicalAssetsColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDonutCard(
                  title: 'By Ownership',
                  value1: data.byOwnership.personal,
                  value2: data.byOwnership.joint,
                  pct1: personalPct,
                  pct2: jointPct,
                  label1: 'Personal',
                  label2: 'Joint',
                  color1: personalColor,
                  color2: jointColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Card for By Category
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'By Category',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ...data.byCategory.asMap().entries.map((entry) {
                  int idx = entry.key;
                  var cat = entry.value;
                  return _buildCategoryItem(cat, categoryColors[idx % categoryColors.length]);
                }).toList(),
              ],
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildDonutCard({
    required String title,
    required double value1,
    required double value2,
    required double pct1,
    required double pct2,
    required String label1,
    required String label2,
    required Color color1,
    required Color color2,
  }) {
    // If both values are 0, use dummy data so the donut renders grey
    final bool isEmpty = value1 == 0 && value2 == 0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 30,
                sections: isEmpty
                    ? [
                        PieChartSectionData(color: Colors.white12, value: 1, title: '', radius: 16),
                      ]
                    : [
                        if (value1 > 0)
                          PieChartSectionData(color: color1, value: value1, title: '', radius: 18),
                        if (value2 > 0)
                          PieChartSectionData(color: color2, value: value2, title: '', radius: 18),
                      ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildLegendRow(color1, label1, pct1),
          const SizedBox(height: 8),
          _buildLegendRow(color2, label2, pct2),
        ],
      ),
    );
  }

  Widget _buildLegendRow(Color color, String label, double percentage) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
        ),
        Text(
          '${percentage.toStringAsFixed(0)}%',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(AssetDistributionByCategory cat, Color barColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_getIconForCategory(cat.iconName), color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  cat.categoryName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                formatCurrency(cat.totalValue),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Row(
              children: [
                if (cat.percentage > 0)
                  Expanded(
                    flex: (cat.percentage * 100).toInt(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                if (cat.percentage < 100)
                  Expanded(
                    flex: ((100 - cat.percentage) * 100).toInt(),
                    child: const SizedBox(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${cat.percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined, color: Colors.white.withOpacity(0.3), size: 48),
          const SizedBox(height: 12),
          Text(
            'Belum ada aset tercatat',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
