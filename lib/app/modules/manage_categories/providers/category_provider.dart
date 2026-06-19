import 'package:get/get.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/services/auth_service.dart';
import '../models/category_model.dart';

class CategoryProvider {
  final ApiProvider _apiProvider = ApiProvider();
  final AuthService _authService = Get.find<AuthService>();

  Future<List<CategoryModel>> fetchCategories() async {
    final token = _authService.accessToken.value;
    if (token.isEmpty) throw Exception('Sesi telah habis, silakan login kembali.');

    final response = await _apiProvider.get('/categories/', token: token);
    
    // Backend API typically wraps responses in {'data': [...]} or directly returns a list
    List<dynamic> data = response is Map && response.containsKey('data') ? response['data'] : response;
    return data.map((item) => CategoryModel.fromJson(item)).toList();
  }

  Future<CategoryModel> createCategory(String name, String type, {String? iconName}) async {
    final token = _authService.accessToken.value;
    if (token.isEmpty) throw Exception('Sesi telah habis, silakan login kembali.');

    final payload = {
      'name': name,
      'type': type, // 'income' or 'expense'
    };
    if (iconName != null) {
      payload['icon_name'] = iconName;
    }

    final response = await _apiProvider.post('/categories/', payload, token: token);
    return CategoryModel.fromJson(response);
  }

  Future<CategoryModel> updateCategory(String categoryId, {String? name, String? type, String? iconName}) async {
    final token = _authService.accessToken.value;
    if (token.isEmpty) throw Exception('Sesi telah habis, silakan login kembali.');

    final payload = <String, dynamic>{};
    if (name != null) payload['name'] = name;
    if (type != null) payload['type'] = type;
    if (iconName != null) payload['icon_name'] = iconName;

    final response = await _apiProvider.put('/categories/$categoryId', payload, token: token);
    return CategoryModel.fromJson(response);
  }

  Future<void> deleteCategory(String categoryId) async {
    final token = _authService.accessToken.value;
    if (token.isEmpty) throw Exception('Sesi telah habis, silakan login kembali.');

    await _apiProvider.delete('/categories/$categoryId', token: token);
  }
}
