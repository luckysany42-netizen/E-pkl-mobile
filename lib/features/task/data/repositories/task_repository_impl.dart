import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

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
    required List<File> attachments,
    String? note,
  }) async {
    debugPrint('[TaskRepo] submitTask START taskId=$taskId, files=${attachments.length}');
    try {
      final formData = FormData();

      // PENTING: nama field HARUS 'attachments[]' (dengan tanda kurung
      // siku), bukan cuma 'attachments' -- ini konvensi standar PHP/Laravel
      // supaya banyak file dengan nama field sama dikumpulkan jadi array
      // di $request->file('attachments'). Tanpa '[]', PHP cuma akan
      // menyimpan file TERAKHIR (menimpa yang sebelumnya).
      for (final file in attachments) {
        debugPrint('[TaskRepo] adding file: ${file.path}, exists=${await file.exists()}');
        formData.files.add(
          MapEntry('attachments[]', await MultipartFile.fromFile(file.path)),
        );
      }

      if (note != null && note.trim().isNotEmpty) {
        formData.fields.add(MapEntry('submission_note', note.trim()));
      }

      debugPrint('[TaskRepo] sending POST to ${ApiEndpoints.taskSubmit(taskId.toString())}');
      final response = await _apiClient.dio.post(
        ApiEndpoints.taskSubmit(taskId.toString()),
        data: formData,
      );
      debugPrint('[TaskRepo] response received, status=${response.statusCode}');
      debugPrint('[TaskRepo] response body=${response.data}');

      final parsed = TaskModel.fromJson(response.data['data']);
      debugPrint('[TaskRepo] parsed OK, new status=${parsed.status}');
      return Result.success(parsed);
    } on DioException catch (e) {
      debugPrint('[TaskRepo] DioException: type=${e.type}, message=${e.message}');
      debugPrint('[TaskRepo] DioException response: ${e.response?.data}');
      return Result.failure(_extractErrorMessage(e));
    } catch (e, stack) {
      debugPrint('[TaskRepo] UNEXPECTED ERROR: $e');
      debugPrint('[TaskRepo] STACK: $stack');
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
