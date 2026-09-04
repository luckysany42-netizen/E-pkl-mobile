part of 'leave_bloc.dart';

class LeaveState extends Equatable {
  final bool isLoading;
  final bool isSubmitting;
  final bool createSuccess;
  final String? errorMessage;
  final List<LeaveRequestModel> requests;

  const LeaveState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.createSuccess = false,
    this.errorMessage,
    this.requests = const [],
  });

  LeaveState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    bool? createSuccess,
    String? errorMessage,
    bool clearError = false,
    List<LeaveRequestModel>? requests,
  }) {
    return LeaveState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      createSuccess: createSuccess ?? false,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      requests: requests ?? this.requests,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isSubmitting,
        createSuccess,
        errorMessage,
        requests,
      ];
}
