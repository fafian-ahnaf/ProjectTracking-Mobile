import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_tracking/app/data/models/user_model.dart';
import 'package:project_tracking/app/data/service/profile_service.dart';

class ProfileController extends GetxController {
  final ProfileService _service = ProfileService();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // State User
  var user = Rxn<User>();
  var isLoading = false.obs;
  var isSaving = false.obs;
  
  // Mode Edit
  var isEditing = false.obs;
  
  // Form Controllers
  late TextEditingController nameC;
  late TextEditingController emailC;
  
  // Password Change Controllers (Opsional)
  late TextEditingController currentPassC;
  late TextEditingController newPassC;
  late TextEditingController confirmPassC;

  final Color brand = const Color(0xFFF69220);

  @override
  void onInit() {
    super.onInit();
    nameC = TextEditingController();
    emailC = TextEditingController();
    currentPassC = TextEditingController();
    newPassC = TextEditingController();
    confirmPassC = TextEditingController();
    
    fetchProfile();
  }

  @override
  void onClose() {
    nameC.dispose();
    emailC.dispose();
    currentPassC.dispose();
    newPassC.dispose();
    confirmPassC.dispose();
    super.onClose();
  }

  void toggleEdit() {
    isEditing.value = !isEditing.value;
    // Reset form password jika batal edit
    if (!isEditing.value) {
      currentPassC.clear();
      newPassC.clear();
      confirmPassC.clear();
      // Reset nama/email ke data asli
      if (user.value != null) {
        nameC.text = user.value!.name;
        emailC.text = user.value!.email;
      }
    }
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      final res = await _service.getProfile();
      if (res['status'] == true) {
        user.value = User.fromJson(res['data']);
        nameC.text = user.value!.name;
        emailC.text = user.value!.email;
      }
    } catch (e) {
      print("Error fetch profile: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isSaving.value = true;

      // Siapkan payload
      Map<String, dynamic> payload = {
        'name': nameC.text.trim(),
        'email': emailC.text.trim(),
      };

      // Jika user ingin ganti password
      if (newPassC.text.isNotEmpty) {
        payload['current_password'] = currentPassC.text;
        payload['password'] = newPassC.text;
        payload['password_confirmation'] = confirmPassC.text;
      }

      final res = await _service.updateProfile(payload);
      final status = res['status'];
      final body = res['body'];

      if (status == 200) {
        // Sukses
        user.value = User.fromJson(body['data']);
        Get.snackbar('Sukses', 'Profil berhasil diperbarui', backgroundColor: Colors.green, colorText: Colors.white);
        
        // Reset field password & mode edit
        currentPassC.clear();
        newPassC.clear();
        confirmPassC.clear();
        isEditing.value = false;
        
      } else if (status == 422) {
        // Error Validasi Laravel
        String message = 'Data tidak valid';
        if (body['errors'] != null) {
          final errors = body['errors'] as Map<String, dynamic>;
          message = errors.values.first[0]; // Ambil error pertama
        } else if (body['message'] != null) {
          message = body['message'];
        }
        Get.snackbar('Gagal', message, backgroundColor: Colors.orange, colorText: Colors.white);
      } else {
        Get.snackbar('Error', body['message'] ?? 'Gagal update profil', backgroundColor: Colors.red, colorText: Colors.white);
      }

    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan sistem: $e');
    } finally {
      isSaving.value = false;
    }
  }
}