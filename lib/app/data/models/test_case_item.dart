class TestCaseItem {
  int? id;
  int? projectId;
  
  // Relasi (Nullable)
  int? requirementId;
  String? requirementName; // Helper dari relasi requirement.title
  int? designSpecId;
  String? designSpecName; // Helper dari relasi designSpec.artifact_name
  
  String title;
  String? scenario;
  String? expectedResult;
  String? tester;
  String status; // Planned, In Progress, Passed, Failed
  DateTime? startDate; // API: start_at
  DateTime? endDate;   // API: end_at

  TestCaseItem({
    this.id,
    this.projectId,
    this.requirementId,
    this.requirementName,
    this.designSpecId,
    this.designSpecName,
    required this.title,
    this.scenario,
    this.expectedResult,
    this.tester,
    required this.status,
    this.startDate,
    this.endDate,
  });

  factory TestCaseItem.fromJson(Map<String, dynamic> json) {
    String? reqName;
    if (json['requirement'] != null) {
      reqName = json['requirement']['title'];
    }

    String? designName;
    if (json['design_spec'] != null) {
      designName = '[${json['design_spec']['artifact_type'] ?? '?'}] ${json['design_spec']['artifact_name'] ?? '-'}';
    }

    return TestCaseItem(
      id: json['id'],
      projectId: json['project_id'],
      requirementId: json['requirement_id'],
      requirementName: reqName,
      designSpecId: json['design_spec_id'],
      designSpecName: designName,
      title: json['title'] ?? '',
      scenario: json['scenario'],
      expectedResult: json['expected_result'],
      tester: json['tester'],
      status: json['status'] ?? 'Planned',
      // Mapping start_at -> startDate
      startDate: json['start_at'] != null ? DateTime.parse(json['start_at']) : null,
      endDate: json['end_at'] != null ? DateTime.parse(json['end_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requirement_id': requirementId,
      'design_spec_id': designSpecId,
      'title': title,
      'scenario': scenario,
      'expected_result': expectedResult,
      'tester': tester,
      'status': status,
      // Mapping startDate -> start_at untuk dikirim ke API
      'start_at': startDate?.toIso8601String().split('T')[0],
      'end_at': endDate?.toIso8601String().split('T')[0],
    };
  }
  
  // Helper copyWith untuk update state lokal
  TestCaseItem copyWith({
    String? title,
    String? status,
    int? requirementId,
    int? designSpecId,
    String? tester,
    String? scenario,
    String? expectedResult,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return TestCaseItem(
      id: id,
      projectId: projectId,
      requirementId: requirementId ?? this.requirementId,
      requirementName: requirementName, // Keep old name
      designSpecId: designSpecId ?? this.designSpecId,
      designSpecName: designSpecName,   // Keep old name
      title: title ?? this.title,
      scenario: scenario ?? this.scenario,
      expectedResult: expectedResult ?? this.expectedResult,
      tester: tester ?? this.tester,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}