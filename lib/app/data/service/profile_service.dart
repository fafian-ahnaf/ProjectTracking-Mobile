import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../config/app_config.dart';

class ProfileService {
  late Dio _dio;
  final storage = GetStorage();

  ProfileService() {
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

  // GET Profile
  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get('/api/profile', options: _headers);
    return response.data; // { status: true, data: { ... } }
  }

  // UPDATE Profile (Nama, Email, Password)
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await _dio.put(
      '/api/profile',
      data: data,
      options: _headers,
    );
    return {
      'status': response.statusCode,
      'body': response.data,
    };
  }
}