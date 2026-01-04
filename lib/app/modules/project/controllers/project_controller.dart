import 'package:get/get.dart';
import 'package:project_tracking/app/data/models/project_item.dart';

class ProjectController extends GetxController {
  /// Daftar semua project (reaktif)
  final projects = <ProjectItem>[].obs;

  /// Statistik ringkas
  int get total => projects.length;
  int get inProgress => projects.where((e) => e.status == 'In Progress').length;
  int get review => projects.where((e) => e.status == 'Review').length;
  int get done => projects.where((e) => e.status == 'Selesai').length;

  /// Tambah project baru
  void add(ProjectItem item) {
    projects.add(item);
  }

  /// Hapus project berdasarkan index
  void removeAt(int index) {
    if (index >= 0 && index < projects.length) {
      projects.removeAt(index);
    }
  }

  /// Update data project berdasarkan index
  void updateAt(int index, ProjectItem updated) {
    if (index >= 0 && index < projects.length) {
      projects[index] = updated;
      projects.refresh(); // supaya UI auto-update
    }
  }

  /// Optional: reset seluruh data project
  void clearAll() {
    projects.clear();
  }

  /// Optional: contoh dummy data awal (buat testing)
  @override
  void onInit() {
    super.onInit();
    // kamu bisa aktifkan baris di bawah saat testing:
    // projects.addAll([
    //   ProjectItem(name: 'ERP Cafe Canary', pic: 'Rani', status: 'Belum Mulai', progress: 0),
    //   ProjectItem(name: 'TrampoTrack Mobile', pic: 'Dika', status: 'In Progress', progress: 40),
    // ]);
  }
}
