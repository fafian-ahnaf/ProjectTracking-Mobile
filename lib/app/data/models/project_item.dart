// lib/app/data/models/project_item.dart

class ProjectItem {
  final String name;
  final String pic;
  final String status; // Belum Mulai | In Progress | Review | Selesai
  final DateTime? startDate;
  final DateTime? endDate;
  final int progress; // 0..100
  final String documentPath; // sekarang TIDAK nullable → aman
  final String activity;      // TIDAK nullable → aman

  const ProjectItem({
    required this.name,
    required this.pic,
    required this.status,
    this.startDate,
    this.endDate,
    this.progress = 0,
    this.documentPath = '',
    this.activity = '',
  });

  ProjectItem copyWith({
    String? name,
    String? pic,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int? progress,
    String? documentPath,
    String? activity,
  }) {
    return ProjectItem(
      name: name ?? this.name,
      pic: pic ?? this.pic,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      progress: progress ?? this.progress,
      documentPath: documentPath ?? this.documentPath,
      activity: activity ?? this.activity,
    );
  }

  // ==============================
  //        JSON FACTORY
  // ==============================
  factory ProjectItem.fromJson(Map<String, dynamic> json) {
    String? rawStart = json['startDate'];
    String? rawEnd   = json['endDate'];

    return ProjectItem(
      name: json['name'] ?? '',
      pic: json['pic'] ?? '',
      status: json['status'] ?? 'Belum Mulai',

      startDate: (rawStart != null && rawStart.toString().isNotEmpty)
          ? DateTime.tryParse(rawStart)
          : null,

      endDate: (rawEnd != null && rawEnd.toString().isNotEmpty)
          ? DateTime.tryParse(rawEnd)
          : null,

      progress: (json['progress'] is int)
          ? json['progress']
          : int.tryParse('${json['progress'] ?? "0"}') ?? 0,

      documentPath: json['documentPath']?.toString() ?? '',
      activity: json['activity']?.toString() ?? '',
    );
  }

  // ==============================
  //            TO JSON
  // ==============================
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'pic': pic,
      'status': status,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'progress': progress,
      'documentPath': documentPath,
      'activity': activity,
    };
  }

  @override
  String toString() =>
      'ProjectItem(name: $name, pic: $pic, status: $status, progress: $progress)';
}
