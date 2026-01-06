import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/service/register_service.dart'; // Import Service Baru
import '../../../routes/app_pages.dart';

class RegisterController extends GetxController {
  // Gunakan RegisterService
  final RegisterService _registerService = RegisterService();

  final usernameC = TextEditingController();
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final confirmC = TextEditingController();

  var obscure1 = true.obs;
  var obscure2 = true.obs;
  var isLoading = false.obs;

  void toggle1() => obscure1.value = !obscure1.value;
  void toggle2() => obscure2.value = !obscure2.value;

  Future<void> onRegister() async {
    // 1. Validasi Input Kosong
    if (usernameC.text.isEmpty ||
        emailC.text.isEmpty ||
        passC.text.isEmpty ||
        confirmC.text.isEmpty) {
      Get.snackbar(
        'Peringatan',
        'Semua kolom harus diisi',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // 2. Validasi Match Password (UX)
    if (passC.text != confirmC.text) {
      Get.snackbar(
        'Error',
        'Password konfirmasi tidak sama',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    // 3. Panggil Register Service
    final result = await _registerService.register(
      usernameC.text,
      emailC.text,
      passC.text,
      confirmC.text,
    );

    isLoading.value = false;

    if (result['success']) {
      // Sukses Register
      Get.snackbar(
        'Berhasil',
        'Register berhasil. Silakan masuk.',
        backgroundColor: const Color(0xFFA9BA9D), 
        colorText: Colors.black87,
        snackPosition: SnackPosition.TOP,
      );

      // Arahkan langsung ke form Login
      Get.offAllNamed(Routes.LOGIN);
    } else {
      // Gagal Register (misal email sudah ada)
      Get.snackbar(
        'Gagal',
        result['message'],
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void registerWithGoogle() {
    print("Google Register belum diimplementasi");
  }

  @override
  void onClose() {
    usernameC.dispose();
    emailC.dispose();
    passC.dispose();
    confirmC.dispose();
    super.onClose();
  }
}
