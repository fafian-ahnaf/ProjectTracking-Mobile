class DevelopmentItem {
  int? id;
  int? projectId;
  int designSpecId;
  
  // Data Relasi untuk Tampilan UI
  String designSpecName; // [Type] Name
  String requirementTitle;
  
  String? pic; // Developer Name
  String status; // In Progress, Review, Done
  DateTime? startDate;
  DateTime? endDate;

  DevelopmentItem({
    this.id,
    this.projectId,
    required this.designSpecId,
    this.designSpecName = '',
    this.requirementTitle = '',
    this.pic,
    required this.status,
    this.startDate,
    this.endDate,
  });

  factory DevelopmentItem.fromJson(Map<String, dynamic> json) {
    // Helper ambil data nested designSpec & requirement
    String dName = '-';
    String rTitle = '-';
    
    if (json['design_spec'] != null) {
      final d = json['design_spec'];
      dName = '[${d['artifact_type'] ?? '?'}] ${d['artifact_name'] ?? ''}';
      
      if (d['requirement'] != null) {
        rTitle = d['requirement']['title'] ?? '-';
      }
    }

    return DevelopmentItem(
      id: json['id'],
      projectId: json['project_id'],
      designSpecId: json['design_spec_id'],
      designSpecName: dName,
      requirementTitle: rTitle,
      pic: json['pic'],
      status: json['status'] ?? 'In Progress',
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'design_spec_id': designSpecId,
      'pic': pic,
      'status': status,
      'start_date': startDate?.toIso8601String().split('T')[0],
      'end_date': endDate?.toIso8601String().split('T')[0],
    };
  }
}