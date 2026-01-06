import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_tracking/app/data/service/planning_service.dart';

class PlanningController extends GetxController {
  final int projectId;
  PlanningController(this.projectId);

  final PlanningService _service = PlanningService();

  // State
  var isLoading = false.obs;
  var planningNote = ''.obs;
  var planningActivity = ''.obs; // Ini judul kegiatannya
  
  var files = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchPlanningData();
  }

  Future<void> fetchPlanningData() async {
    try {
      isLoading.value = true;
      final res = await _service.getPlanning(projectId);
      
      if (res['status'] == true) {
        final data = res['data'];
        planningNote.value = data['planning_note'] ?? '';
        planningActivity.value = data['planning_activity'] ?? '';
        
        if (data['files'] != null) {
          files.assignAll(List<Map<String, dynamic>>.from(data['files']));
        }
      }
    } catch (e) {
      print("Error fetch planning: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // UPDATE: Tambahkan parameter newActivity
  Future<void> saveChanges({
    String? newNote, 
    String? newActivity, 
    List<File>? newFiles
  }) async {
    try {
      isLoading.value = true;

      final res = await _service.updatePlanning(
        projectId: projectId,
        note: newNote ?? planningNote.value,
        activity: newActivity ?? planningActivity.value, // Kirim judul baru
        newFiles: newFiles,
      );

      final status = res['status'];
      
      if (status == 200) {
        // Update state lokal biar UI langsung berubah tanpa fetch ulang
        if (newNote != null) planningNote.value = newNote;
        if (newActivity != null) planningActivity.value = newActivity;
        
        await fetchPlanningData(); // Refresh file list & data terbaru
        
        Get.snackbar('Sukses', 'Data Planning berhasil disimpan', 
          backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar('Gagal', res['data']['message'] ?? 'Gagal menyimpan',
          backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', '$e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteFile(int fileId) async {
    try {
      final success = await _service.deleteFile(projectId, fileId);
      if (success) {
        files.removeWhere((f) => f['id'] == fileId);
        Get.snackbar('Terhapus', 'File berhasil dihapus');
      } else {
        Get.snackbar('Gagal', 'Gagal menghapus file');
      }
    } catch (e) {
      Get.snackbar('Error', 'Kesalahan: $e');
    }
  }
  
  Future<void> pickAndUploadFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null) {
      List<File> filesToUpload = result.paths.map((path) => File(path!)).toList();
      await saveChanges(newFiles: filesToUpload);
    }
  }
}