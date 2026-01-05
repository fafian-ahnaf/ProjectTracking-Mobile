import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_tracking/app/data/models/maintenance_item.dart';
import 'package:project_tracking/app/data/service/maintenance_service.dart';

class MaintenanceController extends GetxController {
  final String tagId;
  MaintenanceController({required this.tagId});

  final MaintenanceService _service = MaintenanceService();
  
  var items = <MaintenanceItem>[].obs;
  var isLoading = false.obs;
  var progress = 0.0.obs;

  int? projectId;

  // Status sesuai API
  final statuses = ['Planned', 'In Progress', 'Resolved', 'Closed'];

  void setProjectId(int id) {
    projectId = id;
    fetchMaintenances();
  }

  Future<void> fetchMaintenances() async {
    if (projectId == null) return;
    try {
      isLoading.value = true;
      final data = await _service.getMaintenances(projectId!);
      items.assignAll(data.map((e) => MaintenanceItem.fromJson(e)).toList());
      _calculateProgress();
    } catch (e) {
      print("Error fetch maintenance: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateProgress() {
    if (items.isEmpty) {
      progress.value = 0.0;
      return;
    }
    // Hitung item yang sudah Resolved atau Closed
    final done = items.where((e) => e.status == 'Resolved' || e.status == 'Closed').length;
    progress.value = done / items.length;
  }

  Future<void> add(MaintenanceItem item) async {
    if (projectId == null) return;
    try {
      isLoading.value = true;
      final res = await _service.create(projectId!, item.toJson());
      
      if (res['status'] == 201) {
        await fetchMaintenances();
        Get.snackbar('Sukses', 'Task Maintenance ditambahkan', backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar('Gagal', res['data']['message'] ?? 'Gagal menyimpan', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', '$e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateItem(int id, MaintenanceItem item) async {
    if (projectId == null) return;
    try {
      final res = await _service.update(projectId!, id, item.toJson());
      if (res['status'] == 200) {
        await fetchMaintenances();
        Get.snackbar('Sukses', 'Task Maintenance diupdate', backgroundColor: Colors.green, colorText: Colors.white);
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
        Get.snackbar('Dihapus', 'Task maintenance dihapus');
      }
    } catch (e) {
      Get.snackbar('Error', '$e');
    }
  }
}