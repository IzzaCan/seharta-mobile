import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiProvider {
  // Gunakan IP 10.0.2.2 untuk Android emulator, atau IP PC Anda (misal: 192.168.1.4) jika run di HP fisik
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api/v1';
    }
    return Platform.isAndroid
        ? 'http://192.168.1.9:8000/api/v1'
        : 'http://localhost:8000/api/v1';
  }

  // Domain utama untuk load static files (seperti avatar)
  static String get baseDomain {
    if (kIsWeb) return 'http://localhost:8000';
    return Platform.isAndroid ? 'http://192.168.1.9:8000' : 'http://localhost:8000';
  }

  // Helper headers
  Map<String, String> _headers(String? token) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // POST Request
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      if (kDebugMode) {
        print('API POST -> $uri');
        print('API Body -> ${jsonEncode(body)}');
      }
      final response = await http.post(
        uri,
        headers: _headers(token),
        body: jsonEncode(body),
      );
      return _processResponse(response);
    } catch (e) {
      if (kDebugMode) print('API POST Error: $e');
      throw _handleException(e);
    }
  }

  // GET Request
  Future<Map<String, dynamic>> get(String endpoint, {String? token}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      if (kDebugMode) {
        print('API GET -> $uri');
      }
      final response = await http.get(uri, headers: _headers(token));
      return _processResponse(response);
    } catch (e) {
      if (kDebugMode) print('API GET Error: $e');
      throw _handleException(e);
    }
  }

  // PUT Request
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      if (kDebugMode) {
        print('API PUT -> $uri');
        print('API Body -> ${jsonEncode(body)}');
      }
      final response = await http.put(
        uri,
        headers: _headers(token),
        body: jsonEncode(body),
      );
      return _processResponse(response);
    } catch (e) {
      if (kDebugMode) print('API PUT Error: $e');
      throw _handleException(e);
    }
  }

  // DELETE Request
  Future<Map<String, dynamic>> delete(String endpoint, {String? token}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      if (kDebugMode) {
        print('API DELETE -> $uri');
      }
      final response = await http.delete(uri, headers: _headers(token));
      return _processResponse(response);
    } catch (e) {
      if (kDebugMode) print('API DELETE Error: $e');
      throw _handleException(e);
    }
  }

  // POST Multipart Request
  Future<Map<String, dynamic>> postMultipart(
    String endpoint, {
    required List<int> fileBytes,
    required String fileName,
    String fileField = 'file',
    Map<String, String>? fields,
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      if (kDebugMode) {
        print('API MULTIPART POST -> $uri');
      }
      var request = http.MultipartRequest('POST', uri);
      
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      if (fields != null) {
        request.fields.addAll(fields);
      }
      
      request.files.add(http.MultipartFile.fromBytes(
        fileField, 
        fileBytes,
        filename: fileName,
      ));
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      return _processResponse(response);
    } catch (e) {
      if (kDebugMode) print('API MULTIPART Error: $e');
      throw _handleException(e);
    }
  }
  // Proses HTTP Response
  Map<String, dynamic> _processResponse(http.Response response) {
    final statusCode = response.statusCode;
    final bodyString = response.body;

    if (kDebugMode) {
      print('API Response Status -> $statusCode');
      print('API Response Body -> $bodyString');
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(bodyString);
    } catch (_) {
      throw 'Format respons server tidak valid';
    }

    if (statusCode >= 200 && statusCode < 300) {
      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else if (decoded is List) {
        return {'data': decoded};
      }
      return {'message': 'Success'};
    } else {
      // Ambil pesan error dari FastAPI (biasanya di field 'detail')
      String errorMessage = 'Terjadi kesalahan sistem';
      if (decoded is Map && decoded.containsKey('detail')) {
        final detail = decoded['detail'];
        if (detail is String) {
          errorMessage = detail;
        } else if (detail is List && detail.isNotEmpty) {
          // Kasus error validasi pydantic FastAPI
          final firstError = detail.first;
          if (firstError is Map && firstError.containsKey('msg')) {
            errorMessage = firstError['msg'] as String;
          }
        }
      }
      throw errorMessage;
    }
  }

  // Exception translator
  String _handleException(dynamic exception) {
    if (exception is SocketException) {
      return 'Tidak dapat terhubung ke server. Pastikan koneksi internet aktif dan server backend berjalan.';
    }
    if (exception is HttpException) {
      return 'Kesalahan HTTP pada server.';
    }
    if (exception is FormatException) {
      return 'Format data tidak didukung.';
    }
    return exception.toString();
  }
}
