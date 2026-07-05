class AnalyticsOverview {
  final double netWorth;
  final double totalLiquidity;
  final double totalAssetValue;
  final double savingsRatePercentage;

  AnalyticsOverview({
    required this.netWorth,
    required this.totalLiquidity,
    required this.totalAssetValue,
    required this.savingsRatePercentage,
  });

  factory AnalyticsOverview.fromJson(Map<String, dynamic> json) {
    return AnalyticsOverview(
      netWorth: (json['net_worth'] ?? 0).toDouble(),
      totalLiquidity: (json['total_liquidity'] ?? 0).toDouble(),
      totalAssetValue: (json['total_asset_value'] ?? 0).toDouble(),
      savingsRatePercentage: (json['savings_rate_percentage'] ?? 0).toDouble(),
    );
  }
}

class AnalyticsIncomeVsExpense {
  final double totalIncome;
  final double totalExpense;
  final double netSurplus;
  final double expenseToIncomeRatio;

  AnalyticsIncomeVsExpense({
    required this.totalIncome,
    required this.totalExpense,
    required this.netSurplus,
    required this.expenseToIncomeRatio,
  });

  factory AnalyticsIncomeVsExpense.fromJson(Map<String, dynamic> json) {
    return AnalyticsIncomeVsExpense(
      totalIncome: (json['total_income'] ?? 0).toDouble(),
      totalExpense: (json['total_expense'] ?? 0).toDouble(),
      netSurplus: (json['net_surplus'] ?? 0).toDouble(),
      expenseToIncomeRatio: (json['expense_to_income_ratio'] ?? 0).toDouble(),
    );
  }
}

class AnalyticsCategoryBreakdown {
  final String categoryId;
  final String categoryName;
  final double amount;
  final double percentage;

  AnalyticsCategoryBreakdown({
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.percentage,
  });

  factory AnalyticsCategoryBreakdown.fromJson(Map<String, dynamic> json) {
    return AnalyticsCategoryBreakdown(
      categoryId: json['category_id'] ?? '',
      categoryName: json['category_name'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }
}

class AnalyticsBudgetAnalysis {
  final double totalBudgeted;
  final double totalSpentOnBudget;
  final double overallAdherencePercentage;
  final int overBudgetCategoriesCount;

  AnalyticsBudgetAnalysis({
    required this.totalBudgeted,
    required this.totalSpentOnBudget,
    required this.overallAdherencePercentage,
    required this.overBudgetCategoriesCount,
  });

  factory AnalyticsBudgetAnalysis.fromJson(Map<String, dynamic> json) {
    return AnalyticsBudgetAnalysis(
      totalBudgeted: (json['total_budgeted'] ?? 0).toDouble(),
      totalSpentOnBudget: (json['total_spent_on_budget'] ?? 0).toDouble(),
      overallAdherencePercentage: (json['overall_adherence_percentage'] ?? 0).toDouble(),
      overBudgetCategoriesCount: json['over_budget_categories_count'] ?? 0,
    );
  }
}

class AssetDistributionByType {
  final double wallets;
  final double physicalAssets;

  AssetDistributionByType({
    required this.wallets,
    required this.physicalAssets,
  });

  factory AssetDistributionByType.fromJson(Map<String, dynamic> json) {
    return AssetDistributionByType(
      wallets: (json['wallets'] ?? 0).toDouble(),
      physicalAssets: (json['physical_assets'] ?? 0).toDouble(),
    );
  }
}

class AssetDistributionByOwnership {
  final double joint;
  final double personal;

  AssetDistributionByOwnership({
    required this.joint,
    required this.personal,
  });

  factory AssetDistributionByOwnership.fromJson(Map<String, dynamic> json) {
    return AssetDistributionByOwnership(
      joint: (json['joint'] ?? 0).toDouble(),
      personal: (json['personal'] ?? 0).toDouble(),
    );
  }
}

class AssetDistributionByCategory {
  final String categoryId;
  final String categoryName;
  final String? iconName;
  final int assetCount;
  final double totalValue;
  final double percentage;

  AssetDistributionByCategory({
    required this.categoryId,
    required this.categoryName,
    this.iconName,
    required this.assetCount,
    required this.totalValue,
    required this.percentage,
  });

  factory AssetDistributionByCategory.fromJson(Map<String, dynamic> json) {
    return AssetDistributionByCategory(
      categoryId: json['category_id'] ?? '',
      categoryName: json['category_name'] ?? '',
      iconName: json['icon_name'],
      assetCount: json['asset_count'] ?? 0,
      totalValue: (json['total_value'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }
}

class AnalyticsAssetDistribution {
  final AssetDistributionByType byType;
  final AssetDistributionByOwnership byOwnership;
  final List<AssetDistributionByCategory> byCategory;

  AnalyticsAssetDistribution({
    required this.byType,
    required this.byOwnership,
    required this.byCategory,
  });

  factory AnalyticsAssetDistribution.fromJson(Map<String, dynamic> json) {
    return AnalyticsAssetDistribution(
      byType: AssetDistributionByType.fromJson(json['by_type'] ?? {}),
      byOwnership: AssetDistributionByOwnership.fromJson(json['by_ownership'] ?? {}),
      byCategory: (json['by_category'] as List?)
              ?.map((e) => AssetDistributionByCategory.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class UserSpenderSummary {
  final String userId;
  final String userName;
  final double totalSpent;

  UserSpenderSummary({
    required this.userId,
    required this.userName,
    required this.totalSpent,
  });

  factory UserSpenderSummary.fromJson(Map<String, dynamic> json) {
    return UserSpenderSummary(
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      totalSpent: (json['total_spent'] ?? 0).toDouble(),
    );
  }
}

class UserActivitySummary {
  final String userId;
  final String userName;
  final int transactionCount;

  UserActivitySummary({
    required this.userId,
    required this.userName,
    required this.transactionCount,
  });

  factory UserActivitySummary.fromJson(Map<String, dynamic> json) {
    return UserActivitySummary(
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      transactionCount: json['transaction_count'] ?? 0,
    );
  }
}

class BehavioralSummary {
  final UserSpenderSummary? highestSpender;
  final UserActivitySummary? mostActiveMember;

  BehavioralSummary({
    this.highestSpender,
    this.mostActiveMember,
  });

  factory BehavioralSummary.fromJson(Map<String, dynamic> json) {
    return BehavioralSummary(
      highestSpender: json['highest_spender'] != null
          ? UserSpenderSummary.fromJson(json['highest_spender'])
          : null,
      mostActiveMember: json['most_active_member'] != null
          ? UserActivitySummary.fromJson(json['most_active_member'])
          : null,
    );
  }
}

class UserSpendingDistribution {
  final String userId;
  final String userName;
  final String? avatarUrl;
  final double totalSpent;
  final int transactionCount;
  final double averageTransaction;
  final double percentageOfTotal;
  final String? favoriteCategory;

  UserSpendingDistribution({
    required this.userId,
    required this.userName,
    this.avatarUrl,
    required this.totalSpent,
    required this.transactionCount,
    required this.averageTransaction,
    required this.percentageOfTotal,
    this.favoriteCategory,
  });

  factory UserSpendingDistribution.fromJson(Map<String, dynamic> json) {
    return UserSpendingDistribution(
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      avatarUrl: json['avatar_url'],
      totalSpent: (json['total_spent'] ?? 0).toDouble(),
      transactionCount: json['transaction_count'] ?? 0,
      averageTransaction: (json['average_transaction'] ?? 0).toDouble(),
      percentageOfTotal: (json['percentage_of_total'] ?? 0).toDouble(),
      favoriteCategory: json['favorite_category'],
    );
  }
}

class UserSpendingHabit {
  final String userId;
  final String userName;
  final String? mostActiveDay;
  final String? mostActiveHour;

  UserSpendingHabit({
    required this.userId,
    required this.userName,
    this.mostActiveDay,
    this.mostActiveHour,
  });

  factory UserSpendingHabit.fromJson(Map<String, dynamic> json) {
    return UserSpendingHabit(
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      mostActiveDay: json['most_active_day'],
      mostActiveHour: json['most_active_hour'],
    );
  }
}

class AnalyticsBehavioralAnalytics {
  final BehavioralSummary summary;
  final List<UserSpendingDistribution> spendingDistribution;
  final List<UserSpendingHabit> spendingHabit;

  AnalyticsBehavioralAnalytics({
    required this.summary,
    required this.spendingDistribution,
    required this.spendingHabit,
  });

  factory AnalyticsBehavioralAnalytics.fromJson(Map<String, dynamic> json) {
    return AnalyticsBehavioralAnalytics(
      summary: BehavioralSummary.fromJson(json['summary'] ?? {}),
      spendingDistribution: (json['spending_distribution'] as List?)
              ?.map((e) => UserSpendingDistribution.fromJson(e))
              .toList() ??
          [],
      spendingHabit: (json['spending_habit'] as List?)
              ?.map((e) => UserSpendingHabit.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class AnalyticsCurrentFilter {
  final int month;
  final int year;
  final String ownershipType;

  AnalyticsCurrentFilter({
    required this.month,
    required this.year,
    required this.ownershipType,
  });

  factory AnalyticsCurrentFilter.fromJson(Map<String, dynamic> json) {
    return AnalyticsCurrentFilter(
      month: json['month'] ?? 0,
      year: json['year'] ?? 0,
      ownershipType: json['ownership_type'] ?? 'ALL',
    );
  }
}

class AnalyticsFilterMetadata {
  final DateTime? earliestTransactionDate;
  final List<int> availableYears;
  final List<int> availableMonths;
  final AnalyticsCurrentFilter currentFilter;

  AnalyticsFilterMetadata({
    this.earliestTransactionDate,
    required this.availableYears,
    required this.availableMonths,
    required this.currentFilter,
  });

  factory AnalyticsFilterMetadata.fromJson(Map<String, dynamic> json) {
    return AnalyticsFilterMetadata(
      earliestTransactionDate: json['earliest_transaction_date'] != null
          ? DateTime.tryParse(json['earliest_transaction_date'])
          : null,
      availableYears: List<int>.from(json['available_years'] ?? []),
      availableMonths: List<int>.from(json['available_months'] ?? []),
      currentFilter: AnalyticsCurrentFilter.fromJson(json['current_filter'] ?? {}),
    );
  }
}

class AnalyticsResponse {
  final AnalyticsOverview overview;
  final AnalyticsIncomeVsExpense incomeVsExpense;
  final List<AnalyticsCategoryBreakdown> categoryBreakdown;
  final AnalyticsBudgetAnalysis budgetAnalysis;
  final AnalyticsAssetDistribution assetDistribution;
  final AnalyticsBehavioralAnalytics behavioralAnalytics;
  final AnalyticsFilterMetadata filterMetadata;

  AnalyticsResponse({
    required this.overview,
    required this.incomeVsExpense,
    required this.categoryBreakdown,
    required this.budgetAnalysis,
    required this.assetDistribution,
    required this.behavioralAnalytics,
    required this.filterMetadata,
  });

  factory AnalyticsResponse.fromJson(Map<String, dynamic> json) {
    return AnalyticsResponse(
      overview: AnalyticsOverview.fromJson(json['overview'] ?? {}),
      incomeVsExpense: AnalyticsIncomeVsExpense.fromJson(json['income_vs_expense'] ?? {}),
      categoryBreakdown: (json['category_breakdown'] as List?)
              ?.map((e) => AnalyticsCategoryBreakdown.fromJson(e))
              .toList() ??
          [],
      budgetAnalysis: AnalyticsBudgetAnalysis.fromJson(json['budget_analysis'] ?? {}),
      assetDistribution: AnalyticsAssetDistribution.fromJson(json['asset_distribution'] ?? {}),
      behavioralAnalytics: AnalyticsBehavioralAnalytics.fromJson(json['behavioral_analytics'] ?? {}),
      filterMetadata: AnalyticsFilterMetadata.fromJson(json['filter_metadata'] ?? {}),
    );
  }
}
