part of 'task_bloc.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class TaskLoadRequested extends TaskEvent {
  const TaskLoadRequested();
}

class TaskStatusUpdateRequested extends TaskEvent {
  final int taskId;
  final String status;

  const TaskStatusUpdateRequested({required this.taskId, required this.status});

  @override
  List<Object?> get props => [taskId, status];
}

class TaskSubmitRequested extends TaskEvent {
  final int taskId;
  final List<File> attachments;
  final String? note;

  const TaskSubmitRequested({
    required this.taskId,
    required this.attachments,
    this.note,
  });

  @override
  List<Object?> get props => [taskId, attachments, note];
}
