import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/analytics_model.dart';

class BehavioralInsights extends StatelessWidget {
  final BehavioralSummary summary;

  const BehavioralInsights({
    Key? key,
    required this.summary,
  }) : super(key: key);

  final Color primaryDark = const Color(0xFF0D2B33);
  final Color cardColor = Colors.white;

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
    if (summary.highestSpender == null && summary.mostActiveMember == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.psychology_outlined, color: Color(0xFFA5C5CB), size: 20),
            const SizedBox(width: 8),
            Text(
              'Wawasan Perilaku',
              style: TextStyle(
                color: primaryDark,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (summary.highestSpender != null)
              Expanded(
                child: _buildInsightCard(
                  title: 'PENGELUAR TERBANYAK',
                  name: summary.highestSpender!.userName,
                  subtitle: formatCurrency(summary.highestSpender!.totalSpent),
                  avatarColor: const Color(0xFF3B82F6),
                ),
              ),
            if (summary.highestSpender != null && summary.mostActiveMember != null)
              const SizedBox(width: 12),
            if (summary.mostActiveMember != null)
              Expanded(
                child: _buildInsightCard(
                  title: 'PALING AKTIF',
                  name: summary.mostActiveMember!.userName,
                  subtitle: '${summary.mostActiveMember!.transactionCount} Transaksi',
                  avatarColor: const Color(0xFF8B5CF6),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildInsightCard({
    required String title,
    required String name,
    required String subtitle,
    required Color avatarColor,
  }) {
    // Generate initials (max 2 characters)
    String initials = "U";
    if (name.isNotEmpty) {
      final parts = name.trim().split(RegExp(r'\s+'));
      if (parts.length > 1) {
        initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else {
        initials = name.substring(0, name.length > 1 ? 2 : 1).toUpperCase();
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
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
              color: Colors.black54,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: avatarColor.withOpacity(0.2),
                child: Text(
                  initials,
                  style: TextStyle(
                    color: avatarColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: primaryDark,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          color: avatarColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
