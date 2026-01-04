import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterController extends GetxController {
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final confirmC = TextEditingController();

  final obscure1 = true.obs;
  final obscure2 = true.obs;

  get registerWithGoogle => null;

  get usernameC => null;

  void toggle1() => obscure1.value = !obscure1.value;
  void toggle2() => obscure2.value = !obscure2.value;

  Future<void> onRegister() async {
    final email = emailC.text.trim();
    final pass = passC.text;
    final confirm = confirmC.text;

    if (email.isEmpty || pass.isEmpty || confirm.isEmpty) {
      Get.snackbar('Validasi', 'Semua field wajib diisi');
      return;
    }
    if (pass != confirm) {
      Get.snackbar('Error', 'Password tidak sama');
      return;
    }

    // Simpan ke SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
    await prefs.setString('user_pass', pass);

    Get.snackbar('Berhasil', 'Registrasi sukses!');
    Get.offAllNamed('/login'); // pindah ke login
  }

  @override
  void onClose() {
    emailC.dispose();
    passC.dispose();
    confirmC.dispose();
    super.onClose();
  }
}
