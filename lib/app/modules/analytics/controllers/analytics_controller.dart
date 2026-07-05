import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../../../data/models/analytics_model.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/services/auth_service.dart';

AnalyticsResponse _parseAnalyticsResponse(Map<String, dynamic> json) {
  return AnalyticsResponse.fromJson(json);
}

class AnalyticsController extends GetxController with StateMixin<AnalyticsResponse> {
  final ApiProvider _apiProvider = ApiProvider();
  final AuthService _authService = Get.find<AuthService>();

  // State untuk Dropdown Bulan
  var selectedMonth = DateTime.now().month.obs;
  var selectedYear = DateTime.now().year.obs;

  // Nama bulan untuk dropdown jika diperlukan (walaupun backend yang nentukan di metadata)
  final List<String> monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  String get currentMonthName => '${monthNames[selectedMonth.value - 1]} ${selectedYear.value}';

  @override
  void onInit() {
    super.onInit();
    fetchAnalytics();
  }

  void changeMonth(int month, int year) {
    selectedMonth.value = month;
    selectedYear.value = year;
    fetchAnalytics();
  }

  Future<void> fetchAnalytics() async {
    change(null, status: RxStatus.loading());
    try {
      final token = _authService.accessToken.value;
      if (token.isEmpty) {
        change(null, status: RxStatus.error('Token tidak tersedia. Silakan login kembali.'));
        return;
      }

      final response = await _apiProvider.getAnalyticsData(
        token: token,
        month: selectedMonth.value,
        year: selectedYear.value,
      );

      final analyticsData = await compute(_parseAnalyticsResponse, response as Map<String, dynamic>);
      change(analyticsData, status: RxStatus.success());
    } catch (e) {
      if (kDebugMode) print('Error fetching analytics: $e');
      change(null, status: RxStatus.error(e.toString()));
    }
  }

  Future<void> refreshAnalytics() async {
    await fetchAnalytics();
  }
}
