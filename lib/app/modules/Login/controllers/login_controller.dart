import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final emailC = TextEditingController();
  final passC  = TextEditingController();

  final obscure = true.obs;
  void toggleObscure() => obscure.value = !obscure.value;

  Future<void> login() async {
    // VALIDASI SINGKAT (boleh kamu ganti sesuai kebutuhan)
    if (emailC.text.trim().isEmpty || passC.text.isEmpty) {
      Get.snackbar('Validasi', 'Email dan password tidak boleh kosong');
      return;
    }

    // >>> NAVIGASI KE DASHBOARD <<<
    // Pakai path langsung (paling aman, anti-typo):
    Get.offAllNamed('/dashboard');

    // Jika kamu pakai constants:
    // Get.offAllNamed(Routes.DASBOARD);
  }

  Future<void> loginWithGoogle() async {
    // nanti isi
  }

  @override
  void onClose() {
    emailC.dispose();
    passC.dispose();
    super.onClose();
  }
}
