import 'package:get/get.dart';

class AnalyticsController extends GetxController {
  // State untuk Dropdown Bulan
  var selectedMonth = 'Maret 2024'.obs;
  final List<String> months = [
    'Januari 2024',
    'Februari 2024',
    'Maret 2024',
    'April 2024',
  ];

  void changeMonth(String? newMonth) {
    if (newMonth != null) {
      selectedMonth.value = newMonth;
    }
  }

  void optimizeBudget() {
    print("Membuka menu optimasi anggaran...");
  }

  void viewCategoryDetails() {
    print("Membuka detail kategori...");
  }

  Future<void> refreshAnalytics() async {
    await Future.delayed(const Duration(seconds: 1));
  }
}
