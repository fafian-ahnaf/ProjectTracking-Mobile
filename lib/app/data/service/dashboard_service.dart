import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../config/app_config.dart';

class DashboardService {
  late Dio _dio;
  final storage = GetStorage();

  DashboardService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // Ambil token dari storage
      final token = storage.read('token');

      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan, silakan login ulang.',
        };
      }

      final response = await _dio.get(
        '/api/dashboard-stats', // Endpoint sesuai controller Laravel kamu
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // Kirim Token di sini
          },
        ),
      );

      final data = response.data;

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data['data'], // Masuk ke key 'data' dari response Laravel
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal memuat data (${response.statusCode})',
        };
      }
    } on DioException catch (e) {
      // Handle jika token expired (401)
      if (e.response?.statusCode == 401) {
        return {
          'success': false,
          'message': 'Sesi habis, silakan login kembali.',
          'needLogin': true, 
        };
      }
      return {
        'success': false,
        'message': 'Koneksi error: ${e.message}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
}