import 'package:get/get.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/services/auth_service.dart';
import '../models/wallet_model.dart';

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
}
