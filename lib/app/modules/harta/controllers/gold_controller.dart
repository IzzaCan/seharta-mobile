import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/gold_model.dart';
import '../../../data/services/gold_service.dart';

class GoldController extends GetxController {
  final GoldService _goldService = GoldService();

  // State
  var latestPrice = Rxn<GoldPriceModel>();
  var previousPrice = Rxn<GoldPriceModel>();
  var priceHistory = <GoldPriceModel>[].obs;
  var isLoading = false.obs;
  var hasError = false.obs;
  var isUsingCache = false.obs;

  // SharedPreferences cache keys
  static const String _cacheBuyPriceKey = 'gold_cache_buy_price';
  static const String _cacheSellPriceKey = 'gold_cache_sell_price';
  static const String _cacheMarketDateKey = 'gold_cache_market_date';
  static const String _cacheSourceKey = 'gold_cache_source';

  /// Price change percentage compared to previous day
  double get priceChangePercent {
    if (latestPrice.value == null || previousPrice.value == null) return 0.0;
    final current = latestPrice.value!.buyPrice;
    final previous = previousPrice.value!.buyPrice;
    if (previous == 0) return 0.0;
    return ((current - previous) / previous) * 100;
  }

  /// Whether price went up
  bool get isUp => priceChangePercent >= 0;

  /// Price difference in absolute IDR
  int get priceDifference {
    if (latestPrice.value == null || previousPrice.value == null) return 0;
    return latestPrice.value!.buyPrice - previousPrice.value!.buyPrice;
  }

  /// Calculate current gold asset value from grams (Using Sell Price / Buyback for liquid asset valuation)
  double calculateGoldValue(double grams) {
    final price = latestPrice.value?.sellPrice ?? 0;
    return grams * price;
  }

  /// Get the current buy price (0 if unavailable)
  int get currentBuyPrice => latestPrice.value?.buyPrice ?? 0;

  /// Get the current sell price (0 if unavailable)
  int get currentSellPrice => latestPrice.value?.sellPrice ?? 0;

  @override
  void onInit() {
    super.onInit();
    fetchGoldPrice();
  }

  /// Fetch latest gold price + previous day for comparison
  Future<void> fetchGoldPrice() async {
    try {
      isLoading(true);
      hasError(false);
      isUsingCache(false);

      // Fetch latest price
      final latest = await _goldService.fetchLatestPrice();

      if (latest != null) {
        latestPrice.value = latest;
        await _cachePrice(latest);

        // Fetch history (2 items) to get previous day price
        final history = await _goldService.fetchHistory(page: 1, limit: 2);
        if (history.length >= 2) {
          previousPrice.value = history[1]; // second item = yesterday
        }
      } else {
        // API failed → load from cache
        hasError(true);
        await _loadCachedPrice();
      }
    } catch (e) {
      if (kDebugMode) print('GoldController.fetchGoldPrice error: $e');
      hasError(true);
      await _loadCachedPrice();
    } finally {
      isLoading(false);
    }
  }

  /// Fetch extended history for Analytics chart
  Future<void> fetchGoldHistory({int limit = 30}) async {
    try {
      final history = await _goldService.fetchHistory(page: 1, limit: limit);
      priceHistory.assignAll(history);
    } catch (e) {
      if (kDebugMode) print('GoldController.fetchGoldHistory error: $e');
    }
  }

  /// Save latest price to SharedPreferences as fallback
  Future<void> _cachePrice(GoldPriceModel price) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_cacheBuyPriceKey, price.buyPrice);
      await prefs.setInt(_cacheSellPriceKey, price.sellPrice);
      await prefs.setString(_cacheMarketDateKey, price.marketDate);
      await prefs.setString(_cacheSourceKey, price.source);
    } catch (e) {
      if (kDebugMode) print('GoldController._cachePrice error: $e');
    }
  }

  /// Load cached price from SharedPreferences when API fails
  Future<void> _loadCachedPrice() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedBuy = prefs.getInt(_cacheBuyPriceKey);
      final cachedSell = prefs.getInt(_cacheSellPriceKey);
      final cachedDate = prefs.getString(_cacheMarketDateKey);
      final cachedSource = prefs.getString(_cacheSourceKey);

      if (cachedBuy != null && cachedSell != null) {
        isUsingCache(true);
        latestPrice.value = GoldPriceModel(
          id: 'cached',
          source: cachedSource ?? 'Cache',
          buyPrice: cachedBuy,
          sellPrice: cachedSell,
          currency: 'IDR',
          marketDate: cachedDate ?? '',
          scrapedAt: DateTime.now(),
        );
      }
    } catch (e) {
      if (kDebugMode) print('GoldController._loadCachedPrice error: $e');
    }
  }
}
