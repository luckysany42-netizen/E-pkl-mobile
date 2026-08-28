import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/result.dart';
import '../../domain/repositories/task_repository.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final ApiClient _apiClient;

  TaskRepositoryImpl(this._apiClient);

  @override
  Future<Result<List<TaskModel>>> getTasks() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.internTasks);
      final List raw = response.data['data'] ?? [];
      final list = raw.map((e) => TaskModel.fromJson(e)).toList();
      return Result.success(list);
    } on DioException catch (e) {
      return Result.failure(_extractErrorMessage(e));
    } catch (e) {
      return Result.failure('Terjadi kesalahan tidak terduga: $e');
    }
  }

  @override
  Future<Result<TaskModel>> updateStatus({
    required int taskId,
    required String status,
  }) async {
    try {
      final response = await _apiClient.dio.patch(
        ApiEndpoints.taskStatus(taskId.toString()),
        data: {'status': status},
      );
      return Result.success(TaskModel.fromJson(response.data['data']));
    } on DioException catch (e) {
      return Result.failure(_extractErrorMessage(e));
    } catch (e) {
      return Result.failure('Terjadi kesalahan tidak terduga: $e');
    }
  }

  @override
  Future<Result<TaskModel>> submitTask({
    required int taskId,
    required File attachment,
    String? note,
  }) async {
    try {
      final formData = FormData.fromMap({
        'attachment': await MultipartFile.fromFile(attachment.path),
        if (note != null && note.trim().isNotEmpty) 'submission_note': note.trim(),
      });

      final response = await _apiClient.dio.post(
        ApiEndpoints.taskSubmit(taskId.toString()),
        data: formData,
      );

      return Result.success(TaskModel.fromJson(response.data['data']));
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
