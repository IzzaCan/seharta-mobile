import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../harta/controllers/gold_controller.dart';

class GoldSimulatorCard extends StatefulWidget {
  const GoldSimulatorCard({Key? key}) : super(key: key);

  @override
  State<GoldSimulatorCard> createState() => _GoldSimulatorCardState();
}

class _GoldSimulatorCardState extends State<GoldSimulatorCard> {
  double _grams = 10.0;
  final Color primaryDark = const Color(0xFF0D2B33);
  final Color tealMid = const Color(0xFF00695C);
  final Color greenUp = const Color(0xFF00C853);
  final Color redDown = const Color(0xFFFF1744);
  final Color goldAccent = const Color(0xFFD4A843);

  String _formatCurrency(double value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  @override
  Widget build(BuildContext context) {
    return GetX<GoldController>(
      builder: (goldCtrl) {
        if (goldCtrl.isLoading.value) {
          return const SizedBox.shrink(); // Hide while loading
        }
        final history = goldCtrl.priceHistory;
        if (history.length < 2) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black.withOpacity(0.05)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: goldAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.calculate_outlined, color: Color(0xFFD4A843), size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Simulator Investasi Emas',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D2B33),
                            ),
                          ),
                          Text(
                            'Simulasi keuntungan masa lalu',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black.withOpacity(0.04)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 28, color: Colors.grey[400]),
                      const SizedBox(height: 10),
                      Text(
                        'Data historis emas belum mencukupi (minimal 2 hari) untuk menjalankan simulasi profit.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // Newest is index 0 (use sell price/buyback for current liquidation value), oldest is last (use buy price for initial investment cost)
        final currentPrice = history.first.sellPrice.toDouble();
        final pastPrice = history.last.buyPrice.toDouble();
        final days = history.length;

        final initialInvestment = pastPrice * _grams;
        final currentValue = currentPrice * _grams;
        final profit = currentValue - initialInvestment;
        final isProfit = profit >= 0;
        final percentage = (profit.abs() / initialInvestment) * 100;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: goldAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.calculate_outlined, color: Color(0xFFD4A843), size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Simulator Investasi Emas',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D2B33),
                          ),
                        ),
                        Text(
                          'Geser untuk simulasi simulasi masa lalu',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Berat Emas',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryDark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_grams.toStringAsFixed(0)} Gram',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: tealMid,
                  inactiveTrackColor: tealMid.withOpacity(0.1),
                  thumbColor: Colors.white,
                  overlayColor: tealMid.withOpacity(0.1),
                  trackHeight: 6,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10, elevation: 3),
                ),
                child: Slider(
                  value: _grams,
                  min: 1.0,
                  max: 100.0,
                  divisions: 99,
                  onChanged: (val) {
                    setState(() {
                      _grams = val;
                    });
                  },
                ),
              ),

              const SizedBox(height: 16),
              
              // Result Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (isProfit ? greenUp : redDown).withOpacity(0.1),
                      (isProfit ? greenUp : redDown).withOpacity(0.02),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (isProfit ? greenUp : redDown).withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Jika Anda membeli ${_grams.toStringAsFixed(0)} gram $days hari lalu,',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Modal Awal',
                              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatCurrency(initialInvestment),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0D2B33),
                              ),
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_forward_rounded, color: Colors.grey, size: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Nilai Sekarang',
                              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatCurrency(currentValue),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0D2B33),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1, color: Colors.black12),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isProfit ? 'Keuntungan Anda:' : 'Penurunan Nilai:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isProfit ? greenUp : redDown,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isProfit ? Icons.trending_up : Icons.trending_down,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '+${_formatCurrency(profit.abs())} (${percentage.toStringAsFixed(1)}%)',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
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
        );
      },
    );
  }
}
