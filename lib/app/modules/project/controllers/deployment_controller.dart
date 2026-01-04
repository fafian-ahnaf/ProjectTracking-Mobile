// lib/app/modules/project_detail/controllers/deployment_controller.dart
import 'package:get/get.dart';

class DeploymentItem {
  final String title;
  final String? environment; // Dev / Staging / Production
  final String status;       // Planned / In Progress / Done
  final String? pic;         // Penanggung jawab
  final String? notes;       // Catatan singkat
  final DateTime? startDate; // Tanggal Mulai
  final DateTime? endDate;   // Tanggal Selesai

  DeploymentItem({
    required this.title,
    this.environment,
    required this.status,
    this.pic,
    this.notes,
    this.startDate,
    this.endDate,
  });

  DeploymentItem copyWith({
    String? title,
    String? environment,
    String? status,
    String? pic,
    String? notes,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return DeploymentItem(
      title: title ?? this.title,
      environment: environment ?? this.environment,
      status: status ?? this.status,
      pic: pic ?? this.pic,
      notes: notes ?? this.notes,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

class DeploymentController extends GetxController {
  DeploymentController({required this.tagId});

  final String tagId;

  final RxList<DeploymentItem> items = <DeploymentItem>[].obs;

  final List<String> statuses = const [
    'Planned',
    'In Progress',
    'Done',
  ];

  void add({
    required String title,
    String? environment,
    required String status,
    String? pic,
    String? notes,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    items.add(
      DeploymentItem(
        title: title,
        environment: environment,
        status: status,
        pic: pic,
        notes: notes,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  void updateAt(int index, DeploymentItem newItem) {
    if (index < 0 || index >= items.length) return;
    items[index] = newItem;
  }

  void removeAt(int index) {
    if (index < 0 || index >= items.length) return;
    items.removeAt(index);
  }
}
