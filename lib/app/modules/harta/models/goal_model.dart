import 'package:intl/intl.dart';

double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

class GoalModel {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final double progressPercentage;
  final double remainingAmount;
  final DateTime? deadline;
  final String? note;
  final DateTime createdAt;

  GoalModel({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.progressPercentage,
    required this.remainingAmount,
    this.deadline,
    this.note,
    required this.createdAt,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      targetAmount: _parseDouble(json['target_amount']),
      currentAmount: _parseDouble(json['current_amount']),
      progressPercentage: _parseDouble(json['progress_percentage']),
      remainingAmount: _parseDouble(json['remaining_amount']),
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      note: json['note'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }

  String get formattedDeadline {
    if (deadline == null) return 'Tanpa Target';
    return DateFormat('dd MMMM yyyy').format(deadline!);
  }
}

class GoalContributionModel {
  final String id;
  final String goalId;
  final double amount;
  final String transactionType; // DEPOSIT or WITHDRAWAL
  final String? note;
  final DateTime contributionDate;
  final String? contributorName;
  final String? walletName;

  GoalContributionModel({
    required this.id,
    required this.goalId,
    required this.amount,
    required this.transactionType,
    this.note,
    required this.contributionDate,
    this.contributorName,
    this.walletName,
  });

  factory GoalContributionModel.fromJson(Map<String, dynamic> json) {
    return GoalContributionModel(
      id: json['id'] ?? '',
      goalId: json['goal_id'] ?? '',
      amount: _parseDouble(json['amount']),
      transactionType: json['transaction_type'] ?? 'DEPOSIT',
      note: json['note'],
      contributionDate: json['contribution_date'] != null 
          ? DateTime.parse(json['contribution_date']) 
          : DateTime.now(),
      contributorName: json['contributor_name'],
      walletName: json['wallet_name'],
    );
  }
}

class GoalDetailModel extends GoalModel {
  final List<GoalContributionModel> contributions;

  GoalDetailModel({
    required String id,
    required String name,
    required double targetAmount,
    required double currentAmount,
    required double progressPercentage,
    required double remainingAmount,
    DateTime? deadline,
    String? note,
    required DateTime createdAt,
    required this.contributions,
  }) : super(
          id: id,
          name: name,
          targetAmount: targetAmount,
          currentAmount: currentAmount,
          progressPercentage: progressPercentage,
          remainingAmount: remainingAmount,
          deadline: deadline,
          note: note,
          createdAt: createdAt,
        );

  factory GoalDetailModel.fromJson(Map<String, dynamic> json) {
    var list = json['contributions'] as List? ?? [];
    List<GoalContributionModel> contribs = list.map((i) => GoalContributionModel.fromJson(i)).toList();

    return GoalDetailModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      targetAmount: _parseDouble(json['target_amount']),
      currentAmount: _parseDouble(json['current_amount']),
      progressPercentage: _parseDouble(json['progress_percentage']),
      remainingAmount: _parseDouble(json['remaining_amount']),
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      note: json['note'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      contributions: contribs,
    );
  }
}
