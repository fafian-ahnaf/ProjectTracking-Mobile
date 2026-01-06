import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_tracking/app/data/models/deployment_item.dart';
import 'package:project_tracking/app/data/service/deployment_service.dart';

class DeploymentController extends GetxController {
  final String tagId;
  DeploymentController({required this.tagId});

  final DeploymentService _service = DeploymentService();
  
  var items = <DeploymentItem>[].obs;
  var isLoading = false.obs;
  var progress = 0.0.obs;

  int? projectId;

  final statuses = ['Planned', 'In Progress', 'Success', 'Failed'];
  final environments = ['Development', 'Staging', 'Production'];

  void setProjectId(int id) {
    projectId = id;
    fetchDeployments();
  }

  Future<void> fetchDeployments() async {
    if (projectId == null) return;
    try {
      isLoading.value = true;
      final data = await _service.getDeployments(projectId!);
      items.assignAll(data.map((e) => DeploymentItem.fromJson(e)).toList());
      _calculateProgress();
    } catch (e) {
      print("Error fetch deploy: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateProgress() {
    if (items.isEmpty) {
      progress.value = 0.0;
      return;
    }
    final success = items.where((e) => e.status == 'Success').length;
    progress.value = success / items.length;
  }

  Future<void> add(DeploymentItem item) async {
    if (projectId == null) return;
    try {
      isLoading.value = true;
      final res = await _service.create(projectId!, item.toJson());
      
      if (res['status'] == 201) {
        await fetchDeployments();
        Get.snackbar('Sukses', 'Deployment ditambahkan', backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar('Gagal', res['data']['message'] ?? 'Gagal menyimpan', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', '$e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateItem(int id, DeploymentItem item) async {
    if (projectId == null) return;
    try {
      final res = await _service.update(projectId!, id, item.toJson());
      if (res['status'] == 200) {
        await fetchDeployments();
        Get.snackbar('Sukses', 'Deployment diupdate', backgroundColor: Colors.green, colorText: Colors.white);
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
        Get.snackbar('Dihapus', 'Data deployment dihapus');
      }
    } catch (e) {
      Get.snackbar('Error', '$e');
    }
  }
}