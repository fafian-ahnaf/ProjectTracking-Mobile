import 'package:get/get.dart';

/// ================= MODEL =================
class TestCaseItem {
  final int id;
  final String title;
  final String status;
  final String? requirement;
  final String? designSpec;
  final String? tester;
  final String? scenario;
  final String? expectedResult;

  // ✅ TAMBAHAN
  final DateTime? startDate;
  final DateTime? endDate;

  TestCaseItem({
    required this.id,
    required this.title,
    required this.status,
    this.requirement,
    this.designSpec,
    this.tester,
    this.scenario,
    this.expectedResult,
    this.startDate,
    this.endDate,
  });

  TestCaseItem copyWith({
    int? id,
    String? title,
    String? status,
    String? requirement,
    String? designSpec,
    String? tester,
    String? scenario,
    String? expectedResult,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return TestCaseItem(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
      requirement: requirement ?? this.requirement,
      designSpec: designSpec ?? this.designSpec,
      tester: tester ?? this.tester,
      scenario: scenario ?? this.scenario,
      expectedResult: expectedResult ?? this.expectedResult,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

/// ================= CONTROLLER =================
class TestingController extends GetxController {
  TestingController({required this.tagId});

  final String tagId;

  /// daftar test case
  final RxList<TestCaseItem> items = <TestCaseItem>[].obs;

  /// status dropdown
  final List<String> statuses = const [
    'Planned',
    'In Progress',
    'Passed',
    'Failed',
  ];

  /// progress (Passed / total)
  final RxDouble progress = 0.0.obs;

  int _autoId = 0;

  /// ================= ADD =================
  void add({
    required String title,
    required String status,
    String? requirement,
    String? designSpec,
    String? tester,
    String? scenario,
    String? expectedResult,

    // ✅ TAMBAHAN
    DateTime? startDate,
    DateTime? endDate,
  }) {
    _autoId++;

    final item = TestCaseItem(
      id: _autoId,
      title: title,
      status: status,
      requirement: _normalize(requirement),
      designSpec: _normalize(designSpec),
      tester: _normalize(tester),
      scenario: _normalize(scenario),
      expectedResult: _normalize(expectedResult),
      startDate: startDate,
      endDate: endDate,
    );

    items.add(item);
    _recalcProgress();
  }

  /// ================= UPDATE =================
  void updateAt(int index, TestCaseItem value) {
    if (index < 0 || index >= items.length) return;
    items[index] = value;
    _recalcProgress();
  }

  /// ================= REMOVE =================
  void removeAt(int index) {
    if (index < 0 || index >= items.length) return;
    items.removeAt(index);
    _recalcProgress();
  }

  /// ================= SET STATUS =================
  void setStatus(int index, String status) {
    if (index < 0 || index >= items.length) return;
    final current = items[index];
    items[index] = current.copyWith(status: status);
    _recalcProgress();
  }

  /// ================= PROGRESS =================
  void _recalcProgress() {
    if (items.isEmpty) {
      progress.value = 0;
      return;
    }
    final passed = items.where((e) => e.status == 'Passed').length;
    progress.value = passed / items.length;
  }

  /// ================= HELPER =================
  String? _normalize(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    return v.trim();
  }
}
