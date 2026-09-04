import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/data/models/user_model.dart';
import '../../domain/repositories/profile_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repository;

  ProfileBloc(this._repository) : super(const ProfileState()) {
    on<ProfileUpdateRequested>(_onUpdateProfile);
    on<ProfileChangeEmailRequested>(_onChangeEmail);
    on<ProfileChangePasswordRequested>(_onChangePassword);
  }

  Future<void> _onUpdateProfile(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    final result = await _repository.updateProfile(
      currentUser: event.currentUser,
      name: event.name,
      phone: event.phone,
      nimNis: event.nimNis,
      asalInstansi: event.asalInstansi,
      photo: event.photo,
      removePhoto: event.removePhoto,
    );
    if (result.isSuccess) {
      emit(state.copyWith(
        isSubmitting: false,
        updatedUser: result.data,
        submitSuccess: true,
      ));
    } else {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: result.errorMessage,
      ));
    }
  }

  Future<void> _onChangeEmail(
    ProfileChangeEmailRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    final result = await _repository.changeEmail(
      newEmail: event.newEmail,
      currentPassword: event.currentPassword,
    );
    if (result.isSuccess) {
      emit(state.copyWith(
        isSubmitting: false,
        updatedUser: result.data,
        submitSuccess: true,
      ));
    } else {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: result.errorMessage,
      ));
    }
  }

  Future<void> _onChangePassword(
    ProfileChangePasswordRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    final result = await _repository.changePassword(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
      confirmPassword: event.confirmPassword,
    );
    emit(state.copyWith(
      isSubmitting: false,
      submitSuccess: result.isSuccess,
      errorMessage: result.isSuccess ? null : result.errorMessage,
    ));
  }
}
