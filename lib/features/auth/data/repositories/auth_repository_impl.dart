import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/result.dart';
import '../../../../core/utils/storage_helper.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;

  AuthRepositoryImpl(this._apiClient);

  @override
  Future<Result<({UserModel user, String token})>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      final data = response.data;

      // Backend AuthController::login() bisa balikin status:false dengan
      // HTTP 200 (bukan 401) untuk kasus "Email / Password salah", jadi
      // dicek manual di sini, tidak cukup andalkan status code Dio.
      if (data['status'] != true || data['token'] == null) {
        return Result.failure(data['message'] ?? 'Email / Password salah');
      }

      // Catatan: backend juga punya jalur login akun Landing (source:'landing')
      // yang tidak relevan untuk app intern ini, jadi diabaikan / dianggap gagal.
      if (data['source'] == 'landing') {
        return Result.failure(
          'Akun ini terdaftar di sistem Landing, bukan akun intern E-PKL.',
        );
      }

      final user = UserModel.fromJson(data['user']);
      final token = data['token'] as String;

      await StorageHelper.saveToken(token);

      return Result.success((user: user, token: token));
    } on DioException catch (e) {
      return Result.failure(_extractErrorMessage(e));
    } catch (e) {
      return Result.failure('Terjadi kesalahan tidak terduga: $e');
    }
  }

  @override
  Future<Result<({UserModel user, String token})>> register({
    required String name,
    required String email,
    String? phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.register,
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      final data = response.data;

      if (data['status'] != true || data['token'] == null) {
        return Result.failure(data['message'] ?? 'Registrasi gagal');
      }

      final user = UserModel.fromJson(data['user']);
      final token = data['token'] as String;

      await StorageHelper.saveToken(token);

      return Result.success((user: user, token: token));
    } on DioException catch (e) {
      return Result.failure(_extractErrorMessage(e));
    } catch (e) {
      return Result.failure('Terjadi kesalahan tidak terduga: $e');
    }
  }

  @override
  Future<Result<UserModel>> getMe() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.me);
      final user = UserModel.fromJson(response.data['user']);
      return Result.success(user);
    } on DioException catch (e) {
      return Result.failure(_extractErrorMessage(e));
    } catch (e) {
      return Result.failure('Terjadi kesalahan tidak terduga: $e');
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _apiClient.dio.delete(ApiEndpoints.logout);
    } on DioException catch (_) {
      // Sengaja diabaikan: walau request logout ke server gagal (misal token
      // sudah expired duluan), token lokal tetap harus dihapus di bawah ini
      // supaya user tetap bisa "logout" dari sisi app.
    } finally {
      await StorageHelper.clearToken();
    }
    return Result.success(null);
  }

  String _extractErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Koneksi ke server timeout. Cek koneksi internet / IP server.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Tidak bisa terhubung ke server. Pastikan HP & laptop di WiFi yang sama, dan server Laravel sedang jalan.';
    }
    return 'Terjadi kesalahan: ${e.message}';
  }
}
