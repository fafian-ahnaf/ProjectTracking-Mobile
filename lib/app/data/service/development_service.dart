import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../config/app_config.dart';

class DevelopmentService {
  late Dio _dio;
  final storage = GetStorage();

  DevelopmentService() {
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
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<List<dynamic>> getDevelopments(int projectId) async {
    final response = await _dio.get(
      '/api/projects/$projectId/developments',
      options: _headers,
    );
    return response.data['data'];
  }

  Future<Map<String, dynamic>> create(int projectId, Map<String, dynamic> data) async {
    final response = await _dio.post(
      '/api/projects/$projectId/developments',
      data: data,
      options: _headers,
    );
    return {'status': response.statusCode, 'data': response.data};
  }

  Future<Map<String, dynamic>> update(int projectId, int id, Map<String, dynamic> data) async {
    final response = await _dio.put(
      '/api/projects/$projectId/developments/$id',
      data: data,
      options: _headers,
    );
    return {'status': response.statusCode, 'data': response.data};
  }

  Future<bool> delete(int projectId, int id) async {
    final response = await _dio.delete(
      '/api/projects/$projectId/developments/$id',
      options: _headers,
    );
    return response.statusCode == 200;
  }
}