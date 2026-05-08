import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  // Controller untuk text field
  late TextEditingController emailController;
  late TextEditingController passwordController;

  // Obscure text untuk password
  var isPasswordHidden = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Inisialisasi controller, bisa diisi default value untuk testing
    emailController = TextEditingController(text: 'admin@localhost');
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

  void login() {
    // Logika login Anda di sini
    print("Login ditekan dengan email: ${emailController.text}");
  }
}