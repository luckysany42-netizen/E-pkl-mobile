import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/result.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../models/attendance_model.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final ApiClient _apiClient;

  AttendanceRepositoryImpl(this._apiClient);

  @override
  Future<Result<List<AttendanceModel>>> getHistory() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.attendances);
      final List raw = response.data['data'] ?? [];
      final list = raw.map((e) => AttendanceModel.fromJson(e)).toList();
      return Result.success(list);
    } on DioException catch (e) {
      return Result.failure(_extractErrorMessage(e));
    } catch (e) {
      return Result.failure('Terjadi kesalahan tidak terduga: $e');
    }
  }

  @override
  Future<Result<AttendanceModel?>> getToday() async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiEndpoints.attendances}/today',
      );
      final data = response.data['data'];
      if (data == null) return Result.success(null);
      return Result.success(AttendanceModel.fromJson(data));
    } on DioException catch (e) {
      return Result.failure(_extractErrorMessage(e));
    } catch (e) {
      return Result.failure('Terjadi kesalahan tidak terduga: $e');
    }
  }

  @override
  Future<Result<AttendanceModel>> checkIn({
    required File photo,
    String? location,
  }) async {
    try {
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(photo.path, filename: 'checkin.jpg'),
        if (location != null) 'location': location,
      });

      final response = await _apiClient.dio.post(
        '${ApiEndpoints.attendances}/check-in',
        data: formData,
      );

      return Result.success(AttendanceModel.fromJson(response.data['data']));
    } on DioException catch (e) {
      return Result.failure(_extractErrorMessage(e));
    } catch (e) {
      return Result.failure('Terjadi kesalahan tidak terduga: $e');
    }
  }

  @override
  Future<Result<AttendanceModel>> checkOut({required String base64Photo}) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiEndpoints.attendances}/check-out',
        data: {'photo': base64Photo},
      );

      return Result.success(AttendanceModel.fromJson(response.data['data']));
    } on DioException catch (e) {
      return Result.failure(_extractErrorMessage(e));
    } catch (e) {
      return Result.failure('Terjadi kesalahan tidak terduga: $e');
    }
  }

  String _extractErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Tidak bisa terhubung ke server.';
    }
    return 'Terjadi kesalahan: ${e.message}';
  }
}
