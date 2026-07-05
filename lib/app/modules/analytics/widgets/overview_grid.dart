import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/analytics_model.dart';

class OverviewGrid extends StatelessWidget {
  final AnalyticsOverview overview;

  const OverviewGrid({
    Key? key,
    required this.overview,
  }) : super(key: key);

  final Color primaryDark = const Color(0xFF0D2B33);
  final Color cardColor = const Color(0xFF0D2B33);

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
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.9,
      children: [
        _buildStatCard(
          title: 'Net Worth',
          value: formatCurrency(overview.netWorth),
          icon: Icons.account_balance_wallet_outlined,
          iconColor: const Color(0xFFA5C5CB),
        ),
        _buildStatCard(
          title: 'Liquidity',
          value: formatCurrency(overview.totalLiquidity),
          icon: Icons.link_rounded,
          iconColor: const Color(0xFF4ADE80),
        ),
        _buildStatCard(
          title: 'Total Assets',
          value: formatCurrency(overview.totalAssetValue),
          icon: Icons.pie_chart_outline_rounded,
          iconColor: const Color(0xFFB39DDB),
        ),
        _buildStatCard(
          title: 'Savings Rate',
          value: '${overview.savingsRatePercentage.toStringAsFixed(1)}%',
          icon: Icons.savings_outlined,
          iconColor: const Color(0xFF047857),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
