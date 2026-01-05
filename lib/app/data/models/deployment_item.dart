class DeploymentItem {
  int? id;
  int? projectId;
  String environment; // Development, Staging, Production
  String? version;    // v1.0.0
  String status;      // Planned, In Progress, Success, Failed
  String? pic;
  String? url;        // Link hasil deploy
  String? notes;
  DateTime? startDate; // API: start_at
  DateTime? endDate;   // API: end_at

  DeploymentItem({
    this.id,
    this.projectId,
    required this.environment,
    this.version,
    required this.status,
    this.pic,
    this.url,
    this.notes,
    this.startDate,
    this.endDate,
  });

  factory DeploymentItem.fromJson(Map<String, dynamic> json) {
    return DeploymentItem(
      id: json['id'],
      projectId: json['project_id'],
      environment: json['environment'] ?? 'Development',
      version: json['version'],
      status: json['status'] ?? 'Planned',
      pic: json['pic'],
      url: json['url'],
      notes: json['notes'],
      startDate: json['start_at'] != null ? DateTime.parse(json['start_at']) : null,
      endDate: json['end_at'] != null ? DateTime.parse(json['end_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'environment': environment,
      'version': version,
      'status': status,
      'pic': pic,
      'url': url,
      'notes': notes,
      'start_at': startDate?.toIso8601String().split('T')[0],
      'end_at': endDate?.toIso8601String().split('T')[0],
    };
  }

  // Helper copyWith
  DeploymentItem copyWith({
    String? environment,
    String? version,
    String? status,
    String? pic,
    String? url,
    String? notes,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return DeploymentItem(
      id: id,
      projectId: projectId,
      environment: environment ?? this.environment,
      version: version ?? this.version,
      status: status ?? this.status,
      pic: pic ?? this.pic,
      url: url ?? this.url,
      notes: notes ?? this.notes,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}