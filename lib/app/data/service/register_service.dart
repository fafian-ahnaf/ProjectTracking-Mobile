import 'package:dio/dio.dart';
import '../config/app_config.dart';

class RegisterService {
  late Dio _dio;

  RegisterService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Accept': 'application/json', // Wajib untuk Laravel
          'Content-Type': 'application/json',
        },
        // Agar status 422/400 tidak dianggap error crash oleh Dio
        validateStatus: (status) {
          return status! < 500;
        },
      ),
    );
  }

  Future<Map<String, dynamic>> register(
      String name, String email, String password, String confirmPassword) async {
    try {
      final response = await _dio.post(
        '/api/register', 
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': confirmPassword, // Sesuai validasi 'confirmed' Laravel
        },
      );

      final data = response.data;

      // 201 Created atau 200 OK
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Registrasi berhasil',
          'data': data,
        };
      } 
      // 422 Unprocessable Entity (Validasi Gagal)
      else if (response.statusCode == 422) {
        String message = 'Validasi gagal';
        
        if (data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          // Ambil pesan error pertama
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
          'message': 'Gagal register (${response.statusCode})',
        };
      }
    } on DioException catch (e) {
      // Handle masalah koneksi
      String errorMsg = 'Terjadi kesalahan koneksi';
      if (e.type == DioExceptionType.connectionTimeout) {
        errorMsg = 'Koneksi timeout. Cek internet kamu.';
      }
      return {
        'success': false,
        'message': errorMsg,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
}