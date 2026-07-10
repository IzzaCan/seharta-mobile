import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../../routes/app_pages.dart';
import '../../../data/services/family_service.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/models/wallet_model.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'dart:typed_data';
import '../views/widgets/image_calibration_dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ProfileController extends GetxController {
  final FamilyService _familyService = Get.find<FamilyService>();
  final AuthService _authService = Get.find<AuthService>();
  
  final appVersion = 'v1.0.0'.obs;
  
  RxString get familyName => _familyService.familyName;
  Rx<UserModel?> get currentUser => _authService.currentUser;
  String? get avatarUrl => currentUser.value?.avatarUrl;
  
  String? get partnerName => _familyService.partner?.fullName;
  String? get partnerAvatarUrl => _familyService.partner?.avatarUrl;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    _loadVersion();
  }

  void _loadVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion.value = 'v${packageInfo.version} (${packageInfo.buildNumber})';
    } catch (_) {
      appVersion.value = 'v1.0.0';
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    isAppLockOn = prefs.getBool('is_app_lock_enabled') ?? false;
    update();
  }

  Future<void> pickProfilePicture(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      try {
        final bytes = await pickedFile.readAsBytes();
        
        final GlobalKey cropperKey = GlobalKey();
        final RxBool isUploading = false.obs;

        Get.dialog(
          ImageCalibrationDialog(
            imageBytes: bytes,
            cropperKey: cropperKey,
            isLoading: isUploading,
            onApply: () async {
              try {
                isUploading.value = true;
                
                // Ambil gambar yang di-crop dari RepaintBoundary
                RenderRepaintBoundary boundary = cropperKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
                ui.Image image = await boundary.toImage(pixelRatio: 2.0); // Resolusi lebih tinggi
                ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
                
                if (byteData != null) {
                  final croppedBytes = byteData.buffer.asUint8List();
                  
                  // Gunakan API upload dari AuthService
                  await _authService.uploadAvatar(croppedBytes, 'profile.png');
                  
                  Get.back(); // Tutup dialog kalibrasi
                  Get.snackbar('Berhasil', 'Foto profil berhasil diperbarui', backgroundColor: const Color(0xFF1F9975), colorText: Colors.white);
                } else {
                  throw 'Gagal mengekstrak data gambar';
                }
              } catch (e) {
                Get.snackbar('Gagal', 'Gagal memproses foto: $e', backgroundColor: Colors.red, colorText: Colors.white);
              } finally {
                isUploading.value = false;
              }
            },
          ),
          barrierDismissible: false,
        );
      } catch (e) {
        Get.snackbar('Gagal', 'Gagal memuat foto: $e', backgroundColor: Colors.red, colorText: Colors.white);
      }
    }
  }

  void showSettingsBottomSheet() {
    final nameController = TextEditingController(text: currentUser.value?.fullName ?? '');
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final isLoading = false.obs;
    final isOldPasswordObscured = true.obs;
    final isNewPasswordObscured = true.obs;

    final primaryColor = const Color(0xFF0F172A); // Slate 900
    final secondaryColor = const Color(0xFF475569); // Slate 600
    final accentColor = const Color(0xFF0EA5E9); // Modern Blue Accent

    InputDecoration _inputStyle({
      required String labelText,
      required IconData prefixIcon,
      Widget? suffixIcon,
    }) {
      return InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF64748B), size: 18),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accentColor, width: 1.5),
        ),
      );
    }

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 12,
          bottom: Get.context != null ? MediaQuery.of(Get.context!).viewInsets.bottom + 24 : 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              Text(
                'Pengaturan Profil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),

              // Bagian 1: Informasi Dasar (Nama)
              Text(
                'Informasi Pribadi',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: secondaryColor,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                style: TextStyle(fontSize: 14, color: primaryColor),
                decoration: _inputStyle(
                  labelText: 'Nama Lengkap',
                  prefixIcon: Icons.person_outline,
                ),
              ),
              
              const SizedBox(height: 24),

              // Bagian 2: Ganti Password (Opsional)
              Text(
                'Ubah Password (Opsional)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: secondaryColor,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => TextField(
                controller: oldPasswordController,
                obscureText: isOldPasswordObscured.value,
                style: TextStyle(fontSize: 14, color: primaryColor),
                decoration: _inputStyle(
                  labelText: 'Password Lama',
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      isOldPasswordObscured.value ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: const Color(0xFF64748B),
                      size: 18,
                    ),
                    onPressed: () => isOldPasswordObscured.toggle(),
                  ),
                ),
              )),
              const SizedBox(height: 12),
              Obx(() => TextField(
                controller: newPasswordController,
                obscureText: isNewPasswordObscured.value,
                style: TextStyle(fontSize: 14, color: primaryColor),
                decoration: _inputStyle(
                  labelText: 'Password Baru',
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      isNewPasswordObscured.value ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: const Color(0xFF64748B),
                      size: 18,
                    ),
                    onPressed: () => isNewPasswordObscured.toggle(),
                  ),
                ),
              )),

              const SizedBox(height: 32),

              // Tombol Simpan
              Obx(() => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D2B33), // Mempertahankan brand color utama Seharta
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: isLoading.value ? null : () async {
                    try {
                      isLoading.value = true;
                      if (nameController.text != currentUser.value?.fullName && nameController.text.isNotEmpty) {
                        await _authService.updateProfile(nameController.text);
                      }
                      if (oldPasswordController.text.isNotEmpty && newPasswordController.text.isNotEmpty) {
                        await _authService.updatePassword(oldPasswordController.text, newPasswordController.text);
                      }
                      Get.back();
                      Get.snackbar(
                        'Berhasil', 
                        'Profil berhasil diperbarui', 
                        backgroundColor: const Color(0xFF10B981), 
                        colorText: Colors.white,
                        snackPosition: SnackPosition.TOP,
                      );
                    } catch (e) {
                      Get.snackbar(
                        'Gagal', 
                        e.toString(), 
                        backgroundColor: const Color(0xFFEF4444), 
                        colorText: Colors.white,
                        snackPosition: SnackPosition.TOP,
                      );
                    } finally {
                      isLoading.value = false;
                    }
                  },
                  child: isLoading.value 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                      : const Text(
                          'Simpan Perubahan', 
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                ),
              )),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  // State untuk Switch (Toggle)
  bool isAppLockOn = false;

  void toggleAppLock(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final storedPin = prefs.getString('security_pin') ?? '';
    
    if (value) {
      if (storedPin.isEmpty) {
        // No PIN registered yet, redirect to CHANGE_PIN
        Get.snackbar(
          'Buat PIN', 
          'Silakan buat PIN keamanan Anda terlebih dahulu', 
          backgroundColor: Colors.orange[100], 
          colorText: Colors.orange[900]
        );
        Get.toNamed(Routes.PIN);
        isAppLockOn = false;
      } else {
        isAppLockOn = true;
        await prefs.setBool('is_app_lock_enabled', true);
      }
    } else {
      isAppLockOn = false;
      await prefs.setBool('is_app_lock_enabled', false);
    }
    update();
  }

  // Aksi navigasi & aksi khusus
  void showPairingCode() {
    print("Tampilkan Modal QR Code");
  }

  void unpairAccount() {
    print("Putuskan Tautan (Tampilkan Pop-up Peringatan)");
  }

  void logout() {
    Get.defaultDialog(
      title: 'Keluar Akun',
      titleStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Color(0xFF0D2B33),
      ),
      middleText: 'Apakah Anda yakin ingin keluar dari akun?',
      middleTextStyle: TextStyle(
        color: Colors.grey[700],
      ),
      textConfirm: 'Keluar',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      cancelTextColor: const Color(0xFF0D2B33),
      buttonColor: const Color(0xFF0D2B33),
      onConfirm: () async {
        Get.back(); // Tutup dialog konfirmasi
        // Jalankan logout dengan loading overlay
        Get.showOverlay(
          asyncFunction: () => _authService.logout(),
          loadingWidget: const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF67F2A5), // Menggunakan accent color hijau dari desain
            ),
          ),
        );
      },
    );
  }

  Future<void> refreshProfile() async {
    await Future.wait([
      _authService.checkCurrentSession(),
      _familyService.fetchFamilyInfo(),
    ]);
  }

  void showExportBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Material(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ekspor Data Transaksi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D2B33),
                    ),
                  ),
                  InkWell(
                    onTap: () => Get.back(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, size: 20, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Text(
                'Pilih format dokumen laporan keuangan yang Anda inginkan:',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),

              // PDF Option
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.picture_as_pdf_outlined, color: Colors.red),
                ),
                title: const Text(
                  'Dokumen PDF Laporan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Text(
                  'Format PDF resmi lengkap dengan tabel dan metadata keluarga.',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
                onTap: () {
                  Get.back(); // close bottom sheet
                  _showPeriodPickerDialog(context, 'PDF');
                },
              ),
              const Divider(height: 24, thickness: 0.5),

              // CSV Option
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.table_chart_outlined, color: Colors.green),
                ),
                title: const Text(
                  'Data Mentah CSV (Excel)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Text(
                  'Format data mentah tabular untuk dibuka di Excel/Sheets.',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
                onTap: () {
                  Get.back(); // close bottom sheet
                  _showPeriodPickerDialog(context, 'CSV');
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    ),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showPeriodPickerDialog(BuildContext context, String format) {
    final currentMonth = DateTime.now().month;
    final currentYear = DateTime.now().year;

    final selectedMonth = currentMonth.obs;
    final selectedYear = currentYear.obs;

    final List<int> years = [2024, 2025, 2026, 2027];
    final List<int> months = List.generate(12, (index) => index + 1);

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih Periode',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D2B33),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tentukan bulan dan tahun untuk laporan data transaksi Anda.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),
                
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE0E5E9)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: selectedMonth.value,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items: months.map((monthNum) => DropdownMenuItem(
                              value: monthNum,
                              child: Text(
                                _monthName(monthNum),
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            )).toList(),
                            onChanged: (val) {
                              if (val != null) selectedMonth.value = val;
                            },
                          ),
                        ),
                      )),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(() => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE0E5E9)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: selectedYear.value,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items: years.map((yearNum) => DropdownMenuItem(
                              value: yearNum,
                              child: Text(
                                '$yearNum',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            )).toList(),
                            onChanged: (val) {
                              if (val != null) selectedYear.value = val;
                            },
                          ),
                        ),
                      )),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D2B33),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Get.back(); // close picker dialog
                        _processExport(
                          context: context,
                          month: selectedMonth.value,
                          year: selectedYear.value,
                          format: format,
                        );
                      },
                      child: const Text('Ekspor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _processExport({
    required BuildContext context,
    required int month,
    required int year,
    required String format,
  }) async {
    // Show Loading Overlay
    Get.dialog(
      const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF0D2B33)),
                SizedBox(height: 16),
                Text('Mengambil data...', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final ApiProvider _apiProvider = ApiProvider();
      final token = _authService.accessToken.value;
      
      // Calculate date range for the selected month & year
      final dateFrom = DateTime(year, month, 1);
      final nextMonth = month == 12 ? 1 : month + 1;
      final nextYear = month == 12 ? year + 1 : year;
      final dateTo = DateTime(nextYear, nextMonth, 1).subtract(const Duration(days: 1));

      final dateFromStr = DateFormat('yyyy-MM-dd').format(dateFrom);
      final dateToStr = DateFormat('yyyy-MM-dd').format(dateTo);
      
      final endpoint = '/transactions/?page=1&size=100&date_from=${dateFromStr}T00:00:00&date_to=${dateToStr}T23:59:59';
      
      final response = await _apiProvider.get(endpoint, token: token);
      
      if (Get.isDialogOpen == true) Get.back(); // Close loading dialog

      if (response != null && response['items'] != null) {
        final txList = response['items'] as List;
        final transactions = txList.map((e) => TransactionModel.fromJson(e)).toList();

        if (transactions.isEmpty) {
          Get.snackbar(
            'Info',
            'Tidak ada transaksi pada periode ${_monthName(month)} $year',
            backgroundColor: Colors.orange[100],
            colorText: Colors.orange[900],
          );
          return;
        }

        if (format == 'PDF') {
          await _generatePdf(
            month: month,
            year: year,
            transactions: transactions,
          );
        } else if (format == 'CSV') {
          await _generateCsv(
            month: month,
            year: year,
            transactions: transactions,
          );
        }
      } else {
        throw 'Gagal mendapatkan data transaksi';
      }
    } catch (e) {
      if (Get.isDialogOpen == true) Get.back(); // Ensure loading closed
      Get.snackbar(
        'Gagal Ekspor',
        e.toString(),
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  Future<void> _generatePdf({
    required int month,
    required int year,
    required List<TransactionModel> transactions,
  }) async {
    final doc = pw.Document();
    
    final formattedMonth = _monthName(month);
    final user = currentUser.value;
    final fName = familyName.value;
    final pName = partnerName;

    // Table headers
    final headers = ['Tanggal', 'Tipe', 'Kategori', 'Nominal', 'Dompet', 'Catatan'];
    
    // Table data
    final data = transactions.map((tx) {
      final dateStr = DateFormat('dd/MM/yy HH:mm').format(DateTime.tryParse(tx.transactionDate) ?? DateTime.now());
      final isExpense = tx.transactionType.toUpperCase() == 'EXPENSE' || tx.transactionType.toUpperCase() == 'TRANSFER';
      final isTransfer = tx.transactionType.toUpperCase() == 'TRANSFER';
      final typeText = isTransfer ? 'Transfer' : (isExpense ? 'Pengeluaran' : 'Pemasukan');
      final amountVal = '${isExpense ? "-" : "+"}Rp ${tx.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}';
      
      return [
        dateStr,
        typeText,
        tx.categoryName ?? '-',
        amountVal,
        tx.walletName ?? '-',
        tx.notes ?? '-',
      ];
    }).toList();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'SEHARTA',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#0D2B33'),
                  ),
                ),
                pw.Text(
                  'LAPORAN TRANSAKSI',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Divider(thickness: 2, color: PdfColor.fromHex('#0D2B33')),
            pw.SizedBox(height: 16),
            
            // Period and Metadata
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Periode Laporan:',
                        style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        '$formattedMonth $year',
                        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0D2B33')),
                      ),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Pengguna: ${user?.fullName ?? ""}', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Email: ${user?.email ?? ""}', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                        pw.SizedBox(height: 4),
                        pw.Text('Keluarga: ${fName.isEmpty ? "-" : fName}', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                        if (pName != null)
                          pw.Text('Pasangan: $pName', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 24),

            // Table
            pw.Table.fromTextArray(
              context: context,
              headers: headers,
              data: data,
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                fontSize: 9,
              ),
              headerDecoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#0D2B33'),
              ),
              cellStyle: const pw.TextStyle(
                fontSize: 8,
              ),
              cellAlignment: pw.Alignment.centerLeft,
              cellAlignments: {
                3: pw.Alignment.centerRight,
              },
            ),
          ];
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 24),
            child: pw.Text(
              'Halaman ${context.pageNumber} dari ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
            ),
          );
        },
      ),
    );

    final bytes = await doc.save();
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
      name: 'Laporan_Transaksi_${formattedMonth}_$year.pdf',
    );
  }

  Future<void> _generateCsv({
    required int month,
    required int year,
    required List<TransactionModel> transactions,
  }) async {
    final buffer = StringBuffer();
    final formattedMonth = _monthName(month);
    
    // Metadata
    buffer.writeln('# Periode Laporan: $formattedMonth $year');
    buffer.writeln('# Pengguna: ${currentUser.value?.fullName ?? ""} (${currentUser.value?.email ?? ""})');
    buffer.writeln('# Keluarga: ${familyName.value}');
    if (partnerName != null) {
      buffer.writeln('# Pasangan: $partnerName');
    }
    buffer.writeln('');
    
    // Header
    buffer.writeln('Tanggal,Tipe,Kategori,Nominal,Dompet,Catatan,Pembuat');
    
    for (final tx in transactions) {
      final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.tryParse(tx.transactionDate) ?? DateTime.now());
      final isExpense = tx.transactionType.toUpperCase() == 'EXPENSE' || tx.transactionType.toUpperCase() == 'TRANSFER';
      final isTransfer = tx.transactionType.toUpperCase() == 'TRANSFER';
      final typeText = isTransfer ? 'Transfer' : (isExpense ? 'Pengeluaran' : 'Pemasukan');
      final amountVal = '${isExpense ? "-" : "+"}${tx.amount.toStringAsFixed(0)}';
      final notes = tx.notes?.replaceAll('"', '""') ?? '';
      
      buffer.writeln('"$dateStr","$typeText","${tx.categoryName ?? ""}","$amountVal","${tx.walletName ?? ""}","$notes","${tx.creatorName ?? ""}"');
    }
    
    final bytes = utf8.encode(buffer.toString());
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Laporan_Transaksi_${formattedMonth}_$year.csv',
    );
  }

  String _monthName(int monthNum) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[monthNum - 1];
  }
}
