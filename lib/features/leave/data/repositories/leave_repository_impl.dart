import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/result.dart';
import '../../domain/repositories/leave_repository.dart';
import '../models/leave_request_model.dart';

class LeaveRepositoryImpl implements LeaveRepository {
  final ApiClient _apiClient;

  LeaveRepositoryImpl(this._apiClient);

  @override
  Future<Result<List<LeaveRequestModel>>> getLeaveRequests() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.leaveRequests);
      final data = response.data['data'] as List<dynamic>;
      return Result.success(
        data
            .map((item) => LeaveRequestModel.fromJson(item))
            .toList(),
      );
    } on DioException catch (e) {
      return Result.failure(_errorMessage(e));
    } catch (e) {
      return Result.failure('Gagal memuat data izin: $e');
    }
  }

  @override
  Future<Result<LeaveRequestModel>> createLeaveRequest({
    required DateTime date,
    required String reasonType,
    String? note,
    File? attachment,
  }) async {
    try {
      final formData = FormData.fromMap({
        'date': _dateOnly(date),
        'reason_type': reasonType,
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
        if (attachment != null)
          'attachment': await MultipartFile.fromFile(
            attachment.path,
            filename: attachment.path.split(Platform.pathSeparator).last,
          ),
      });
      final response = await _apiClient.dio.post(
        ApiEndpoints.leaveRequests,
        data: formData,
      );
      return Result.success(
        LeaveRequestModel.fromJson(response.data['data']),
      );
    } on DioException catch (e) {
      return Result.failure(_errorMessage(e));
    } catch (e) {
      return Result.failure('Pengajuan izin gagal: $e');
    }
  }

  String _dateOnly(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  String _errorMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return 'Terjadi kesalahan: ${error.message}';
  }
}
