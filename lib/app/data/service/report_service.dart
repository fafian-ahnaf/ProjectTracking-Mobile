import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart'; // Pastikan ada di pubspec
import 'package:get_storage/get_storage.dart';
import '../config/app_config.dart';

class ReportService {
  late Dio _dio;
  final storage = GetStorage();

  ReportService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        headers: {'Accept': 'application/json'},
      ),
    );
  }

  Options get _headers {
    final token = storage.read('token');
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  // Ambil Data Report (JSON)
  Future<Map<String, dynamic>> getReportData({DateTime? start, DateTime? end}) async {
    final Map<String, dynamic> query = {};
    if (start != null) query['start'] = start.toIso8601String().split('T')[0];
    if (end != null) query['end'] = end.toIso8601String().split('T')[0];

    final response = await _dio.get(
      '/api/reports',
      queryParameters: query,
      options: _headers,
    );
    return response.data;
  }

  // Download CSV
  Future<String?> downloadCsv({DateTime? start, DateTime? end}) async {
    final Map<String, dynamic> query = {'export': 'csv'};
    if (start != null) query['start'] = start.toIso8601String().split('T')[0];
    if (end != null) query['end'] = end.toIso8601String().split('T')[0];

    try {
      // Ambil direktori sementara
      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'report_${DateTime.now().millisecondsSinceEpoch}.csv';
      final savePath = '${dir.path}/$fileName';

      await _dio.download(
        '/api/reports',
        savePath,
        queryParameters: query,
        options: _headers,
      );
      
      return savePath;
    } catch (e) {
      print('Download error: $e');
      return null;
    }
  }
}