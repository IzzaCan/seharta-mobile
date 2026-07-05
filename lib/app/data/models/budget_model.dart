class BudgetModel {
  final String id;
  final String categoryId;
  final String categoryName;
  final double limitAmount;
  final double spentAmount;
  final double remainingAmount;
  final int month;
  final int year;

  BudgetModel({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.limitAmount,
    required this.spentAmount,
    required this.remainingAmount,
    required this.month,
    required this.year,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] ?? '',
      categoryId: json['category_id'] ?? '',
      categoryName: json['category_name'] ?? 'Kategori',
      limitAmount: _parseDouble(json['budget_amount'] ?? json['limit_amount']),
      spentAmount: _parseDouble(json['spent_amount']),
      remainingAmount: _parseDouble(json['remaining_amount']),
      month: json['month'] ?? DateTime.now().month,
      year: json['year'] ?? DateTime.now().year,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'category_name': categoryName,
      'limit_amount': limitAmount,
      'spent_amount': spentAmount,
      'remaining_amount': remainingAmount,
      'month': month,
      'year': year,
    };
  }
}
