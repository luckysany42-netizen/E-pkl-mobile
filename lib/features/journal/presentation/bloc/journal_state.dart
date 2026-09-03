part of 'journal_bloc.dart';

class JournalState extends Equatable {
  final bool isLoading;
  final bool isSubmitting;
  final List<JournalModel> history;
  final List<DateTime> datesTaken;
  final String? errorMessage;

  // True sesaat setelah submit sukses.
  // Digunakan oleh halaman form untuk menutup halaman setelah
  // create/update berhasil.
  final bool submitSuccess;

  const JournalState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.history = const [],
    this.datesTaken = const [],
    this.errorMessage,
    this.submitSuccess = false,
  });

  JournalState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    List<JournalModel>? history,
    List<DateTime>? datesTaken,
    String? errorMessage,
    bool clearError = false,
    bool? submitSuccess,
  }) {
    return JournalState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      history: history ?? this.history,
      datesTaken: datesTaken ?? this.datesTaken,
      errorMessage: clearError
          ? null
          : (errorMessage ?? this.errorMessage),

      // Nilai lama tetap dipertahankan secara default.
      // Caller yang membutuhkan reset harus mengirim
      // submitSuccess: false secara eksplisit.
      submitSuccess: submitSuccess ?? this.submitSuccess,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isSubmitting,
        history,
        datesTaken,
        errorMessage,
        submitSuccess,
      ];
}