import 'package:get/get.dart';

class WelcomeController extends GetxController {
  void goToLogin() {
    // TODO: arahkan ke halaman login kamu
    // sementara pakai snackbar biar tidak error
    Get.snackbar('Navigasi', 'Pergi ke halaman Login');
    // Get.toNamed(Routes.LOGIN);
  }

  void goToRegister() {
    Get.snackbar('Navigasi', 'Pergi ke halaman Registrasi');
    // Get.toNamed(Routes.REGISTER);
  }
}
