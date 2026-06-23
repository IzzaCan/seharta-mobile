import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  // Definisi warna sesuai desain
  final Color primaryColor = const Color(0xFF0F2C36); // Biru gelap
  final Color accentColor = const Color(0xFF1F9975); // Hijau
  final Color borderColor = const Color(0xFFE0E5E9);
  final Color textHintColor = const Color(0xFF9098B1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Logo & Nama Aplikasi
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.wallet, // Ganti dengan asset logo Anda jika ada
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Seharta',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // 2. Teks Sambutan
              Text(
                'Selamat Datang',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Masuk ke akun Anda untuk mengelola\nrencana bersama.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // 3. Tombol Login Google
              Obx(() => SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: controller.isGoogleLoading.value ? null : controller.loginWithGoogle,
                  icon: controller.isGoogleLoading.value 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.g_mobiledata, size: 30, color: Colors.blue), // Placeholder ikon Google
                  label: Text(
                    controller.isGoogleLoading.value ? 'Memproses...' : 'Lanjutkan dengan Google',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFF8F9FB),
                    side: BorderSide(color: borderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              )),
              const SizedBox(height: 24),

              // 4. Divider "Atau Email"
              Row(
                children: [
                  Expanded(child: Divider(color: borderColor)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Atau Email',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ),
                  Expanded(child: Divider(color: borderColor)),
                ],
              ),
              const SizedBox(height: 24),

              // 5. Input Email
              Text(
                'ALAMAT EMAIL',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'nama@email.com',
                  hintStyle: TextStyle(color: textHintColor),
                  prefixIcon: Icon(Icons.mail_outline, color: textHintColor),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 6. Input Password & Lupa Sandi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'KATA SANDI',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.toNamed('/forgot-password'),
                    child: Text(
                      'Lupa Sandi?',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Obx(() => TextFormField(
                    controller: controller.passwordController,
                    obscureText: controller.isPasswordHidden.value,
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      hintStyle: TextStyle(color: textHintColor),
                      prefixIcon: Icon(Icons.lock_outline, color: textHintColor),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isPasswordHidden.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: textHintColor,
                        ),
                        onPressed: controller.togglePasswordView,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: primaryColor),
                      ),
                    ),
                  )),
              const SizedBox(height: 32),

              // 7. Tombol Masuk Sekarang
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value ? null : controller.login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        disabledBackgroundColor: primaryColor.withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Masuk Sekarang',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  )),
              const SizedBox(height: 24),

              // 8. Teks Daftar
              Center(
                child: GestureDetector(
                  onTap: () => Get.toNamed('/register'),
                  child: RichText(
                    text: TextSpan(
                      text: 'Belum punya akun? ',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      children: [
                        TextSpan(
                          text: 'Daftar Gratis',
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // 9. Banner Testimoni/Proof
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F6FF), // Biru sangat pudar
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    // Avatar stack (mockup)
                    SizedBox(
                      width: 50,
                      child: Stack(
                        children: [
                          const CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.grey,
                            backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=Suami&background=0D2B33&color=fff'),
                          ),
                          Positioned(
                            left: 18,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.white,
                              child: const CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.blueGrey,
                                backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=Istri&background=1F9975&color=fff'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          text: '5.000+ pasangan telah mencapai\n',
                          style: TextStyle(color: Colors.grey[700], fontSize: 10, height: 1.5),
                          children: [
                            TextSpan(
                              text: 'Financial Freedom ',
                              style: TextStyle(color: accentColor, fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(text: 'bersama.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}