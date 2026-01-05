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

  // Variabel untuk menyimpan ID Project
  int? projectId;

  final types = ['UI', 'API', 'DB', 'Flow'];
  final statuses = ['Draft', 'Review', 'Approved'];

  // Dipanggil dari UI untuk set project ID & load data
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

  Future<void> add(DesignSpecItem item) async {
    if (projectId == null) return;
    try {
      isLoading.value = true;
      final res = await _service.create(projectId!, item.toJson());
      
      if (res['status'] == 201) {
        await fetchDesignSpecs();
        Get.snackbar('Sukses', 'Design Spec ditambahkan', backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar('Gagal', res['data']['message'] ?? 'Gagal menyimpan', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', '$e');
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