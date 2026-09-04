part of 'profile_bloc.dart';

class ProfileState extends Equatable {
  final bool isSubmitting;
  final String? errorMessage;
  final UserModel? updatedUser;
  final bool submitSuccess;

  const ProfileState({
    this.isSubmitting = false,
    this.errorMessage,
    this.updatedUser,
    this.submitSuccess = false,
  });

  ProfileState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    UserModel? updatedUser,
    bool? submitSuccess,
  }) {
    return ProfileState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      updatedUser: updatedUser ?? this.updatedUser,
      submitSuccess: submitSuccess ?? false,
    );
  }

  @override
  List<Object?> get props => [
        isSubmitting,
        errorMessage,
        updatedUser,
        submitSuccess,
      ];
}
