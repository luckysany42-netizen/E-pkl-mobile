part of 'attendance_bloc.dart';

class AttendanceState extends Equatable {
  final bool isLoading;
  // true khusus saat proses submit check-in/check-out (beda dari isLoading
  // awal, supaya UI bisa nunjukin loading di tombol tanpa nge-blank
  // seluruh halaman yang sudah ada datanya).
  final bool isSubmitting;
  final AttendanceModel? today;
  final List<AttendanceModel> history;
  final String? errorMessage;

  const AttendanceState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.today,
    this.history = const [],
    this.errorMessage,
  });

  AttendanceState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    AttendanceModel? today,
    bool clearToday = false,
    List<AttendanceModel>? history,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AttendanceState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      today: clearToday ? null : (today ?? this.today),
      history: history ?? this.history,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props =>
      [isLoading, isSubmitting, today, history, errorMessage];
}
