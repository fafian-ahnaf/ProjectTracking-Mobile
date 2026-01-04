// lib/app/modules/dasboard/controllers/dasboard_controller.dart
import 'package:get/get.dart';
import 'package:project_tracking/app/data/models/project_item.dart';
import 'package:project_tracking/app/modules/project/controllers/project_controller.dart';

class DashboardController extends GetxController {
  // Ambil/siapkan ProjectController (pastikan hanya sekali dibuat)
  late final ProjectController projectC =
      Get.isRegistered<ProjectController>()
          ? Get.find<ProjectController>()
          : Get.put(ProjectController(), permanent: true);

  // Angka-angka untuk kartu statistik
  final RxInt totalComplete   = 0.obs;
  final RxInt totalIncomplete = 0.obs;
  final RxInt totalOverdue    = 0.obs;
  final RxInt totalProject    = 0.obs;

  @override
  void onInit() {
    super.onInit();

    // Hitung awal
    _recompute(projectC.projects);

    // Dengarkan setiap perubahan pada daftar projects
    ever<List<ProjectItem>>(projectC.projects, _recompute);
  }

  // Aturan status selesai/overdue bisa kamu sesuaikan di sini
  bool _isComplete(ProjectItem p) {
    // anggap selesai bila status mengandung 'Selesai' atau progress 100
    final s = p.status.toLowerCase();
    return s.contains('selesai') || s.contains('done') || p.progress >= 100;
  }

  bool _isOverdue(ProjectItem p) {
    // overdue jika sudah lewat endDate dan belum complete
    if (p.endDate == null) return false;
    final today = DateTime.now();
    final end = DateTime(p.endDate!.year, p.endDate!.month, p.endDate!.day);
    final now = DateTime(today.year, today.month, today.day);
    return end.isBefore(now) && !_isComplete(p);
  }

  void _recompute(List<ProjectItem> list) {
    final total   = list.length;
    final done    = list.where(_isComplete).length;
    final overdue = list.where(_isOverdue).length;
    final incom   = total - done;

    totalProject.value    = total;
    totalComplete.value   = done;
    totalOverdue.value    = overdue;
    totalIncomplete.value = incom;
  }
}
