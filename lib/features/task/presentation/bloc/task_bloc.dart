import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/task_model.dart';
import '../../domain/repositories/task_repository.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _repository;

  TaskBloc(this._repository) : super(const TaskState()) {
    on<TaskLoadRequested>(_onLoadRequested);
    on<TaskStatusUpdateRequested>(_onStatusUpdateRequested);
    on<TaskSubmitRequested>(_onSubmitRequested);
  }

  Future<void> _onLoadRequested(
    TaskLoadRequested event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _repository.getTasks();

    if (result.isSuccess) {
      emit(state.copyWith(isLoading: false, tasks: result.data));
    } else {
      emit(
        state.copyWith(isLoading: false, errorMessage: result.errorMessage),
      );
    }
  }

  Future<void> _onStatusUpdateRequested(
    TaskStatusUpdateRequested event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(processingTaskId: event.taskId, clearError: true));

    final result = await _repository.updateStatus(
      taskId: event.taskId,
      status: event.status,
    );

    if (result.isSuccess) {
      final updatedTasks = state.tasks
          .map((t) => t.id == event.taskId ? result.data! : t)
          .toList();
      emit(state.copyWith(tasks: updatedTasks, clearProcessingTaskId: true));
    } else {
      emit(
        state.copyWith(
          clearProcessingTaskId: true,
          errorMessage: result.errorMessage,
        ),
      );
    }
  }

  Future<void> _onSubmitRequested(
    TaskSubmitRequested event,
    Emitter<TaskState> emit,
  ) async {
    emit(
      state.copyWith(
        processingTaskId: event.taskId,
        clearError: true,
        submitSuccess: false,
      ),
    );

    final result = await _repository.submitTask(
      taskId: event.taskId,
      attachment: event.attachment,
      note: event.note,
    );

    if (result.isSuccess) {
      final updatedTasks = state.tasks
          .map((t) => t.id == event.taskId ? result.data! : t)
          .toList();
      emit(
        state.copyWith(
          tasks: updatedTasks,
          clearProcessingTaskId: true,
          submitSuccess: true,
        ),
      );
    } else {
      emit(
        state.copyWith(
          clearProcessingTaskId: true,
          errorMessage: result.errorMessage,
        ),
      );
    }
  }
}
