import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/services/auth_service.dart';
import '../../add_transaction/controllers/add_transaction_controller.dart';

class LoadingOcrController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  
  late String imagePath;
  var progressStatus = 'Mempersiapkan gambar...'.obs;

  @override
  void onInit() {
    super.onInit();
    // Ambil path gambar dari arguments routing
    imagePath = Get.arguments as String;
    _uploadAndProcessReceipt();
  }

  Future<void> _uploadAndProcessReceipt() async {
    try {
      progressStatus.value = 'Mengirim gambar ke server...';
      
      final url = Uri.parse('${ApiProvider.baseUrl}/ocr/scan');
      final request = http.MultipartRequest('POST', url);
      
      // Tambahkan header otentikasi JWT
      final token = _authService.accessToken;
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      // Lampirkan file gambar secara eksplisit sebagai JPEG
      final file = await http.MultipartFile.fromPath(
        'file',
        imagePath,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(file);
      
      progressStatus.value = 'Menganalisis struk dengan Gemini AI...';
      
      // Kirim request ke backend FastAPI
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final parsedData = json.decode(response.body);
        
        // Cari instance AddTransactionController secara langsung untuk mengisi form
        try {
          final addTxController = Get.find<AddTransactionController>();
          
          // 1. Isi Jumlah (RP) secara otomatis
          if (parsedData['total_amount'] != null) {
            final amount = parsedData['total_amount'];
            if (amount is num) {
              addTxController.amountController.text = amount.round().toString();
            } else {
              addTxController.amountController.text = amount.toString();
            }
          }

          // 2. Isi Catatan secara otomatis (Format Premium Cerdas & Estetik)
          final merchant = parsedData['merchant_name'] ?? 'Struk Belanja';
          final date = parsedData['date'] ?? '';
          final rawItems = parsedData['items'];
          List<dynamic> items = [];
          if (rawItems is List) {
            items = rawItems;
          } else if (rawItems is String) {
            items = [rawItems];
          }
          
          String noteText = "DETAIL SCAN STRUK (AI)\n";
          noteText += "━━━━━━━━━━━━━━━━━━━━━\n";
          noteText += "Merchant : $merchant\n";
          if (date.isNotEmpty) {
            noteText += "Tanggal  : $date\n";
          }
          
          if (items.isNotEmpty) {
            noteText += "Rincian  :\n";
            for (var item in items) {
              noteText += "  • $item\n";
            }
          }
          
          addTxController.noteController.text = noteText.trimRight();
        } catch (e) {
          debugPrint("AddTransactionController tidak ditemukan atau tidak aktif: $e");
        }
        
        // Tutup halaman loading dan kembali ke AddTransactionView
        Get.back();
        
        Get.snackbar(
          "Scan Berhasil",
          "Data struk belanja Anda berhasil diekstrak oleh Gemini AI!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFDEF7EC),
          colorText: const Color(0xFF03543F),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
        );
      } else {
        // Parse pesan error dari server jika ada
        String errorMsg = 'Gagal memproses struk belanja.';
        try {
          final errorJson = json.decode(response.body);
          if (errorJson['detail'] != null) {
            errorMsg = errorJson['detail'].toString();
          }
        } catch (_) {}
        
        throw Exception(errorMsg);
      }
    } catch (e) {
      // Kembali ke halaman sebelumnya dan beri info kegagalan
      Get.back();
      Get.snackbar(
        "Gagal Scan Struk",
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFDE8E8),
        colorText: const Color(0xFF9B1C1C),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 5),
      );
    }
  }

  void cancelProcess() {
    Get.back();
  }
}
