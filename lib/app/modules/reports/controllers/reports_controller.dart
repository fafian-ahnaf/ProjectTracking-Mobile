import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart'; // Pastikan ada
import 'package:project_tracking/app/data/models/project_item.dart';
import 'package:project_tracking/app/data/service/report_service.dart';

class ReportsController extends GetxController {
  final ReportService _service = ReportService();

  var isLoading = false.obs;
  
  // State Data
  var totalProjects = 0.obs;
  var avgProgress = 0.obs;
  var statusBreakdown = <String, int>{}.obs;
  
  // Chart Data
  var chartLabels = <String>[].obs;
  var chartValues = <int>[].obs;
  
  // List Project
  var projects = <ProjectItem>[].obs;

  // Filter
  var startDate = Rxn<DateTime>();
  var endDate = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    fetchReport();
  }

  Future<void> fetchReport() async {
    try {
      isLoading.value = true;
      final res = await _service.getReportData(
        start: startDate.value, 
        end: endDate.value
      );

      if (res['status'] == true) {
        final data = res['data'];
        
        // 1. Statistik
        final stats = data['statistics'];
        totalProjects.value = stats['total_projects'] ?? 0;
        avgProgress.value = (stats['average_progress'] ?? 0).toInt();
        
        // Breakdown (Map dynamic ke Map<String, int>)
        final breakdown = stats['status_breakdown'] as Map<String, dynamic>;
        statusBreakdown.value = breakdown.map((key, value) => MapEntry(key, value as int));

        // 2. Chart
        final chart = data['chart'];
        chartLabels.assignAll(List<String>.from(chart['labels']));
        chartValues.assignAll(List<int>.from(chart['values']));

        // 3. Project List
        final list = data['projects_list'] as List;
        projects.assignAll(list.map((e) => ProjectItem.fromJson(e)).toList());
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat laporan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> exportToCsv() async {
    try {
      Get.snackbar('Exporting', 'Sedang mengunduh laporan...', showProgressIndicator: true);
      final path = await _service.downloadCsv(start: startDate.value, end: endDate.value);
      
      if (path != null) {
        Get.closeCurrentSnackbar();
        Get.snackbar('Sukses', 'Laporan tersimpan', 
          mainButton: TextButton(
            onPressed: () => OpenFilex.open(path),
            child: const Text('BUKA', style: TextStyle(color: Colors.white)),
          ),
          backgroundColor: Colors.green, colorText: Colors.white
        );
      } else {
        Get.snackbar('Gagal', 'Gagal mengunduh file');
      }
    } catch (e) {
      Get.snackbar('Error', '$e');
    }
  }

  void pickDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: startDate.value != null && endDate.value != null
          ? DateTimeRange(start: startDate.value!, end: endDate.value!)
          : null,
    );

    if (picked != null) {
      startDate.value = picked.start;
      endDate.value = picked.end;
      fetchReport(); // Auto refresh saat filter berubah
    }
  }
  
  void clearFilter() {
    startDate.value = null;
    endDate.value = null;
    fetchReport();
  }
}