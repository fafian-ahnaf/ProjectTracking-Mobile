import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../config/app_config.dart';

class PlanningService {
  late Dio _dio;
  final storage = GetStorage();

  PlanningService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        headers: {'Accept': 'application/json'},
        validateStatus: (status) => status! < 500,
      ),
    );
  }

  Options get _headers {
    final token = storage.read('token');
    return Options(headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'multipart/form-data',
    });
  }

  // GET: Ambil Data Planning (Note + Files)
  Future<Map<String, dynamic>> getPlanning(int projectId) async {
    final response = await _dio.get(
      '/api/projects/$projectId/planning',
      options: _headers,
    );
    return response.data;
  }

  // POST: Update Planning (Note, Activity, Upload Files)
  Future<Map<String, dynamic>> updatePlanning({
    required int projectId,
    String? note,
    String? activity,
    List<File>? newFiles,
  }) async {
    final formData = FormData();

    if (note != null) formData.fields.add(MapEntry('planning_note', note));
    if (activity != null) formData.fields.add(MapEntry('planning_activity', activity));

    // Upload Multiple Files
    if (newFiles != null && newFiles.isNotEmpty) {
      for (var file in newFiles) {
        formData.files.add(MapEntry(
          'files[]', // Sesuai validasi Laravel: files.*
          await MultipartFile.fromFile(file.path),
        ));
      }
    }

    final response = await _dio.post(
      '/api/projects/$projectId/planning',
      data: formData,
      options: _headers,
    );

    return {
      'status': response.statusCode,
      'data': response.data,
    };
  }

  // DELETE: Hapus File Planning
  Future<bool> deleteFile(int projectId, int fileId) async {
    final response = await _dio.delete(
      '/api/projects/$projectId/planning/files/$fileId',
      options: _headers,
    );
    return response.statusCode == 200;
  }
}