import 'api_provider.dart';

class FamilyProvider {
  final ApiProvider _apiProvider = ApiProvider();

  /// Menghubungi API Backend untuk membuat keluarga baru.
  /// Menerima parameter [familyName] dan JWT [token].
  /// Mengembalikan Map dengan detail code PIN 6-digit.
  Future<Map<String, dynamic>> createFamily({
    required String familyName,
    required String token,
  }) async {
    final payload = {
      'family_name': familyName,
    };
    return await _apiProvider.post('/family/create', payload, token: token);
  }

  /// Menghubungi API Backend untuk bergabung ke keluarga yang ada.
  /// Menerima parameter [code] PIN 6-digit dan JWT [token].
  /// Mengembalikan Map dengan status dan family_id.
  Future<Map<String, dynamic>> joinFamily({
    required String code,
    required String token,
  }) async {
    final payload = {
      'code': code,
    };
    return await _apiProvider.post('/family/join', payload, token: token);
  }

  /// Memeriksa status PIN apakah sudah digunakan oleh pasangan atau belum.
  Future<Map<String, dynamic>> checkPairingStatus({
    required String code,
    required String token,
  }) async {
    return await _apiProvider.get('/family/pairing-status/$code', token: token);
  }

  /// Mengambil informasi detail keluarga saat ini.
  Future<Map<String, dynamic>> getFamilyInfo({
    required String token,
  }) async {
    return await _apiProvider.get('/family/info', token: token);
  }

  /// Mengubah nama keluarga saat ini.
  Future<Map<String, dynamic>> updateFamilyName({
    required String newName,
    required String token,
  }) async {
    final payload = {
      'family_name': newName,
    };
    return await _apiProvider.put('/family/name', payload, token: token);
  }
}
