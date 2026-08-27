part of 'journal_bloc.dart';

class JournalState extends Equatable {
  final bool isLoading;
  final bool isSubmitting;
  final List<JournalModel> history;
  final String? errorMessage;
  // true sesaat setelah submit sukses, dipakai buat trigger tutup form &
  // snackbar di halaman, lalu di-reset lagi biar tidak ke-trigger berulang
  // waktu widget rebuild karena alasan lain.
  final bool submitSuccess;

  const JournalState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.history = const [],
    this.errorMessage,
    this.submitSuccess = false,
  });

  JournalState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    List<JournalModel>? history,
    String? errorMessage,
    bool clearError = false,
    bool? submitSuccess,
  }) {
    return JournalState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      history: history ?? this.history,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      submitSuccess: submitSuccess ?? false,
    );
  }

  @override
  List<Object?> get props =>
      [isLoading, isSubmitting, history, errorMessage, submitSuccess];
}
