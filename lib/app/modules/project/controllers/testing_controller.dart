import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_tracking/app/data/models/test_case_item.dart';
import 'package:project_tracking/app/data/service/testing_service.dart';

class TestingController extends GetxController {
  final String tagId;
  TestingController({required this.tagId});

  final TestingService _service = TestingService();
  
  var items = <TestCaseItem>[].obs;
  var isLoading = false.obs;
  var progress = 0.0.obs;

  int? projectId;

  // Status sesuai validasi API: required|in:Planned,In Progress,Passed,Failed
  final statuses = ['Planned', 'In Progress', 'Passed', 'Failed'];

  void setProjectId(int id) {
    projectId = id;
    fetchTestCases();
  }

  Future<void> fetchTestCases() async {
    if (projectId == null) return;
    try {
      isLoading.value = true;
      final data = await _service.getTestCases(projectId!);
      items.assignAll(data.map((e) => TestCaseItem.fromJson(e)).toList());
      _calculateProgress();
    } catch (e) {
      print("Error fetch testing: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateProgress() {
    if (items.isEmpty) {
      progress.value = 0.0;
      return;
    }
    // Hitung progress berdasarkan 'Passed'
    final passed = items.where((e) => e.status == 'Passed').length;
    progress.value = passed / items.length;
  }

  Future<void> add(TestCaseItem item) async {
    if (projectId == null) return;
    try {
      isLoading.value = true;
      final res = await _service.create(projectId!, item.toJson());
      
      if (res['status'] == 201) {
        await fetchTestCases();
        Get.snackbar('Sukses', 'Test Case ditambahkan', backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar('Gagal', res['data']['message'] ?? 'Gagal menyimpan', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', '$e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateItem(int id, TestCaseItem item) async {
    if (projectId == null) return;
    try {
      final res = await _service.update(projectId!, id, item.toJson());
      if (res['status'] == 200) {
        await fetchTestCases(); // Refresh agar relasi req/design terupdate namanya
        Get.snackbar('Sukses', 'Test Case diupdate', backgroundColor: Colors.green, colorText: Colors.white);
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
        Get.snackbar('Dihapus', 'Test Case dihapus');
      }
    } catch (e) {
      Get.snackbar('Error', '$e');
    }
  }
}