import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/result.dart';
import '../../../auth/data/models/user_model.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ApiClient _apiClient;

  ProfileRepositoryImpl(this._apiClient);

  @override
  Future<Result<UserModel>> updateProfile({
    required UserModel currentUser,
    required String name,
    required String phone,
    required String nimNis,
    required String asalInstansi,
    File? photo,
    bool removePhoto = false,
  }) async {
    try {
      final address = currentUser.asalInstansiAddress?.trim().isNotEmpty == true
          ? currentUser.asalInstansiAddress!
          : asalInstansi;
      final placeId = currentUser.asalInstansiPlaceId?.trim().isNotEmpty == true
          ? currentUser.asalInstansiPlaceId!
          : 'manual';

      final formData = FormData.fromMap({
        'name': name,
        'phone': phone,
        'nim_nis': nimNis,
        'asal_instansi': asalInstansi,
        'asal_instansi_address': address,
        'asal_instansi_latitude': currentUser.asalInstansiLatitude ?? 0,
        'asal_instansi_longitude': currentUser.asalInstansiLongitude ?? 0,
        'asal_instansi_place_id': placeId,
        if (photo != null)
          'photo': await MultipartFile.fromFile(
            photo.path,
            filename: 'profile.jpg',
          ),
        if (removePhoto) 'remove_photo': '1',
      });

      debugPrint('[Profile update] name: $name');
      debugPrint('[Profile update] phone: $phone');
      debugPrint('[Profile update] nim_nis: $nimNis');
      debugPrint('[Profile update] asal_instansi: $asalInstansi');
      debugPrint('[Profile update] address: $address');
      debugPrint('[Profile update] latitude: ${currentUser.asalInstansiLatitude ?? 0}');
      debugPrint('[Profile update] longitude: ${currentUser.asalInstansiLongitude ?? 0}');
      debugPrint('[Profile update] place_id: $placeId');

      final response = await _apiClient.dio.post(
        ApiEndpoints.profile,
        data: formData,
      );

      return Result.success(UserModel.fromJson(response.data));
    } on DioException catch (e) {
      return Result.failure(_extractErrorMessage(e));
    } catch (e) {
      return Result.failure('Terjadi kesalahan tidak terduga: $e');
    }
  }

  @override
  Future<Result<UserModel>> changeEmail({
    required String newEmail,
    required String currentPassword,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.changeEmail,
        data: {
          'emailaddress': newEmail,
          'confirmemailpassword': currentPassword,
        },
      );
      return Result.success(UserModel.fromJson(response.data['user']));
    } on DioException catch (e) {
      return Result.failure(_extractErrorMessage(e));
    } catch (e) {
      return Result.failure('Terjadi kesalahan tidak terduga: $e');
    }
  }

  @override
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _apiClient.dio.post(
        ApiEndpoints.changePassword,
        data: {
          'currentpassword': currentPassword,
          'newpassword': newPassword,
          'confirmpassword': confirmPassword,
        },
      );
      return Result.success(null);
    } on DioException catch (e) {
      return Result.failure(_extractErrorMessage(e));
    } catch (e) {
      return Result.failure('Terjadi kesalahan tidak terduga: $e');
    }
  }

  String _extractErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['errors'] is Map) {
      final errors = data['errors'] as Map;
      return errors.entries
          .map((entry) {
            final messages = entry.value is List
                ? (entry.value as List).join(', ')
                : entry.value.toString();
            return '${entry.key}: $messages';
          })
          .join('\n');
    }
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return 'Terjadi kesalahan: ${e.message}';
  }
}
