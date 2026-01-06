class MaintenanceItem {
  int? id;
  int? projectId;
  String title;
  String status; // Planned, In Progress, Resolved, Closed
  String? assignee;
  String? notes;
  DateTime? openedAt;
  DateTime? closedAt;
  int progressPercentage; // Dari backend

  MaintenanceItem({
    this.id,
    this.projectId,
    required this.title,
    required this.status,
    this.assignee,
    this.notes,
    this.openedAt,
    this.closedAt,
    this.progressPercentage = 0,
  });

  factory MaintenanceItem.fromJson(Map<String, dynamic> json) {
    return MaintenanceItem(
      id: json['id'],
      projectId: json['project_id'],
      title: json['title'] ?? '',
      status: json['status'] ?? 'Planned',
      assignee: json['assignee'],
      notes: json['notes'],
      openedAt: json['opened_at'] != null ? DateTime.parse(json['opened_at']) : null,
      closedAt: json['closed_at'] != null ? DateTime.parse(json['closed_at']) : null,
      progressPercentage: int.tryParse(json['progress_percentage'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'status': status,
      'assignee': assignee,
      'notes': notes,
      'opened_at': openedAt?.toIso8601String().split('T')[0],
      'closed_at': closedAt?.toIso8601String().split('T')[0],
    };
  }
}