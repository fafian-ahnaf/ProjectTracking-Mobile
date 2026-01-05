class DesignSpecItem {
  int? id;
  int? projectId;
  int requirementId;
  String? requirementTitle; // Dari relasi requirement.title
  String artifactType;      // UI, API, DB, Flow
  String artifactName;
  String? referenceUrl;
  String? rationale;
  String status;            // Draft, Review, Approved
  String? pic;
  DateTime? startDate;
  DateTime? endDate;

  DesignSpecItem({
    this.id,
    this.projectId,
    required this.requirementId,
    this.requirementTitle,
    required this.artifactType,
    required this.artifactName,
    this.referenceUrl,
    this.rationale,
    required this.status,
    this.pic,
    this.startDate,
    this.endDate,
  });

  factory DesignSpecItem.fromJson(Map<String, dynamic> json) {
    return DesignSpecItem(
      id: json['id'],
      projectId: json['project_id'],
      requirementId: json['requirement_id'],
      // Ambil judul requirement dari nested object (jika diload oleh API)
      requirementTitle: json['requirement']?['title'] ?? '-', 
      artifactType: json['artifact_type'] ?? 'UI',
      artifactName: json['artifact_name'] ?? '',
      referenceUrl: json['reference_url'],
      rationale: json['rationale'],
      status: json['status'] ?? 'Draft',
      pic: json['pic'],
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requirement_id': requirementId,
      'artifact_type': artifactType,
      'artifact_name': artifactName,
      'reference_url': referenceUrl,
      'rationale': rationale,
      'status': status,
      'pic': pic,
      'start_date': startDate?.toIso8601String().split('T')[0],
      'end_date': endDate?.toIso8601String().split('T')[0],
    };
  }
}