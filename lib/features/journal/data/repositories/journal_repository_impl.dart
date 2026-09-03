import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
  Future<Result<List<DateTime>>> getDatesTaken() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.journalDatesTaken);
      final List raw = response.data['data'] ?? [];
      final dates = raw
          .map((e) => DateTime.tryParse(e.toString()))
          .whereType<DateTime>()
          .toList();
      return Result.success(dates);
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
    debugPrint('[JournalRepo] create() START date=$date, activities=${activities.length}, foto=${foto?.path}');
    try {
      if (foto != null) {
        final exists = await foto.exists();
        debugPrint('[JournalRepo] foto exists=$exists, path=${foto.path}');
      }

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

      debugPrint('[JournalRepo] sending POST to ${ApiEndpoints.journals}');
      final response = await _apiClient.dio.post(
        ApiEndpoints.journals,
        data: formData,
      );
      debugPrint('[JournalRepo] response received, status=${response.statusCode}');
      debugPrint('[JournalRepo] response body=${response.data}');

      final parsed = JournalModel.fromJson(response.data['data']);
      debugPrint('[JournalRepo] create() SUKSES, journal id=${parsed.id}');
      return Result.success(parsed);
    } on DioException catch (e) {
      debugPrint('[JournalRepo] DioException: type=${e.type}, message=${e.message}');
      debugPrint('[JournalRepo] DioException response: ${e.response?.data}');
      return Result.failure(_extractErrorMessage(e));
    } catch (e, stack) {
      debugPrint('[JournalRepo] UNEXPECTED ERROR: $e');
      debugPrint('[JournalRepo] STACK: $stack');
      return Result.failure('Terjadi kesalahan tidak terduga: $e');
    }
  }

  @override
  Future<Result<JournalModel>> update({
    required int journalId,
    required List<JournalActivityModel> activities,
    File? foto,
  }) async {
    debugPrint('[JournalRepo] update() START journalId=$journalId, activities=${activities.length}, foto=${foto?.path}');
    try {
      if (foto != null) {
        final exists = await foto.exists();
        debugPrint('[JournalRepo] foto exists=$exists, path=${foto.path}');
      }

      final formData = FormData.fromMap({
        // Laravel method spoofing: PUT dengan body multipart tidak didukung
        // baik oleh sebagian besar HTTP client (termasuk Dio), jadi request
        // dikirim sebagai POST dengan field '_method'='PUT'. Laravel
        // otomatis mendeteksi ini via middleware bawaan dan memprosesnya
        // sebagai request PUT asli.
        '_method': 'PUT',
        'activities': activities.map((a) => a.toJson()).toList(),
        if (foto != null)
          'foto': await MultipartFile.fromFile(foto.path, filename: 'journal.jpg'),
      });

      debugPrint('[JournalRepo] sending POST(spoofed PUT) to ${ApiEndpoints.journalUpdate(journalId.toString())}');
      final response = await _apiClient.dio.post(
        ApiEndpoints.journalUpdate(journalId.toString()),
        data: formData,
      );
      debugPrint('[JournalRepo] response received, status=${response.statusCode}');
      debugPrint('[JournalRepo] response body=${response.data}');

      final parsed = JournalModel.fromJson(response.data['data']);
      debugPrint('[JournalRepo] update() SUKSES, journal id=${parsed.id}, status=${parsed.status}');
      return Result.success(parsed);
    } on DioException catch (e) {
      debugPrint('[JournalRepo] DioException: type=${e.type}, message=${e.message}');
      debugPrint('[JournalRepo] DioException response: ${e.response?.data}');
      return Result.failure(_extractErrorMessage(e));
    } catch (e, stack) {
      debugPrint('[JournalRepo] UNEXPECTED ERROR: $e');
      debugPrint('[JournalRepo] STACK: $stack');
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
