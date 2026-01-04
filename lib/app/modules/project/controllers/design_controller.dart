import 'package:get/get.dart';

/// ======================= MODEL =======================
class DesignItem {
  final int id;
  final String requirement;
  final String type;         // UI / API / DB / dll
  final String artifactName; // nama komponen / endpoint / tabel
  final String status;       // Draft / In Progress / Done

  final String? reference;   // link figma/postman/erd
  final String? notes;       // catatan teknis
  final String? meta;        // meta kecil opsional
  final String? pic;         // PIC design

  final DateTime? startDate;
  final DateTime? endDate;

  DesignItem({
    required this.id,
    required this.requirement,
    required this.type,
    required this.artifactName,
    required this.status,
    this.reference,
    this.notes,
    this.meta,
    this.pic,
    this.startDate,
    this.endDate,
  });

  DesignItem copyWith({
    int? id,
    String? requirement,
    String? type,
    String? artifactName,
    String? status,
    String? reference,
    String? notes,
    String? meta,
    String? pic,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return DesignItem(
      id: id ?? this.id,
      requirement: requirement ?? this.requirement,
      type: type ?? this.type,
      artifactName: artifactName ?? this.artifactName,
      status: status ?? this.status,
      reference: reference ?? this.reference,
      notes: notes ?? this.notes,
      meta: meta ?? this.meta,
      pic: pic ?? this.pic,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

/// ===================== CONTROLLER =====================
class DesignController extends GetxController {
  DesignController({required this.tagId});

  final String tagId;

  /// daftar design spec
  final RxList<DesignItem> items = <DesignItem>[].obs;

  /// progress 0..1 (dibaca di UI)
  final RxDouble progress = 0.0.obs;

  /// dropdown list
  final List<String> types = const [
    'UI',
    'API',
    'DB',
    'Flow',
    'Other',
  ];

  /// status utama yg dipakai progress
  final List<String> statuses = const [
    'Planned',
    'In Progress',
    'Done',
  ];

  int _autoId = 1;

  /// Tambah design baru
  void add({
    required String requirement,
    required String type,
    required String artifactName,
    required String status,
    String? reference,
    String? notes,
    String? meta,
    String? pic,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final item = DesignItem(
      id: _autoId++,
      requirement: requirement,
      type: type,
      artifactName: artifactName,
      status: status,
      reference: reference,
      notes: notes,
      meta: meta,
      pic: pic,
      startDate: startDate,
      endDate: endDate,
    );

    items.add(item);
    _recalcProgress();
  }

  /// Hapus baris berdasarkan index (dipakai di icon delete)
  void removeAt(int index) {
    if (index < 0 || index >= items.length) return;
    items.removeAt(index);
    _recalcProgress();
  }

  /// Kalau nanti mau ubah status dari tabel
  void setStatus(int id, String newStatus) {
    final idx = items.indexWhere((e) => e.id == id);
    if (idx == -1) return;

    items[idx] = items[idx].copyWith(status: newStatus);
    _recalcProgress();
  }

  /// Hitung progress berdasarkan status Draft / In Progress / Done
  void _recalcProgress() {
    if (items.isEmpty) {
      progress.value = 0;
      return;
    }

    double sum = 0;
    for (final e in items) {
      final s = e.status.toLowerCase();

      if (s.contains('Planned')) {
        sum += 0.0;
      } else if (s.contains('in progress') || s.contains('progress')) {
        sum += 0.5;
      } else if (s.contains('done') || s.contains('completed')) {
        sum += 1.0;
      } else {
        // status lain dianggap tengah-tengah
        sum += 0.5;
      }
    }

    progress.value = (sum / items.length).clamp(0.0, 1.0);
  }
}
