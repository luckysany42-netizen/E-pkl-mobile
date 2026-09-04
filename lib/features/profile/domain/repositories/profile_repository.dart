import 'dart:io';

import '../../../../core/network/result.dart';
import '../../../auth/data/models/user_model.dart';

abstract class ProfileRepository {
  Future<Result<UserModel>> updateProfile({
    required UserModel currentUser,
    required String name,
    required String phone,
    required String nimNis,
    required String asalInstansi,
    File? photo,
    bool removePhoto = false,
  });

  Future<Result<UserModel>> changeEmail({
    required String newEmail,
    required String currentPassword,
  });

  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  });
}
