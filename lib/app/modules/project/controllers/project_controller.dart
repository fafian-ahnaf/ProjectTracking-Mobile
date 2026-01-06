import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_tracking/app/data/models/project_item.dart';
import 'package:project_tracking/app/data/service/project_service.dart';

class ProjectController extends GetxController {
  final ProjectService _service = ProjectService();
  var projects = <ProjectItem>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProjects();
  }

  Future<void> fetchProjects() async {
    try {
      isLoading.value = true;
      final data = await _service.getProjects();
      projects.assignAll(data.map((e) => ProjectItem.fromJson(e)).toList());
    } catch (e) {
      print("Error fetch: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> add(ProjectItem item) async {
    try {
      isLoading.value = true;

      // 1. Format Tanggal yang Aman (YYYY-MM-DD)
      // toIso8601String() kadang bawa jam menit yg bikin Laravel bingung
      String? startStr = item.startDate?.toIso8601String().split('T')[0];
      String? endStr = item.endDate?.toIso8601String().split('T')[0];

      final payload = {
        'title': item.name,
        'pic': item.pic,
        'status': _mapStatusToApi(item.status), // Pastikan mapping benar
        'start_date': startStr,
        'end_date': endStr,
        'progress': item.progress,
        'activity': item.activity,
      };

      File? fileUpload;
      if (item.documentPath != null && !item.documentPath!.startsWith('http')) {
        fileUpload = File(item.documentPath!);
      }

      // 2. Panggil Service
      final result = await _service.createProject(payload, fileUpload);
      final statusCode = result['status'];
      final responseData = result['data'];

      // 3. Cek Status Code
      if (statusCode == 201 || statusCode == 200) {
        // SUKSES
        projects.insert(0, ProjectItem.fromJson(responseData['data']));
        Get.back();
        Get.snackbar(
          'Sukses',
          'Project berhasil dibuat',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else if (statusCode == 422) {
        // ERROR VALIDASI (Tampilkan pesan spesifik)
        String message = 'Data tidak valid';
        if (responseData['errors'] != null) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          // Ambil error pertama, misal: "The title field is required"
          message = errors.values.first[0];
        } else if (responseData['message'] != null) {
          message = responseData['message'];
        }

        Get.snackbar(
          'Gagal',
          message,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      } else {
        // Error Lain
        Get.snackbar(
          'Error',
          'Gagal menyimpan ($statusCode)',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Exception',
        'Terjadi kesalahan: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Fungsi updateAt dan removeAt sesuaikan juga jika perlu...
  Future<void> updateAt(int index, ProjectItem item) async {
    // Safety check: pastikan ada ID nya
    if (item.id == null) {
      Get.snackbar('Error', 'ID Project tidak ditemukan');
      return;
    }

    try {
      isLoading.value = true;

      // 1. Siapkan Payload (Format Tanggal YYYY-MM-DD)
      String? startStr = item.startDate?.toIso8601String().split('T')[0];
      String? endStr = item.endDate?.toIso8601String().split('T')[0];

      final payload = {
        'title': item.name,
        'pic': item.pic,
        'status': _mapStatusToApi(item.status),
        'start_date': startStr,
        'end_date': endStr,
        // Kirim data lain jika diperlukan API untuk update
        // 'progress': item.progress,
        // 'activity': item.activity,
      };

      // 2. Cek File: hanya upload jika path-nya BUKAN url (artinya file lokal baru)
      File? fileUpload;
      if (item.documentPath != null && !item.documentPath!.startsWith('http')) {
        fileUpload = File(item.documentPath!);
      }

      // 3. Panggil Service (gunakan ID item)
      final result = await _service.updateProject(
        item.id!,
        payload,
        fileUpload,
      );

      final statusCode = result['status'];
      final responseData = result['data'];

      // 4. Cek Status Code
      if (statusCode == 200) {
        // === SUKSES ===
        // Update data di list lokal berdasarkan response API terbaru
        projects[index] = ProjectItem.fromJson(responseData['data']);
        projects.refresh(); // Trigger UI update

        Get.back(); // Tutup Dialog Edit
        Get.snackbar(
          'Sukses',
          'Project berhasil diupdate',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else if (statusCode == 422) {
        // === ERROR VALIDASI (Menghindari Layar Merah) ===
        String message = 'Data tidak valid';
        if (responseData['errors'] != null) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          message = errors.values.first[0]; // Ambil pesan error pertama
        } else if (responseData['message'] != null) {
          message = responseData['message'];
        }
        Get.snackbar(
          'Gagal Edit',
          message,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        // === ERROR LAIN ===
        Get.snackbar(
          'Error',
          'Gagal update ($statusCode): ${responseData['message']}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Exception Edit: $e");
      Get.snackbar(
        'Gagal',
        'Terjadi kesalahan sistem',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ... (sisa fungsi removeAt, _mapStatusToApi sama seperti sebelumnya)
  Future<void> removeAt(int index) async {
    final item = projects[index];
    if (item.id == null) return;

    try {
      await _service.deleteProject(item.id!);
      projects.removeAt(index);
      Get.snackbar('Dihapus', 'Project berhasil dihapus');
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal menghapus: $e');
    }
  }

  // Pastikan Mapping Status Sesuai Database
  String _mapStatusToApi(String statusUi) {
    switch (statusUi) {
      case 'Belum Mulai':
        return 'todo';
      case 'In Progress':
        return 'in_progress';
      case 'Review':
        return 'review';
      case 'Selesai':
        return 'done';
      default:
        return 'todo';
    }
  }
}
