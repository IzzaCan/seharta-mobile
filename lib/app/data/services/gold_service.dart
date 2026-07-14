import 'package:flutter/foundation.dart';
import '../models/gold_model.dart';
import '../providers/api_provider.dart';

/// Top-level function for compute() isolation
List<GoldPriceModel> _parseGoldHistory(List<dynamic> data) {
  return data.map((json) => GoldPriceModel.fromJson(json)).toList();
}

class GoldService {
  final ApiProvider _apiProvider = ApiProvider();

  /// Fetch the latest gold price from /gold/latest
  Future<GoldPriceModel?> fetchLatestPrice() async {
    try {
      final response = await _apiProvider.getGoldLatestPrice();
      if (response['success'] == true && response['data'] != null) {
        return GoldPriceModel.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('GoldService.fetchLatestPrice error: $e');
      return null;
    }
  }

  /// Fetch gold price history from /gold/history
  /// Returns a list sorted by market_date descending (newest first)
  Future<List<GoldPriceModel>> fetchHistory({
    int page = 1,
    int limit = 30,
  }) async {
    try {
      final response = await _apiProvider.getGoldHistory(
        page: page,
        limit: limit,
      );
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'] as List<dynamic>;
        return await compute(_parseGoldHistory, data);
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('GoldService.fetchHistory error: $e');
      return [];
    }
  }
}
