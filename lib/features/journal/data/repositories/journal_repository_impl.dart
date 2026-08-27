import 'dart:io';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/result.dart';
import '../../domain/repositories/journal_repository.dart';
import '../models/journal_activity_model.dart';
import '../models/journal_model.dart';

class JournalRepositoryImpl implements JournalRepository {
  final ApiClient _apiClient;

  JournalRepositoryImpl(this._apiClient);

  @override
  Future<Result<List<JournalModel>>> getHistory() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.journalHistory);
      final List raw = response.data['data'] ?? [];
      final list = raw.map((e) => JournalModel.fromJson(e)).toList();
      return Result.success(list);
    } on DioException catch (e) {
      return Result.failure(_extractErrorMessage(e));
    } catch (e) {
      return Result.failure('Terjadi kesalahan tidak terduga: $e');
    }
  }

  @override
  Future<Result<JournalModel>> create({
    required DateTime date,
    required List<JournalActivityModel> activities,
    File? foto,
  }) async {
    try {
      final formData = FormData.fromMap({
        'date': DateFormat('yyyy-MM-dd').format(date),
        // Backend nunggu format array standar Laravel:
        // activities[0][jam_mulai], activities[0][kegiatan], dst.
        // Dio otomatis nge-generate ini kalau kita kirim List<Map> lewat
        // FormData.fromMap dengan key 'activities'.
        'activities': activities.map((a) => a.toJson()).toList(),
        if (foto != null)
          'foto': await MultipartFile.fromFile(foto.path, filename: 'journal.jpg'),
      });

      final response = await _apiClient.dio.post(
        ApiEndpoints.journals,
        data: formData,
      );

      return Result.success(JournalModel.fromJson(response.data['data']));
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
