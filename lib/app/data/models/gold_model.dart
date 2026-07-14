import 'package:intl/intl.dart';

class GoldPriceModel {
  final String id;
  final String source;
  final int buyPrice;
  final int sellPrice;
  final String currency;
  final String marketDate;
  final DateTime scrapedAt;

  GoldPriceModel({
    required this.id,
    required this.source,
    required this.buyPrice,
    required this.sellPrice,
    required this.currency,
    required this.marketDate,
    required this.scrapedAt,
  });

  factory GoldPriceModel.fromJson(Map<String, dynamic> json) {
    return GoldPriceModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      source: json['source'] ?? '',
      buyPrice: (json['buy_price'] is int)
          ? json['buy_price']
          : int.tryParse(json['buy_price'].toString()) ?? 0,
      sellPrice: (json['sell_price'] is int)
          ? json['sell_price']
          : int.tryParse(json['sell_price'].toString()) ?? 0,
      currency: json['currency'] ?? 'IDR',
      marketDate: json['market_date'] ?? '',
      scrapedAt: json['scraped_at'] != null
          ? DateTime.parse(json['scraped_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'source': source,
      'buy_price': buyPrice,
      'sell_price': sellPrice,
      'currency': currency,
      'market_date': marketDate,
      'scraped_at': scrapedAt.toIso8601String(),
    };
  }

  /// Formatted buy price: "Rp 1.892.000"
  String get formattedBuyPrice {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(buyPrice);
  }

  /// Formatted sell price: "Rp 1.850.000"
  String get formattedSellPrice {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(sellPrice);
  }

  /// Short formatted: "1.892.000"
  String get shortBuyPrice {
    return buyPrice.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  /// Short formatted sell: "1.850.000"
  String get shortSellPrice {
    return sellPrice.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}

/// Helper to extract gold gram weight from asset notes using [GOLD_GRAM:X.X] format
class GoldGramHelper {
  static final RegExp _gramPattern = RegExp(r'\[GOLD_GRAM:([\d.]+)\]');

  /// Extract gram value from notes string. Returns null if not found.
  static double? extractGram(String? notes) {
    if (notes == null || notes.isEmpty) return null;
    final match = _gramPattern.firstMatch(notes);
    if (match == null) return null;
    return double.tryParse(match.group(1) ?? '');
  }

  /// Embed gram value into notes string. Replaces existing tag if present.
  static String embedGram(String? existingNotes, double grams) {
    final tag = '[GOLD_GRAM:${grams.toStringAsFixed(2)}]';
    if (existingNotes == null || existingNotes.isEmpty) return tag;
    if (_gramPattern.hasMatch(existingNotes)) {
      return existingNotes.replaceAll(_gramPattern, tag);
    }
    return '$existingNotes\n$tag';
  }

  /// Remove gram tag from notes
  static String removeGram(String? notes) {
    if (notes == null) return '';
    return notes.replaceAll(_gramPattern, '').trim();
  }
}
