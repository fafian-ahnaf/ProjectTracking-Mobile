import '../config/app_config.dart'; // Pastikan import ini ada untuk akses BaseURL

class ProjectItem {
  int? id;
  String name;
  String pic;
  String status;
  DateTime? startDate;
  DateTime? endDate;

  int progress; // Progress manual (inputan user)
  int overallProgress; // Progress hitungan sistem (dari JSON overall_progress)
  Map<String, dynamic>? sdlcProgress; // Detail progress per fase

  String activity;
  String? documentPath; // URL file kontrak
  String? localFilePath;

  ProjectItem({
    this.id,
    required this.name,
    required this.pic,
    required this.status,
    this.startDate,
    this.endDate,
    this.progress = 0,
    this.overallProgress = 0, // Default 0
    this.sdlcProgress,
    this.activity = '',
    this.documentPath,
    this.localFilePath,
  });

  factory ProjectItem.fromJson(Map<String, dynamic> json) {
    return ProjectItem(
      id: json['id'],
      name: json['title'] ?? 'Tanpa Nama',
      pic: json['pic'] ?? '-',
      status: _mapStatusFromApi(json['status']),

      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : null,

      // Ambil progress manual & overall
      progress: json['progress'] ?? 0,
      overallProgress: json['overall_progress'] ?? 0,

      // Ambil detail SDLC (requirement, design, dll)
      sdlcProgress: json['sdlc_progress'],

      activity: json['activity'] ?? '',

      // Fix URL: Kalau cuma "/storage/..." kita gabung dengan BaseUrl
      documentPath: _fixUrl(json['contract_file_url']),
    );
  }

  static String? _fixUrl(String? url) {
    if (url == null) return null;
    if (url.startsWith('http')) return url;
    // Jika path relatif (misal: /storage/contracts/...), gabung dengan domain
    // Hapus slash di awal jika ada biar gak double slash
    final path = url.startsWith('/') ? url.substring(1) : url;
    return '${AppConfig.baseUrl}/$path';
  }

  static String _mapStatusFromApi(String? status) {
    switch (status) {
      case 'todo':
        return 'Belum Mulai';
      case 'in_progress':
        return 'In Progress';
      case 'review':
        return 'Review';
      case 'done':
        return 'Selesai';
      default:
        return 'Belum Mulai';
    }
  }
}


// Tambahkan class ini di file project_item.dart (paling bawah)

class ActivityItem {
  int? id;
  String title;
  String? description;
  String phase; // planning, requirement, dll
  DateTime? occurredAt;

  ActivityItem({
    this.id,
    required this.title,
    this.description,
    required this.phase,
    this.occurredAt,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      id: json['id'],
      title: json['title'] ?? '-',
      description: json['description'],
      phase: json['phase'] ?? 'general',
      occurredAt: json['occurred_at'] != null 
          ? DateTime.parse(json['occurred_at']) 
          : null,
    );
  }
}