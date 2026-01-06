import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_tracking/app/data/models/design_spec_item.dart';
import 'package:project_tracking/app/data/service/design_service.dart';

class DesignController extends GetxController {
  final String tagId;
  DesignController({required this.tagId});

  final DesignService _service = DesignService();

  var items = <DesignSpecItem>[].obs;
  var isLoading = false.obs;
  var progress = 0.0.obs;

  int? projectId;

  // 🔥 UPDATE: Hanya gunakan status yang valid di API Laravel
  final types = ['UI', 'API', 'DB', 'Flow'];
  final statuses = ['Draft', 'Review', 'Approved'];

  void setProjectId(int id) {
    projectId = id;
    fetchDesignSpecs();
  }

  Future<void> fetchDesignSpecs() async {
    if (projectId == null) return;
    try {
      isLoading.value = true;
      final data = await _service.getDesignSpecs(projectId!);
      items.assignAll(data.map((e) => DesignSpecItem.fromJson(e)).toList());
      _calculateProgress();
    } catch (e) {
      print("Error fetch design: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateProgress() {
    if (items.isEmpty) {
      progress.value = 0.0;
      return;
    }
    final approved = items.where((e) => e.status == 'Approved').length;
    progress.value = approved / items.length;
  }

  // 🔥 FUNGSI ADD DENGAN DEBUG LENGKAP 🔥
  Future<void> add(DesignSpecItem item) async {
    if (projectId == null) {
      print("❌ ERROR: Project ID is null");
      return;
    }

    try {
      isLoading.value = true;

      // 1. Cek Data yang mau dikirim (Payload)
      final payload = item.toJson();

      print("================= DEBUG REQUEST =================");
      print("URL: /api/projects/$projectId/design-specs");
      print(
        "PAYLOAD: $payload",
      ); // Cek di console, apakah status 'Planned' atau 'Draft'?
      print("=================================================");

      final res = await _service.create(projectId!, payload);

      print("================= DEBUG RESPONSE =================");
      print("STATUS CODE: ${res['status']}");
      print("DATA: ${res['data']}");
      print("==================================================");

      final statusCode = res['status'];
      final responseData = res['data'];

      if (statusCode == 201 || statusCode == 200) {
        await fetchDesignSpecs();
        Get.snackbar(
          'Sukses',
          'Design Spec ditambahkan',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else if (statusCode == 422) {
        // Tangkap pesan error validasi spesifik
        String message = 'Validasi Gagal';
        if (responseData['errors'] != null) {
          // Ambil error pertama yang muncul
          final errors = responseData['errors'] as Map<String, dynamic>;
          print("❌ VALIDATION ERRORS: $errors"); // Lihat detail error field apa

          final firstErrorKey = errors.keys.first;
          final firstErrorMsg = errors[firstErrorKey][0];
          message = "$firstErrorKey: $firstErrorMsg";
        } else {
          message = responseData['message'] ?? 'Error tidak diketahui';
        }

        Get.snackbar(
          'Gagal',
          message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      } else {
        Get.snackbar(
          'Gagal',
          responseData['message'] ?? 'Gagal menyimpan',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e, stacktrace) {
      print("❌ EXCEPTION: $e");
      print("STACKTRACE: $stacktrace");
      Get.snackbar(
        'Error',
        '$e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStatus(int id, String newStatus) async {
    final item = items.firstWhereOrNull((e) => e.id == id);
    if (item == null || projectId == null) return;

    final data = item.toJson();
    data['status'] = newStatus;

    try {
      final res = await _service.update(projectId!, id, data);
      if (res['status'] == 200) {
        item.status = newStatus;
        items.refresh();
        _calculateProgress();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> removeAt(int index) async {
    final item = items[index];
    if (item.id == null || projectId == null) return;

    try {
      final success = await _service.delete(projectId!, item.id!);
      if (success) {
        items.removeAt(index);
        _calculateProgress();
        Get.snackbar('Dihapus', 'Design Spec dihapus');
      }
    } catch (e) {
      Get.snackbar('Error', '$e');
    }
  }
}
