import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/service/login_service.dart';
import '../../dasboard/views/dasboard_view.dart'; 

class LoginController extends GetxController {
  final LoginService _loginService = LoginService();

  final emailC = TextEditingController();
  final passC = TextEditingController();

  var obscure = true.obs;
  var isLoading = false.obs;

  void toggleObscure() {
    obscure.value = !obscure.value;
  }

  Future<void> login() async {
    // 1. Validasi Input Kosong
    if (emailC.text.isEmpty || passC.text.isEmpty) {
      Get.snackbar(
        'Peringatan', 
        'Email dan Password harus diisi',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
      );
      return;
    }

    // 2. Set Loading
    isLoading.value = true;

    // 3. Panggil Service Dio
    final result = await _loginService.login(emailC.text, passC.text);

    // 4. Stop Loading
    isLoading.value = false;

    // 5. Cek Hasil
    if (result['success']) {
      final token = result['data']['token'];
      final user = result['data']['user'];

      // Simpan Token ke SharedPreferences + debug cek simpan
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        final storedToken = prefs.getString('auth_token');
        debugPrint('Token disimpan: $storedToken');
      } catch (e) {
        debugPrint('Gagal menyimpan token: $e');
      }
      
      Get.snackbar(
        'Berhasil', 
        'Selamat datang, ${user['name']}',
        backgroundColor: const Color(0xFFA9BA9D), // Warna hijau dari LoginView
        colorText: Colors.black87,
      );

      // Pindah ke Dashboard
      Get.offAll(() => const DashboardView());
    } else {
      // Tampilkan Error dari API
      Get.snackbar(
        'Gagal Masuk', 
        result['message'],
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(10),
      );
    }
  }

  // Google Login (Sesuai kode kamu sebelumnya)
  void loginWithGoogle() {
     print("Fitur Google Login belum diimplementasi");
  }

  @override
  void onInit() {
    super.onInit();
    _debugCheckStoredToken();
  }

  Future<void> _debugCheckStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final t = prefs.getString('auth_token');
      debugPrint('Token tersimpan saat init: $t');
    } catch (e) {
      debugPrint('Gagal membaca token: $e');
    }
  }

  @override
  void onClose() {
    emailC.dispose();
    passC.dispose();
    super.onClose();
  }
}