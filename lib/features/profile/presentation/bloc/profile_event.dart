part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileUpdateRequested extends ProfileEvent {
  final UserModel currentUser;
  final String name;
  final String phone;
  final String nimNis;
  final String asalInstansi;
  final File? photo;
  final bool removePhoto;

  const ProfileUpdateRequested({
    required this.currentUser,
    required this.name,
    required this.phone,
    required this.nimNis,
    required this.asalInstansi,
    this.photo,
    this.removePhoto = false,
  });

  @override
  List<Object?> get props => [
        currentUser,
        name,
        phone,
        nimNis,
        asalInstansi,
        photo,
        removePhoto,
      ];
}

class ProfileChangeEmailRequested extends ProfileEvent {
  final String newEmail;
  final String currentPassword;

  const ProfileChangeEmailRequested({
    required this.newEmail,
    required this.currentPassword,
  });

  @override
  List<Object?> get props => [newEmail, currentPassword];
}

class ProfileChangePasswordRequested extends ProfileEvent {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  const ProfileChangePasswordRequested({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [
        currentPassword,
        newPassword,
        confirmPassword,
      ];
}
