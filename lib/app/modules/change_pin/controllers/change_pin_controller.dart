import 'package:get/get.dart';

class ChangePinController extends GetxController {
  // State reaktif untuk menyimpan PIN yang diketik
  var currentPin = ''.obs;

  // Fungsi saat tombol angka ditekan
  void addDigit(String digit) {
    if (currentPin.value.length < 6) {
      currentPin.value += digit;
    }

    // Otomatis proses jika sudah 6 digit
    if (currentPin.value.length == 6) {
      _verifyPin();
    }
  }

  // Fungsi saat tombol hapus (backspace) ditekan
  void removeDigit() {
    if (currentPin.value.isNotEmpty) {
      currentPin.value = currentPin.value.substring(
        0,
        currentPin.value.length - 1,
      );
    }
  }

  // Fungsi untuk memverifikasi PIN saat ini
  void _verifyPin() {
    print("Memverifikasi PIN: ${currentPin.value}");
    // Simulasi loading atau lanjut ke tahap "Masukkan PIN Baru"
    // Setelah sukses diverifikasi:
    // currentPin.value = ''; // Reset form untuk PIN baru
  }

  void forgotPin() {
    print("Membuka halaman Lupa PIN...");
  }
}
