import 'package:flutter/material.dart';
import 'package:get/get.dart';

// kalau pakai timeline, impor ini.
// kalau tidak pakai timeline, aman dihapus saja import-nya.
import 'timeline_controller.dart';

/// =================================================
/// MODEL
/// =================================================
class RequirementItem {
  final int id;
  final String title;
  final String type;        // FR / NFR / Bug / Change
  final String priority;    // Low / Medium / High / Critical
  final String status;      // Planned / In Progress / Done
  final String criteria;

  final String? pic;
  final DateTime? startDate;
  final DateTime? endDate;

  RequirementItem({
    required this.id,
    required this.title,
    required this.type,
    required this.priority,
    required this.status,
    required this.criteria,
    this.pic,
    this.startDate,
    this.endDate,
  });

  RequirementItem copyWith({
    int? id,
    String? title,
    String? type,
    String? priority,
    String? status,
    String? criteria,
    String? pic,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return RequirementItem(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      criteria: criteria ?? this.criteria,
      pic: pic ?? this.pic,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

/// =================================================
/// CONTROLLER
/// =================================================
class RequirementController extends GetxController {
  RequirementController({this.timelineTag});

  /// Tag untuk TimelineController
  final String? timelineTag;

  /// Input field
  final titleC = TextEditingController();
  final criteriaC = TextEditingController();

  /// Dropdown state
  final RxString type = 'FR'.obs;
  final RxString priority = 'Medium'.obs;
  final RxString status = 'Planned'.obs;

  /// Data list + progress
  final RxList<RequirementItem> items = <RequirementItem>[].obs;
  final RxDouble progress = 0.0.obs;

  int _autoId = 1;

  /// ===============================
  /// LOG AKTIVITAS (opsional)
  /// ===============================
  void _logActivity(String message) {
    if (timelineTag == null) return;

    if (Get.isRegistered<TimelineController>(tag: timelineTag)) {
      final t = Get.find<TimelineController>(tag: timelineTag);
      t.add(message);
    }
  }

  /// ===============================
  /// SIMPAN REQUIREMENT
  /// ===============================
  void save({
    String? pic,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final title = titleC.text.trim();
    final criteria = criteriaC.text.trim();

    if (title.isEmpty) return;

    final item = RequirementItem(
      id: _autoId++,
      title: title,
      type: type.value,
      priority: priority.value,
      status: status.value,
      criteria: criteria,
      pic: (pic ?? '').trim().isEmpty ? null : pic!.trim(),
      startDate: startDate,
      endDate: endDate,
    );

    items.add(item);

    _logActivity("Requirement '$title' dibuat");

    titleC.clear();
    criteriaC.clear();

    _recalcProgress();
  }

  /// ===============================
  /// HAPUS
  /// ===============================
  void remove(int id) {
    RequirementItem? removed =
        items.firstWhereOrNull((e) => e.id == id);

    items.removeWhere((e) => e.id == id);

    if (removed != null) {
      _logActivity("Requirement '${removed.title}' dihapus");
    }

    _recalcProgress();
  }

  /// ===============================
  /// UBAH STATUS
  /// ===============================
  void setStatus(int id, String newStatus) {
    final idx = items.indexWhere((e) => e.id == id);
    if (idx == -1) return;

    final old = items[idx];
    items[idx] = old.copyWith(status: newStatus);

    _logActivity(
      "Status '${old.title}' diubah dari ${old.status} → $newStatus",
    );

    _recalcProgress();
  }

  /// ===============================
  /// HITUNG PROGRESS OTOMATIS
  /// ===============================
  void _recalcProgress() {
    if (items.isEmpty) {
      progress.value = 0;
      return;
    }

    double total = 0;

    for (final e in items) {
      final s = e.status.toLowerCase();

      if (s.contains('done')) {
        total += 1;
      } else if (s.contains('progress')) {
        total += 0.5;
      }
    }

    progress.value = total / items.length;
  }

  @override
  void onClose() {
    titleC.dispose();
    criteriaC.dispose();
    super.onClose();
  }
}
