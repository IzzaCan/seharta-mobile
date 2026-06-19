class WalletModel {
  final String id;
  final String walletName;
  final double balance;
  final bool isActive;

  WalletModel({
    required this.id,
    required this.walletName,
    required this.balance,
    required this.isActive,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] ?? '',
      walletName: json['wallet_name'] ?? '',
      balance: json['balance'] is String
          ? (double.tryParse(json['balance']) ?? 0.0)
          : (json['balance'] ?? 0).toDouble(),
      isActive: json['is_active'] ?? true,
    );
  }
}

class TransactionModel {
  final String id;
  final String transactionType; // 'INCOME' or 'EXPENSE'
  final double amount;
  final String? notes;
  final String transactionDate;
  final String? categoryId;
  final String? walletId;
  final String? userId;
  final String? creatorName;
  final String? creatorAvatarUrl;

  TransactionModel({
    required this.id,
    required this.transactionType,
    required this.amount,
    this.notes,
    required this.transactionDate,
    this.categoryId,
    this.walletId,
    this.userId,
    this.creatorName,
    this.creatorAvatarUrl,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      transactionType: json['transaction_type'] ?? 'EXPENSE',
      amount: json['amount'] is String
          ? (double.tryParse(json['amount']) ?? 0.0)
          : (json['amount'] ?? 0).toDouble(),
      notes: json['description'] ?? json['notes'],
      transactionDate: json['transaction_date'] ?? '',
      categoryId: json['category_id'],
      walletId: json['wallet_id'],
      userId: json['user_id'],
      creatorName: json['creator_name'],
      creatorAvatarUrl: json['creator_avatar_url'],
    );
  }
}
