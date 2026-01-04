import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// ======================= MODEL =======================
class RequirementItem {
  final int id;
  final String title;
  final String type;        // FR / NFR / Bug / Change
  final String priority;    // Low / Medium / High / Critical
  final String status;      // Planned / In Progress / Done
  final String criteria;

  final String? pic;        // PIC requirement
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

/// ===================== CONTROLLER =====================
class RequirementController extends GetxController {
  /// input textfield
  final titleC = TextEditingController();
  final criteriaC = TextEditingController();

  /// dropdown state (TIDAK boleh null)
  final RxString type = 'FR'.obs;
  final RxString priority = 'Medium'.obs;
  final RxString status = 'Planned'.obs;

  /// daftar requirement + progress
  final RxList<RequirementItem> items = <RequirementItem>[].obs;
  final RxDouble progress = 0.0.obs; // 0..1

  int _autoId = 1;

  /// Simpan requirement baru
  void save({
    String? pic,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final t = titleC.text.trim();
    final c = criteriaC.text.trim();

    if (t.isEmpty) {
      // bisa kasih snackbar kalau mau
      // Get.snackbar('Validasi', 'Judul requirement tidak boleh kosong');
      return;
    }

    final item = RequirementItem(
      id: _autoId++,
      title: t,
      type: type.value,
      priority: priority.value,
      status: status.value,
      criteria: c,
      pic: (pic ?? '').trim().isEmpty ? null : pic!.trim(),
      startDate: startDate,
      endDate: endDate,
    );

    items.add(item);

    // reset textfield (dropdown biarin)
    titleC.clear();
    criteriaC.clear();

    _recalcProgress();
  }

  /// Hapus requirement
  void remove(int id) {
    items.removeWhere((e) => e.id == id);
    _recalcProgress();
  }

  /// Ubah status lalu hitung ulang progress
  void setStatus(int id, String newStatus) {
    final idx = items.indexWhere((e) => e.id == id);
    if (idx == -1) return;

    items[idx] = items[idx].copyWith(status: newStatus);
    _recalcProgress();
  }

  /// Hitung persentase requirement yg sudah Done
  void _recalcProgress() {
    if (items.isEmpty) {
      progress.value = 0;
      return;
    }
    final done = items
        .where((e) => e.status.toLowerCase().contains('done'))
        .length;
    progress.value = done / items.length;
  }

  @override
  void onClose() {
    titleC.dispose();
    criteriaC.dispose();
    super.onClose();
  }
}