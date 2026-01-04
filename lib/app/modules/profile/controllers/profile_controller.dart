import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final formKey = GlobalKey<FormState>();

  // Text controllers
  final nameC = TextEditingController();
  final emailC = TextEditingController();

  // States
  final isEditing = false.obs;
  final isSaving = false.obs;

  // Mock data user (silakan ganti dari service/backend)
  final _user = {'name': 'maulidha', 'email': 'maulidhafia0@gmail.com'};

  Color get brand => const Color(0xFFF69220);

  get name => null;

  get email => null;

  get phone => null;

  @override
  void onInit() {
    nameC.text = _user['name']!;
    emailC.text = _user['email']!;
    super.onInit();
  }

  void toggleEdit() => isEditing.toggle();

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;

    isSaving.value = true;
    try {
      // TODO: panggil service update profile ke backend
      await Future.delayed(const Duration(milliseconds: 800));

      _user['name'] = nameC.text.trim();
      _user['email'] = emailC.text.trim();

      isEditing.value = false;
      Get.snackbar(
        'Profil diperbarui', 'Perubahan berhasil disimpan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87, colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
    } catch (e) {
      Get.snackbar(
        'Gagal', 'Terjadi kesalahan saat menyimpan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700, colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    nameC.dispose();
    emailC.dispose();
    super.onClose();
  }

  void updateProfile({required String newName, required String newEmail, required String newPhone}) {}
}
