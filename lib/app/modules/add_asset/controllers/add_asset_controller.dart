import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/services/auth_service.dart';
import '../../harta/controllers/harta_controller.dart';
import '../../harta/models/asset_model.dart';

import 'package:intl/intl.dart';
import '../../../utils/asset_helper.dart';

class AddAssetController extends GetxController {
  final ApiProvider _apiProvider = ApiProvider();
  final AuthService _authService = Get.find<AuthService>();
  
  // Controllers for form fields
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final dateController = TextEditingController();
  final notesController = TextEditingController();

  // Image Picker & Photo States
  final ImagePicker _picker = ImagePicker();
  var mainPhotoPath = ''.obs; // local path
  var existingMainPhotoUrl = ''.obs; // relative path from DB
  
  var localDocPaths = <String>[].obs; // local document paths
  var existingDocUrls = <String>[].obs; // relative paths from DB
  
  var isLoading = false.obs;
  var isEdit = false.obs;
  var assetId = ''.obs;

  // Categories
  var categories = <AssetCategoryModel>[].obs;
  var selectedCategoryId = Rxn<String>();
  var isLoadingCategories = false.obs;

  // Enum Options
  final ownershipOptions = ['PERSONAL', 'JOINT'];
  var selectedOwnership = 'PERSONAL'.obs;

  final acquisitionOptions = ['PURCHASE', 'INHERITANCE', 'GIFT'];
  var selectedAcquisition = 'PURCHASE'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    
    // Check if arguments were passed for editing
    if (Get.arguments != null) {
      isEdit.value = true;
      assetId.value = Get.arguments as String;
      _loadAssetData(assetId.value);
    }
  }

  Future<void> fetchCategories() async {
    try {
      isLoadingCategories(true);
      final token = _authService.accessToken.value;
      final response = await _apiProvider.getAssetCategories(token: token);
      final List<dynamic> data = response['data'] as List<dynamic>? ?? [];
      
      final allCategories = data.map((json) => AssetCategoryModel.fromJson(json)).toList();
      
      // Filter unik berdasarkan nama terjemahan Bahasa Indonesia
      final seenNames = <String>{};
      final uniqueCategories = <AssetCategoryModel>[];
      for (var cat in allCategories) {
        final translatedName = translateAssetCategory(cat.name);
        if (!seenNames.contains(translatedName)) {
          seenNames.add(translatedName);
          uniqueCategories.add(cat);
        }
      }
      
      categories.assignAll(uniqueCategories);
      
      if (isEdit.value) {
        if (Get.isRegistered<HartaController>()) {
          final hartaCtrl = Get.find<HartaController>();
          final asset = hartaCtrl.assets.firstWhereOrNull((a) => a.id == assetId.value);
          if (asset != null) {
            final originalCat = allCategories.firstWhereOrNull((c) => c.id == asset.categoryId);
            if (originalCat != null) {
              final originalName = translateAssetCategory(originalCat.name);
              final matchedUniqueCat = uniqueCategories.firstWhereOrNull(
                (c) => translateAssetCategory(c.name) == originalName
              );
              if (matchedUniqueCat != null) {
                selectedCategoryId.value = matchedUniqueCat.id;
              } else {
                categories.add(originalCat);
                selectedCategoryId.value = originalCat.id;
              }
            }
          }
        }
      } else {
        if (categories.isNotEmpty) {
          selectedCategoryId.value = categories.first.id;
        }
      }
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal memuat kategori aset');
    } finally {
      isLoadingCategories(false);
    }
  }

  void _loadAssetData(String id) {
    try {
      if (Get.isRegistered<HartaController>()) {
        final hartaCtrl = Get.find<HartaController>();
        final asset = hartaCtrl.assets.firstWhere((a) => a.id == id);
        
        nameController.text = asset.assetName;
        
        // Format nominal ke Rupiah saat meload data untuk diedit
        final formatter = NumberFormat.decimalPattern('id');
        priceController.text = formatter.format(asset.purchasePrice);
        
        selectedCategoryId.value = asset.categoryId;
        selectedOwnership.value = asset.ownershipType;
        selectedAcquisition.value = asset.acquisitionType;
        notesController.text = asset.notes ?? '';

        if (asset.purchaseDate != null) {
          dateController.text = asset.purchaseDate!.toIso8601String().split('T').first;
        }

        if (asset.photoUrl != null && asset.photoUrl!.trim().isNotEmpty) {
          final urls = asset.photoUrl!.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
          if (urls.isNotEmpty) {
            existingMainPhotoUrl.value = urls.first;
            if (urls.length > 1) {
              existingDocUrls.assignAll(urls.sublist(1));
            }
          }
        }
      }
    } catch (e) {
      print("Gagal memuat data aset untuk diedit: $e");
    }
  }

  Future<void> pickMainPhoto(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        mainPhotoPath.value = image.path;
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil gambar: $e');
    }
  }

  Future<void> pickDocPhoto(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        localDocPaths.add(image.path);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil gambar: $e');
    }
  }

  void removeLocalDoc(int index) {
    localDocPaths.removeAt(index);
  }

  void removeExistingDoc(int index) {
    existingDocUrls.removeAt(index);
  }

  void removeMainPhoto() {
    mainPhotoPath.value = '';
    existingMainPhotoUrl.value = '';
  }

  void pickDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      dateController.text = picked.toIso8601String().split('T').first;
    }
  }

  Future<void> submit() async {
    if (nameController.text.isEmpty || priceController.text.isEmpty || selectedCategoryId.value == null) {
      Get.snackbar('Error', 'Nama, harga, dan kategori aset wajib diisi', backgroundColor: Colors.red[100], colorText: Colors.red[900]);
      return;
    }

    try {
      isLoading(true);
      final token = _authService.accessToken.value;
      
      // 1. Upload foto utama jika ada perubahan lokal
      String finalMainPhotoUrl = existingMainPhotoUrl.value;
      if (mainPhotoPath.value.isNotEmpty) {
        final file = File(mainPhotoPath.value);
        final bytes = await file.readAsBytes();
        final filename = mainPhotoPath.value.split('/').last;
        final uploadResponse = await _apiProvider.uploadAssetFile(
          fileBytes: bytes,
          fileName: filename,
          token: token,
        );
        finalMainPhotoUrl = uploadResponse['url'] ?? '';
      }

      // 2. Upload foto dokumen tambahan jika ada
      final List<String> uploadedDocs = [];
      for (var path in localDocPaths) {
        final file = File(path);
        final bytes = await file.readAsBytes();
        final filename = path.split('/').last;
        final uploadResponse = await _apiProvider.uploadAssetFile(
          fileBytes: bytes,
          fileName: filename,
          token: token,
        );
        final url = uploadResponse['url'];
        if (url != null) {
          uploadedDocs.add(url);
        }
      }

      // Gabungkan foto utama yang baru/lama dengan dokumen yang baru/lama
      final List<String> allPhotoUrls = [];
      if (finalMainPhotoUrl.isNotEmpty) {
        allPhotoUrls.add(finalMainPhotoUrl);
      }
      
      // Tambahkan dokumen existing yang tidak dihapus
      allPhotoUrls.addAll(existingDocUrls);
      
      // Tambahkan dokumen baru yang baru diupload
      allPhotoUrls.addAll(uploadedDocs);

      final photoUrlString = allPhotoUrls.isNotEmpty ? allPhotoUrls.join(',') : null;

      // Bersihkan pemisah ribuan sebelum di-parse ke double
      final rawPrice = priceController.text.replaceAll(RegExp(r'[^0-9]'), '');
      
      final data = {
        'asset_name': nameController.text,
        'purchase_price': double.tryParse(rawPrice) ?? 0.0,
        'category_id': selectedCategoryId.value,
        'ownership_type': selectedOwnership.value,
        'acquisition_type': selectedAcquisition.value,
        'purchase_date': dateController.text.isNotEmpty ? '${dateController.text}T00:00:00Z' : null,
        'notes': notesController.text,
        'photo_url': photoUrlString,
      };

      if (selectedOwnership.value == 'PERSONAL') {
        data['owner_user_id'] = _authService.currentUser.value?.id;
      }

      if (isEdit.value) {
        await _apiProvider.updateAsset(id: assetId.value, data: data, token: token);
        Get.back();
        Get.snackbar('Sukses', 'Aset berhasil diperbarui', backgroundColor: const Color(0xFF1F9975), colorText: Colors.white);
      } else {
        await _apiProvider.createAsset(data: data, token: token);
        Get.back();
        Get.snackbar('Sukses', 'Aset berhasil ditambahkan', backgroundColor: const Color(0xFF1F9975), colorText: Colors.white);
      }

      // Refresh HartaView
      if (Get.isRegistered<HartaController>()) {
        final hartaCtrl = Get.find<HartaController>();
        hartaCtrl.fetchAssets();
        hartaCtrl.fetchWallets();
      }
    } catch (e) {
      Get.snackbar('Gagal', e.toString(), backgroundColor: Colors.red[100], colorText: Colors.red[900]);
    } finally {
      isLoading(false);
    }
  }
}
