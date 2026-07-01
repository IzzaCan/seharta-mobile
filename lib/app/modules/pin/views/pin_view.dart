import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pin_controller.dart';

class PinView extends GetView<PinController> {
  const PinView({Key? key}) : super(key: key);

  // Palet Warna
  final Color primaryDark = const Color(0xFF0D2B33); // Dark Teal
  final Color greenAccent = const Color(0xFF1F9975); // Emerald Green
  final Color lightMint = const Color(0xFFE8F5EE); // Background atas
  final Color backgroundColor = const Color(0xFFF8F9FF);
  final Color cardColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      
      // APP BAR
      appBar: AppBar(
        backgroundColor: lightMint,
        elevation: 0,
        leading: Obx(() {
          if (controller.isUnlockMode.value) {
            return const SizedBox.shrink();
          }
          return IconButton(
            icon: Icon(Icons.arrow_back, color: primaryDark, size: 20),
            onPressed: () => Get.back(),
          );
        }),
        automaticallyImplyLeading: false,
        title: Obx(() => Text(
          controller.isUnlockMode.value
              ? 'Verifikasi PIN'
              : (controller.storedPin.value.isEmpty ? 'Buat PIN Keamanan' : 'PIN Keamanan'),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: primaryDark,
          ),
        )),
        centerTitle: false,
      ),

      // BODY UTAMA
      body: Obx(() {
        if (!controller.isInitialized.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return Column(
          children: [
            // Bagian Atas: Header & Indikator PIN
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [lightMint, backgroundColor],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Ikon Refresh/Lock
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: greenAccent.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: greenAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_reset,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Obx(() {
                    String titleText = 'PIN Saat Ini';
                    String descText = 'Masukkan 6 digit PIN Anda saat ini.';
                    
                    if (controller.isUnlockMode.value) {
                      titleText = 'Masukkan PIN';
                      descText = 'Masukkan 6 digit PIN keamanan Anda untuk masuk.';
                    } else if (controller.step.value == PinStep.enterNew) {
                      titleText = controller.storedPin.value.isEmpty 
                          ? 'Buat PIN Keamanan' 
                          : 'PIN Baru';
                      descText = 'Masukkan 6 digit PIN baru Anda.';
                    } else if (controller.step.value == PinStep.confirmNew) {
                      titleText = 'Konfirmasi PIN';
                      descText = 'Masukkan kembali 6 digit PIN baru Anda.';
                    }
                    
                    return Column(
                      children: [
                        Text(
                          titleText,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          descText,
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 16),

                  // Indikator 6 Titik (Dots)
                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (index) {
                        bool isFilled = index < controller.currentPin.value.length;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: isFilled ? primaryDark : Colors.grey[300],
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Badge "ENKRIPSI BERLAPIS"
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.security, color: greenAccent, size: 10),
                        const SizedBox(width: 4),
                        Text(
                          'ENKRIPSI BERLAPIS',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bagian Bawah: Custom Keypad Numpad
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Baris 1
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNumpadButton('1'),
                        _buildNumpadButton('2'),
                        _buildNumpadButton('3'),
                      ],
                    ),
                    const SizedBox(height: 5),
                    // Baris 2
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNumpadButton('4'),
                        _buildNumpadButton('5'),
                        _buildNumpadButton('6'),
                      ],
                    ),
                    const SizedBox(height: 5),
                    // Baris 3
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNumpadButton('7'),
                        _buildNumpadButton('8'),
                        _buildNumpadButton('9'),
                      ],
                    ),
                    const SizedBox(height: 5),
                    // Baris 4 (Kosong, Nol, Hapus)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(width: 55, height: 55),
                        _buildNumpadButton('0'),
                        _buildBackspaceButton(),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Link Lupa PIN
                    TextButton(
                      onPressed: controller.forgotPin,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Lupa PIN Anda?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: greenAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // WIDGET REUSABLE UNTUK KEYPAD

  // Tombol Angka Biasa
  Widget _buildNumpadButton(String number) {
    return InkWell(
      onTap: () => controller.addDigit(number),
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: 55,
        height: 55,
        alignment: Alignment.center,
        child: Text(
          number,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: primaryDark,
          ),
        ),
      ),
    );
  }

  // Tombol Backspace (Ikon Merah)
  Widget _buildBackspaceButton() {
    return InkWell(
      onTap: controller.removeDigit,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: 55,
        height: 55,
        alignment: Alignment.center,
        child: const Icon(
          Icons.backspace_outlined,
          color: Color(0xFFD32F2F),
          size: 24,
        ),
      ),
    );
  }
}
