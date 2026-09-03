part of 'task_bloc.dart';

class TaskState extends Equatable {
  final bool isLoading;
  // ID task yang lagi diupdate statusnya ATAU lagi disubmit (dipakai buat
  // 2 aksi: toggle status & kumpulkan tugas -- keduanya butuh loading per
  // kartu, bukan loading global).
  final int? processingTaskId;
  final List<TaskModel> tasks;
  final String? errorMessage;
  // true sesaat setelah submit sukses, dipakai buat trigger tutup bottom
  // sheet + snackbar sukses.
  final bool submitSuccess;

  const TaskState({
    this.isLoading = false,
    this.processingTaskId,
    this.tasks = const [],
    this.errorMessage,
    this.submitSuccess = false,
  });

  TaskState copyWith({
    bool? isLoading,
    int? processingTaskId,
    bool clearProcessingTaskId = false,
    List<TaskModel>? tasks,
    String? errorMessage,
    bool clearError = false,
    bool? submitSuccess,
  }) {
    return TaskState(
      isLoading: isLoading ?? this.isLoading,
      processingTaskId: clearProcessingTaskId
          ? null
          : (processingTaskId ?? this.processingTaskId),
      tasks: tasks ?? this.tasks,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      // PENTING: default-nya PERTAHANKAN nilai sebelumnya (bukan selalu
      // reset ke false). Sebelumnya, SETIAP copyWith() -- termasuk dari
      // _onLoadRequested/_onStatusUpdateRequested yang tidak ada
      // hubungannya dengan submit -- diam-diam ikut me-reset submitSuccess
      // ke false. Kalau reset ini kebetulan "menyusul" tepat setelah submit
      // sukses (misal race dengan event lain), listener widget bisa gagal
      // sempat bereaksi. Sekarang submitSuccess CUMA berubah kalau memang
      // sengaja di-set (baik ke true saat sukses, maupun eksplisit ke false
      // di awal aksi baru) -- lihat _onSubmitRequested di task_bloc.dart.
      submitSuccess: submitSuccess ?? this.submitSuccess,
    );
  }

  @override
  List<Object?> get props =>
      [isLoading, processingTaskId, tasks, errorMessage, submitSuccess];
}
