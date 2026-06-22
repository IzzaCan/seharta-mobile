import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../data/services/auth_service.dart';

class LoginController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  // Controller untuk text field
  late TextEditingController emailController;
  late TextEditingController passwordController;

  // Obscure text untuk password
  var isPasswordHidden = true.obs;
  
  // Loading state untuk tombol login
  var isLoading = false.obs;

  // Loading state untuk Google Sign-In
  var isGoogleLoading = false.obs;

  // Flag inisialisasi Google Sign-In
  bool _isGoogleSignInInitialized = false;

  @override
  void onInit() {
    super.onInit();
    // Default testing email bisa dikosongkan agar lebih bersih untuk user
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordView() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  // Validasi Input
  bool _validateInput() {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty) {
      Get.snackbar(
        'Validasi Gagal',
        'Alamat email tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFDE8E8),
        colorText: const Color(0xFF9B1C1C),
        margin: const EdgeInsets.all(16),
      );
      return false;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        'Validasi Gagal',
        'Format email tidak valid',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFDE8E8),
        colorText: const Color(0xFF9B1C1C),
        margin: const EdgeInsets.all(16),
      );
      return false;
    }

    if (password.isEmpty) {
      Get.snackbar(
        'Validasi Gagal',
        'Kata sandi tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFDE8E8),
        colorText: const Color(0xFF9B1C1C),
        margin: const EdgeInsets.all(16),
      );
      return false;
    }

    if (password.length < 8) {
      Get.snackbar(
        'Validasi Gagal',
        'Kata sandi minimal harus terdiri dari 8 karakter',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFDE8E8),
        colorText: const Color(0xFF9B1C1C),
        margin: const EdgeInsets.all(16),
      );
      return false;
    }

    return true;
  }

  // Aksi Login ke Backend
  Future<void> login() async {
    if (!_validateInput()) return;

    isLoading.value = true;
    try {
      await _authService.login(
        emailController.text.trim(),
        passwordController.text,
      );

      Get.snackbar(
        'Berhasil',
        'Selamat Datang, ${_authService.currentUser.value?.fullName ?? "Pengguna"}!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDEF7EC),
        colorText: const Color(0xFF03543F),
        margin: const EdgeInsets.all(16),
      );

      // Arahkan ke /home jika sudah memiliki familyId, atau ke /select-status jika belum
      if (_authService.currentUser.value?.familyId != null) {
        Get.offNamed('/home');
      } else {
        Get.offNamed('/select-status');
      }
    } catch (e) {
      if (e.toString() == 'Email belum diverifikasi') {
        Get.snackbar(
          'Perhatian',
          'Akun Anda belum diverifikasi. Silakan masukkan kode OTP.',
          backgroundColor: const Color(0xFFFCE8B2),
          colorText: const Color(0xFFE65100),
        );
        Get.offAllNamed('/otp-verification', arguments: emailController.text.trim());
        return;
      }

      Get.snackbar(
        'Login Gagal',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFDE8E8),
        colorText: const Color(0xFF9B1C1C),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Aksi Login via Google
  Future<void> loginWithGoogle() async {
    isGoogleLoading.value = true;
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      
      if (!_isGoogleSignInInitialized) {
        await googleSignIn.initialize(
          serverClientId: '128158425180-n4dc75ge2krp7m8mkpg38b1mjm23or77.apps.googleusercontent.com',
        );
        _isGoogleSignInInitialized = true;
      }

      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Gagal mendapatkan token Google');
      }

      // Kirim idToken ke backend
      await _authService.loginWithGoogle(idToken);

      Get.snackbar(
        'Berhasil',
        'Selamat Datang, ${_authService.currentUser.value?.fullName ?? "Pengguna"}!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDEF7EC),
        colorText: const Color(0xFF03543F),
        margin: const EdgeInsets.all(16),
      );

      // Arahkan ke /home jika sudah memiliki familyId, atau ke /select-status jika belum
      if (_authService.currentUser.value?.familyId != null) {
        Get.offAllNamed('/home');
      } else {
        Get.offAllNamed('/select-status');
      }
    } catch (e) {
      if (e is GoogleSignInException && e.code == GoogleSignInExceptionCode.canceled) {
        // User membatalkan proses sign-in secara manual, abaikan error snackbar
        return;
      }
      Get.snackbar(
        'Login Gagal',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFDE8E8),
        colorText: const Color(0xFF9B1C1C),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      );
    } finally {
      isGoogleLoading.value = false;
    }
  }
}
