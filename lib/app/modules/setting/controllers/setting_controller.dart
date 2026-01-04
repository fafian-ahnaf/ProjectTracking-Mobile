import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_tracking/app/routes/app_pages.dart';
import 'package:flutter/material.dart';

class SettingController extends GetxController {
  final notifEnabled = true.obs;
  final marketingEmail = false.obs;
  final darkMode = false.obs;

  @override
  void onInit() {
    darkMode.value = Get.isDarkMode;
    super.onInit();
  }

  void toggleNotif(bool v) => notifEnabled.value = v;
  void toggleMarketing(bool v) => marketingEmail.value = v;

  void toggleDark(bool v) {
    darkMode.value = v;
    Get.changeThemeMode(v ? ThemeMode.dark : ThemeMode.light);
  }

  // ==== LOGOUT ====
  void logout() {
    Get.defaultDialog(
      title: 'Konfirmasi',
      middleText: 'Yakin ingin keluar dari akun?',
      textCancel: 'Batal',
      textConfirm: 'Keluar',
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFF69220),
      onConfirm: () async {
        Get.back(); // tutup dialog

        // Hapus data login dari SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        await prefs.remove('userEmail');
        await prefs.remove('userName');

        // Kembali ke halaman login
        Get.offAllNamed(Routes.LOGIN); // pastikan Routes.LOGIN sudah terdaftar

        Get.snackbar(
          'Logout Berhasil',
          'Kamu telah keluar dari akun.',
          backgroundColor: Colors.black87,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(12),
        );
      },
    );
  }
}
