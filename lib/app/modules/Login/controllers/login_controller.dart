import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart'; // 1. Ganti SharedPrefs jadi ini
import '../../../data/service/login_service.dart';
import '../../../routes/app_pages.dart'; // 2. Import Routes

class LoginController extends GetxController {
  final LoginService _loginService = LoginService();
  final box = GetStorage(); // Inisialisasi Storage

  final emailC = TextEditingController();
  final passC = TextEditingController();

  var obscure = true.obs;
  var isLoading = false.obs;

  void toggleObscure() {
    obscure.value = !obscure.value;
  }

  Future<void> login() async {
    if (emailC.text.isEmpty || passC.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Email dan Password harus diisi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final result = await _loginService.login(emailC.text, passC.text);
      isLoading.value = false;

      if (result['success']) {
        final token = result['data']['token'];
        final user = result['data']['user'];

        // ===== PERBAIKAN DI SINI =====

        // 1. Simpan Token (Kunci harus sama dengan yang dibaca DashboardService)
        box.write('token', token);

        // 2. Simpan Data User (Untuk ditampilkan di Header Dashboard)
        box.write('user', user);

        debugPrint("Token saved: $token");
        debugPrint("User saved: ${user['name']}");

        Get.snackbar(
          'Sukses',
          'Selamat datang, ${user['name']}',
          backgroundColor: const Color(0xFFA9BA9D),
          colorText: Colors.black87,
        );

        // 3. Gunakan Named Route agar rapi
        Get.offAllNamed(Routes.DASBOARD);
      } else {
        Get.snackbar(
          'Gagal',
          result['message'],
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Terjadi kesalahan sistem',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void loginWithGoogle() {
    print("Fitur Google Login belum diimplementasi");
  }

  // Fitur logout sementara untuk test (Opsional)
  void logout() {
    box.remove('token');
    box.remove('user');
    Get.offAllNamed(Routes.LOGIN);
  }

  @override
  void onClose() {
    emailC.dispose();
    passC.dispose();
    super.onClose();
  }
}
