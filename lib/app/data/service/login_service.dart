import 'package:dio/dio.dart';
import '../config/app_config.dart';

class LoginService {
  late Dio _dio;

  LoginService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10), // Timeout 10 detik
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Accept': 'application/json', // Wajib untuk Laravel
          'Content-Type': 'application/json',
        },
        // Validasi status agar Dio tidak throw error untuk 400/401/422
        // Kita handle manual response-nya
        validateStatus: (status) {
          return status! < 500; 
        },
      ),
    );
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/api/login', // Endpoint (dio otomatis gabung dengan baseUrl)
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data;

      // Cek Status Code
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
        };
      } 
      // Handle Validasi Laravel (Error 422) atau Login Gagal (401)
      else if (response.statusCode == 422 || response.statusCode == 401) {
        String message = data['message'] ?? 'Login gagal';
        
        // Jika ada detail error validasi dari Laravel
        if (data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          // Ambil error pertama yang ditemukan
          message = errors.values.first[0];
        }

        return {
          'success': false,
          'message': message,
        };
      } 
      else {
        return {
          'success': false,
          'message': 'Terjadi kesalahan server (${response.statusCode})',
        };
      }
    } on DioException catch (e) {
      // Handle Error Koneksi (Timeout, No Internet, dll)
      String errorMsg = 'Terjadi kesalahan koneksi';
      
      if (e.type == DioExceptionType.connectionTimeout) {
        errorMsg = 'Koneksi timeout. Cek internet kamu.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMsg = 'Tidak dapat terhubung ke server.';
      }

      return {
        'success': false,
        'message': errorMsg,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error tidak diketahui: $e',
      };
    }
  }
}