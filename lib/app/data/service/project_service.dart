import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../config/app_config.dart';

class ProjectService {
  late Dio _dio;
  final storage = GetStorage();

  ProjectService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        headers: {'Accept': 'application/json'}, // Wajib buat Laravel
        // Trik: Izinkan status 422 (Validasi) lewat tanpa dianggap Error Exception
        validateStatus: (status) {
          return status! < 500;
        },
      ),
    );
  }

  // Helper headers
  Options get _headers {
    final token = storage.read('token');
    return Options(
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data',
      },
    );
  }

  // GET
  Future<List<dynamic>> getProjects() async {
    final response = await _dio.get('/api/projects', options: _headers);
    // Kalau 200 OK
    if (response.statusCode == 200) {
      return response.data['data'];
    }
    throw Exception('Gagal ambil data');
  }

  // POST (Create)
  Future<Map<String, dynamic>> createProject(
    Map<String, dynamic> data,
    File? file,
  ) async {
    final formData = FormData.fromMap(data);

    if (file != null) {
      // Pastikan path valid
      formData.files.add(
        MapEntry('contract_file', await MultipartFile.fromFile(file.path)),
      );
    }

    final response = await _dio.post(
      '/api/projects',
      data: formData,
      options: _headers,
    );

    return {'status': response.statusCode, 'data': response.data};
  }


  Future<Map<String, dynamic>> updateProject(
    int id,
    Map<String, dynamic> data,
    File? file,
  ) async {
    final formData = FormData.fromMap(data);

    if (file != null) {
      formData.files.add(
        MapEntry('contract_file', await MultipartFile.fromFile(file.path)),
      );
    }

    print("DEBUG: MENGIRIM REQUEST UPDATE MURNI POST KE: /api/projects/$id");

    final response = await _dio.post(
      '/api/projects/$id',
      data: formData,
      options: _headers,
    );

    return {'status': response.statusCode, 'data': response.data};
  }

  Future<void> deleteProject(int id) async {
    await _dio.delete('/api/projects/$id', options: _headers);
  }
}
