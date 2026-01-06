import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../config/app_config.dart';

class RequirementService {
  late Dio _dio;
  final storage = GetStorage();

  RequirementService() {
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
    });
  }

  // GET ALL
  Future<List<dynamic>> getRequirements(int projectId) async {
    final response = await _dio.get(
      '/api/projects/$projectId/requirements',
      options: _headers,
    );
    return response.data['data'];
  }

  // CREATE
  Future<Map<String, dynamic>> createRequirement(int projectId, Map<String, dynamic> data) async {
    final response = await _dio.post(
      '/api/projects/$projectId/requirements',
      data: data,
      options: _headers,
    );
    return {'status': response.statusCode, 'data': response.data};
  }

  // UPDATE
  Future<Map<String, dynamic>> updateRequirement(int projectId, int reqId, Map<String, dynamic> data) async {
    final response = await _dio.put(
      '/api/projects/$projectId/requirements/$reqId',
      data: data,
      options: _headers,
    );
    return {'status': response.statusCode, 'data': response.data};
  }

  // DELETE
  Future<bool> deleteRequirement(int projectId, int reqId) async {
    final response = await _dio.delete(
      '/api/projects/$projectId/requirements/$reqId',
      options: _headers,
    );
    return response.statusCode == 200;
  }
}