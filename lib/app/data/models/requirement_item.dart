class RequirementItem {
  int? id;
  int? projectId;
  String title;
  String type; // FR, NFR
  String priority; // Low, Medium, High
  String status; // Planned, In Progress, Done
  String? pic;
  DateTime? startDate;
  DateTime? endDate;
  String? acceptanceCriteria;

  RequirementItem({
    this.id,
    this.projectId,
    required this.title,
    required this.type,
    required this.priority,
    required this.status,
    this.pic,
    this.startDate,
    this.endDate,
    this.acceptanceCriteria,
  });

  factory RequirementItem.fromJson(Map<String, dynamic> json) {
    return RequirementItem(
      id: json['id'],
      projectId: json['project_id'],
      title: json['title'] ?? '',
      type: json['type'] ?? 'FR',
      priority: json['priority'] ?? 'Medium',
      status: json['status'] ?? 'Planned',
      pic: json['pic'],
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      acceptanceCriteria: json['acceptance_criteria'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'type': type,
      'priority': priority,
      'status': status,
      'pic': pic,
      'start_date': startDate?.toIso8601String().split('T')[0],
      'end_date': endDate?.toIso8601String().split('T')[0],
      'acceptance_criteria': acceptanceCriteria,
    };
  }
}