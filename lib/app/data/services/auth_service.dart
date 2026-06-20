import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../providers/api_provider.dart';

class AuthService extends GetxService {
  final ApiProvider _apiProvider = ApiProvider();
  late SharedPreferences _prefs;

  // State observables
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxString accessToken = ''.obs;
  
  bool get isLoggedIn => currentUser.value != null;

  // Kunci shared preferences
  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'auth_user';

  // Inisialisasi Service
  Future<AuthService> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSavedAuth();
    return this;
  }

  // Load credential tersimpan
  Future<void> _loadSavedAuth() async {
    final token = _prefs.getString(_keyToken);
    final userJson = _prefs.getString(_keyUser);

    if (token != null && token.isNotEmpty && userJson != null) {
      try {
        accessToken.value = token;
        currentUser.value = UserModel.fromJson(jsonDecode(userJson));
        
        // Verifikasi token masih aktif dengan menanyakan detail user terbaru ke backend
        await checkCurrentSession();
      } catch (e) {
        if (kDebugMode) print('Failed to restore auth session: $e');
        // Jika token tidak valid, bersihkan sesi
        await clearAuthSession();
      }
    }
  }

  // Verifikasi token & ambil data user terbaru
  Future<void> checkCurrentSession() async {
    if (accessToken.value.isEmpty) return;
    
    try {
      final response = await _apiProvider.get('/auth/me', token: accessToken.value);
      final user = UserModel.fromJson(response);
      
      // Update data user di memori & disk
      currentUser.value = user;
      await _prefs.setString(_keyUser, jsonEncode(user.toJson()));
    } catch (e) {
      if (kDebugMode) print('Session verification failed: $e');
      // Token tidak valid/kedaluwarsa, hapus sesi
      await clearAuthSession();
    }
  }

  // Simpan sesi autentikasi
  Future<void> saveAuthSession(TokenResponseModel response) async {
    accessToken.value = response.accessToken;
    currentUser.value = response.user;

    await _prefs.setString(_keyToken, response.accessToken);
    await _prefs.setString(_keyUser, jsonEncode(response.user.toJson()));
  }

  // Hapus sesi autentikasi
  Future<void> clearAuthSession() async {
    accessToken.value = '';
    currentUser.value = null;

    await _prefs.remove(_keyToken);
    await _prefs.remove(_keyUser);
  }

  // LOGIN Action
  Future<void> login(String email, String password) async {
    try {
      final payload = {
        'email': email,
        'password': password,
      };

      final responseMap = await _apiProvider.post('/auth/login', payload);
      final tokenResponse = TokenResponseModel.fromJson(responseMap);
      
      await saveAuthSession(tokenResponse);
    } catch (e) {
      rethrow;
    }
  }

  // REGISTER Action
  Future<void> register(String fullName, String email, String password) async {
    try {
      final payload = {
        'full_name': fullName,
        'email': email,
        'password': password,
      };

      final responseMap = await _apiProvider.post('/auth/register', payload);
      final tokenResponse = TokenResponseModel.fromJson(responseMap);

      await saveAuthSession(tokenResponse);
    } catch (e) {
      rethrow;
    }
  }

  // UPDATE PROFILE Action
  Future<void> updateProfile(String fullName) async {
    try {
      final payload = {'full_name': fullName};
      final response = await _apiProvider.put('/auth/profile', payload, token: accessToken.value);
      final updatedUser = UserModel.fromJson(response);
      currentUser.value = updatedUser;
      await _prefs.setString(_keyUser, jsonEncode(updatedUser.toJson()));
    } catch (e) {
      rethrow;
    }
  }

  // UPDATE PASSWORD Action
  Future<void> updatePassword(String oldPassword, String newPassword) async {
    try {
      final payload = {'old_password': oldPassword, 'new_password': newPassword};
      final response = await _apiProvider.put('/auth/password', payload, token: accessToken.value);
      final updatedUser = UserModel.fromJson(response);
      currentUser.value = updatedUser;
      await _prefs.setString(_keyUser, jsonEncode(updatedUser.toJson()));
    } catch (e) {
      rethrow;
    }
  }

  // UPLOAD AVATAR Action
  Future<void> uploadAvatar(List<int> imageBytes, String fileName) async {
    try {
      final response = await _apiProvider.postMultipart(
        '/auth/avatar',
        fileBytes: imageBytes,
        fileName: fileName,
        token: accessToken.value,
      );
      final updatedUser = UserModel.fromJson(response);
      currentUser.value = updatedUser;
      await _prefs.setString(_keyUser, jsonEncode(updatedUser.toJson()));
    } catch (e) {
      rethrow;
    }
  }

  // VERIFY EMAIL Action
  Future<void> verifyEmail(String email, String otp) async {
    try {
      final payload = {'email': email, 'otp': otp};
      await _apiProvider.post('/auth/verify-email', payload);
    } catch (e) {
      rethrow;
    }
  }

  // RESEND VERIFICATION Action
  Future<void> resendVerification(String email) async {
    try {
      final payload = {'email': email};
      await _apiProvider.post('/auth/resend-verification', payload);
    } catch (e) {
      rethrow;
    }
  }

  // LOGOUT Action
  Future<void> logout() async {
    try {
      // Panggil backend logout endpoint jika diperlukan (opsional client-side)
      if (accessToken.value.isNotEmpty) {
        await _apiProvider.post('/auth/logout', {}, token: accessToken.value);
      }
    } catch (e) {
      if (kDebugMode) print('Backend logout notify error: $e');
    } finally {
      await clearAuthSession();
      // Arahkan kembali ke halaman Login dan hapus seluruh history navigasi
      Get.offAllNamed('/login');
    }
  }
}
