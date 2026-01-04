import 'package:get/get.dart';

/// ======================= MODEL =======================
class DevelopmentItem {
  final int id;
  final String requirement;  // judul requirement
  final String designSpec;   // label design spec (misal: [API] Login — link)
  final String developer;    // nama developer
  final String status;       // Planned / In Progress / Done

  final String? pic;         // PIC dev (opsional, bisa sama dg developer)
  final String? meta;        // catatan kecil / meta (kalau mau dipakai)
  final DateTime? startDate;
  final DateTime? endDate;

  DevelopmentItem({
    required this.id,
    required this.requirement,
    required this.designSpec,
    required this.developer,
    required this.status,
    this.pic,
    this.meta,
    this.startDate,
    this.endDate,
  });

  DevelopmentItem copyWith({
    int? id,
    String? requirement,
    String? designSpec,
    String? developer,
    String? status,
    String? pic,
    String? meta,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return DevelopmentItem(
      id: id ?? this.id,
      requirement: requirement ?? this.requirement,
      designSpec: designSpec ?? this.designSpec,
      developer: developer ?? this.developer,
      status: status ?? this.status,
      pic: pic ?? this.pic,
      meta: meta ?? this.meta,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

/// ===================== CONTROLLER =====================
class DevelopmentController extends GetxController {
  DevelopmentController({required this.tagId});

  final String tagId;

  /// daftar task development
  final RxList<DevelopmentItem> items = <DevelopmentItem>[].obs;

  /// progress 0..1 (dibaca di UI)
  ///
  /// Bobot:
  /// - Planned     = 0
  /// - In Progress = 0.5
  /// - Done        = 1
  final RxDouble progress = 0.0.obs;

  /// status yang dipakai dropdown & perhitungan progress
  final List<String> statuses = const [
    'Planned',
    'In Progress',
    'Done',
  ];

  int _autoId = 1;

  /// Tambah task baru
  void add({
    required String requirement,
    required String designSpec,
    required String developer,
    required String status,
    String? pic,
    String? meta,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final item = DevelopmentItem(
      id: _autoId++,
      requirement: requirement,
      designSpec: designSpec,
      developer: developer,
      status: status,
      pic: pic,
      meta: meta,
      startDate: startDate,
      endDate: endDate,
    );

    items.add(item);
    _recalcProgress();
  }

  /// Update task berdasarkan index (dipakai saat Edit)
  void updateAt(int index, DevelopmentItem newItem) {
    if (index < 0 || index >= items.length) return;
    items[index] = newItem;
    _recalcProgress();
  }

  /// Hapus task berdasarkan index
  void removeAt(int index) {
    if (index < 0 || index >= items.length) return;
    items.removeAt(index);
    _recalcProgress();
  }

  /// Kalau nanti mau ubah status berdasarkan id
  void setStatus(int id, String newStatus) {
    final idx = items.indexWhere((e) => e.id == id);
    if (idx == -1) return;

    items[idx] = items[idx].copyWith(status: newStatus);
    _recalcProgress();
  }

  /// Hitung progress berdasarkan status Planned / In Progress / Done
  void _recalcProgress() {
    if (items.isEmpty) {
      progress.value = 0;
      return;
    }

    double sum = 0;
    for (final e in items) {
      final s = e.status.toLowerCase();

      if (s.contains('planned')) {
        sum += 0.0;            // Planned
      } else if (s.contains('in progress') || s.contains('progress')) {
        sum += 0.5;            // In Progress
      } else if (s.contains('done') || s.contains('completed')) {
        sum += 1.0;            // Done
      } else {
        // status lain di-treat tengah
        sum += 0.5;
      }
    }

    progress.value = (sum / items.length).clamp(0.0, 1.0);
  }
}
