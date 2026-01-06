import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_tracking/app/data/models/development_item.dart';
import 'package:project_tracking/app/data/service/development_service.dart';

class DevelopmentController extends GetxController {
  final String tagId;
  DevelopmentController({required this.tagId});

  final DevelopmentService _service = DevelopmentService();
  
  var items = <DevelopmentItem>[].obs;
  var isLoading = false.obs;
  var progress = 0.0.obs;

  int? projectId;

  final statuses = ['In Progress', 'Review', 'Done'];

  void setProjectId(int id) {
    projectId = id;
    fetchDevelopments();
  }

  Future<void> fetchDevelopments() async {
    if (projectId == null) return;
    try {
      isLoading.value = true;
      final data = await _service.getDevelopments(projectId!);
      items.assignAll(data.map((e) => DevelopmentItem.fromJson(e)).toList());
      _calculateProgress();
    } catch (e) {
      print("Error fetch dev: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateProgress() {
    if (items.isEmpty) {
      progress.value = 0.0;
      return;
    }
    final done = items.where((e) => e.status == 'Done').length;
    progress.value = done / items.length;
  }

  Future<void> add(DevelopmentItem item) async {
    if (projectId == null) return;
    try {
      isLoading.value = true;
      final res = await _service.create(projectId!, item.toJson());
      
      if (res['status'] == 201) {
        await fetchDevelopments();
        Get.snackbar('Sukses', 'Task Development ditambahkan', backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar('Gagal', res['data']['message'] ?? 'Gagal menyimpan', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', '$e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateItem(int id, DevelopmentItem item) async {
    if (projectId == null) return;
    try {
      final res = await _service.update(projectId!, id, item.toJson());
      if (res['status'] == 200) {
        await fetchDevelopments(); // Refresh full list agar relasi design spec terupdate
        Get.snackbar('Sukses', 'Task Development diupdate', backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar('Gagal', res['data']['message'] ?? 'Gagal update', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', '$e');
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
        Get.snackbar('Dihapus', 'Task dihapus');
      }
    } catch (e) {
      Get.snackbar('Error', '$e');
    }
  }
}