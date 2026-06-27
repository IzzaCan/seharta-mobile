import 'package:get/get.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/services/auth_service.dart';
import '../models/wallet_model.dart';
import '../../harta/models/goal_model.dart';

class WalletProvider {
  final ApiProvider _apiProvider = ApiProvider();
  final AuthService _authService = Get.find<AuthService>();

  Future<List<WalletModel>> fetchWallets() async {
    final token = _authService.accessToken.value;
    if (token.isEmpty) throw Exception('Sesi telah habis, silakan login kembali.');

    final response = await _apiProvider.get('/wallets/', token: token);
    
    // Backend return `list[WalletResponse]`, ApiProvider wrap it to `{'data': [...]}`
    List<dynamic> data = response['data'] ?? [];
    return data.map((item) => WalletModel.fromJson(item)).toList();
  }

  Future<List<TransactionModel>> fetchTransactions() async {
    final token = _authService.accessToken.value;
    if (token.isEmpty) throw Exception('Sesi telah habis, silakan login kembali.');

    final response = await _apiProvider.get('/transactions/?size=20', token: token);
    
    // Backend return `TransactionListResponse` which has `items` array
    List<dynamic> data = response['items'] ?? response['data'] ?? [];
    return data.map((item) => TransactionModel.fromJson(item)).toList();
  }

  Future<WalletModel> createWallet(String name, double initialBalance) async {
    final token = _authService.accessToken.value;
    if (token.isEmpty) throw Exception('Sesi telah habis, silakan login kembali.');

    final payload = {
      'wallet_name': name,
      'initial_balance': initialBalance,
    };

    final response = await _apiProvider.post('/wallets/', payload, token: token);
    return WalletModel.fromJson(response);
  }

  Future<void> deleteWallet(String walletId) async {
    final token = _authService.accessToken.value;
    if (token.isEmpty) throw Exception('Sesi telah habis, silakan login kembali.');

    await _apiProvider.delete('/wallets/$walletId', token: token);
  }

  Future<TransactionModel> createTransaction({
    required String walletId,
    required String categoryId,
    required double amount,
    String? description,
    String? transactionDate,
  }) async {
    final token = _authService.accessToken.value;
    if (token.isEmpty) throw Exception('Sesi telah habis, silakan login kembali.');

    final payload = {
      'wallet_id': walletId,
      'category_id': categoryId,
      'amount': amount,
    };
    if (description != null && description.isNotEmpty) {
      payload['description'] = description;
    }
    if (transactionDate != null && transactionDate.isNotEmpty) {
      payload['transaction_date'] = transactionDate;
    }

    final response = await _apiProvider.post('/transactions/', payload, token: token);
    return TransactionModel.fromJson(response);
  }

  // --- GOAL METHODS ---

  Future<List<GoalModel>> fetchGoals() async {
    final token = _authService.accessToken.value;
    if (token.isEmpty) throw Exception('Sesi telah habis, silakan login kembali.');

    final response = await _apiProvider.get('/goals/', token: token);
    List<dynamic> data = response['data'] ?? [];
    return data.map((item) => GoalModel.fromJson(item)).toList();
  }

  Future<GoalDetailModel> fetchGoalDetail(String goalId) async {
    final token = _authService.accessToken.value;
    if (token.isEmpty) throw Exception('Sesi telah habis, silakan login kembali.');

    final response = await _apiProvider.get('/goals/$goalId', token: token);
    return GoalDetailModel.fromJson(response);
  }

  Future<GoalModel> createGoal({
    required String name,
    required double targetAmount,
    String? deadline,
    String? note,
  }) async {
    final token = _authService.accessToken.value;
    if (token.isEmpty) throw Exception('Sesi telah habis, silakan login kembali.');

    final payload = {
      'name': name,
      'target_amount': targetAmount,
    };
    if (deadline != null && deadline.isNotEmpty) {
      payload['deadline'] = deadline;
    }
    if (note != null && note.isNotEmpty) {
      payload['note'] = note;
    }

    final response = await _apiProvider.post('/goals/', payload, token: token);
    return GoalModel.fromJson(response);
  }

  Future<GoalContributionModel> addGoalContribution({
    required String goalId,
    required double amount,
    required String transactionType, // DEPOSIT or WITHDRAWAL
    String? walletId,
    String? note,
  }) async {
    final token = _authService.accessToken.value;
    if (token.isEmpty) throw Exception('Sesi telah habis, silakan login kembali.');

    final payload = {
      'amount': amount,
      'transaction_type': transactionType,
    };
    if (walletId != null && walletId.isNotEmpty) {
      payload['wallet_id'] = walletId;
    }
    if (note != null && note.isNotEmpty) {
      payload['note'] = note;
    }

    final response = await _apiProvider.post('/goals/$goalId/contribute', payload, token: token);
    return GoalContributionModel.fromJson(response);
  }

  Future<void> deleteGoal(String goalId) async {
    final token = _authService.accessToken.value;
    if (token.isEmpty) throw Exception('Sesi telah habis, silakan login kembali.');

    await _apiProvider.delete('/goals/$goalId', token: token);
  }

  Future<GoalModel> updateGoal({
    required String goalId,
    String? name,
    double? targetAmount,
    String? deadline,
    String? note,
  }) async {
    final token = _authService.accessToken.value;
    if (token.isEmpty) throw Exception('Sesi telah habis, silakan login kembali.');

    final payload = <String, dynamic>{};
    if (name != null) payload['name'] = name;
    if (targetAmount != null) payload['target_amount'] = targetAmount;
    if (deadline != null) payload['deadline'] = deadline;
    if (note != null) payload['note'] = note;

    final response = await _apiProvider.put('/goals/$goalId', payload, token: token);
    return GoalModel.fromJson(response);
  }
}
