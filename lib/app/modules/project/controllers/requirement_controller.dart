import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_tracking/app/data/models/requirement_item.dart';
import 'package:project_tracking/app/data/service/requirement_service.dart';

class RequirementController extends GetxController {
  final RequirementService _service = RequirementService();
  
  // State
  var items = <RequirementItem>[].obs;
  var isLoading = false.obs;
  
  // Progress (Hitung berapa % yang statusnya 'Done')
  var progress = 0.0.obs; 

  // ID Project akan di-set dari UI saat init
  int? projectId;

  void setProjectId(int id) {
    projectId = id;
    fetchRequirements();
  }

  Future<void> fetchRequirements() async {
    if (projectId == null) return;
    try {
      isLoading.value = true;
      final data = await _service.getRequirements(projectId!);
      items.assignAll(data.map((e) => RequirementItem.fromJson(e)).toList());
      _calculateProgress();
    } catch (e) {
      print("Error fetch req: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateProgress() {
    if (items.isEmpty) {
      progress.value = 0.0;
      return;
    }
    final doneCount = items.where((e) => e.status == 'Done').length;
    progress.value = doneCount / items.length;
  }

  Future<void> add(RequirementItem item) async {
    if (projectId == null) return;
    try {
      isLoading.value = true;
      final res = await _service.createRequirement(projectId!, item.toJson());
      
      if (res['status'] == 201) {
        // Refresh biar ID dan data sinkron
        await fetchRequirements(); 
        Get.back();
        Get.snackbar('Sukses', 'Requirement berhasil ditambahkan', backgroundColor: Colors.green, colorText: Colors.white);
      } else {
         Get.snackbar('Gagal', 'Gagal menyimpan data', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', '$e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateItem(int reqId, RequirementItem item) async {
    if (projectId == null) return;
    try {
      isLoading.value = true;
      final res = await _service.updateRequirement(projectId!, reqId, item.toJson());
      
      if (res['status'] == 200) {
        await fetchRequirements();
        Get.back();
        Get.snackbar('Sukses', 'Requirement berhasil diupdate', backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar('Gagal', 'Gagal update data', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', '$e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteItem(int reqId) async {
    if (projectId == null) return;
    try {
      final success = await _service.deleteRequirement(projectId!, reqId);
      if (success) {
        items.removeWhere((e) => e.id == reqId);
        _calculateProgress();
        Get.snackbar('Terhapus', 'Requirement berhasil dihapus');
      }
    } catch (e) {
      Get.snackbar('Error', '$e');
    }
  }
}