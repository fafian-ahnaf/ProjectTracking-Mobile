import 'package:get/get.dart';

/* ================= MODEL ================= */

class MaintenanceItem {
  final String title;
  final String status; // Planned, In Progress, Done
  final String? pic;
  final String? notes;
  final DateTime? startDate;
  final DateTime? endDate;

  MaintenanceItem({
    required this.title,
    required this.status,
    this.pic,
    this.notes,
    this.startDate,
    this.endDate,
  });

  MaintenanceItem copyWith({
    String? title,
    String? status,
    String? pic,
    String? notes,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return MaintenanceItem(
      title: title ?? this.title,
      status: status ?? this.status,
      pic: pic ?? this.pic,
      notes: notes ?? this.notes,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

/* ================= CONTROLLER ================= */

class MaintenanceController extends GetxController {
  MaintenanceController({required this.tagId});
  final String tagId;

  final items = <MaintenanceItem>[].obs;

  final statuses = ['Planned', 'In Progress', 'Done'];

  /* ============== ADD ============== */

  void add({
    required String title,
    required String status,
    String? pic,
    String? notes,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    items.add(
      MaintenanceItem(
        title: title,
        status: status,
        pic: pic,
        notes: notes,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  /* ============== UPDATE ============== */

  void updateAt(
    int index, {
    required String title,
    required String status,
    String? pic,
    String? notes,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    if (index < 0 || index >= items.length) return;

    items[index] = items[index].copyWith(
      title: title,
      status: status,
      pic: pic,
      notes: notes,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /* ============== REMOVE ============== */

  void removeAt(int index) {
    if (index < 0 || index >= items.length) return;
    items.removeAt(index);
  }
}
