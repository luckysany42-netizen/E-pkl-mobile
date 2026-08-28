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
      submitSuccess: submitSuccess ?? false,
    );
  }

  @override
  List<Object?> get props =>
      [isLoading, processingTaskId, tasks, errorMessage, submitSuccess];
}
