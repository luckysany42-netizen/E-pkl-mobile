part of 'leave_bloc.dart';

abstract class LeaveEvent extends Equatable {
  const LeaveEvent();

  @override
  List<Object?> get props => [];
}

class LeaveLoadRequested extends LeaveEvent {
  const LeaveLoadRequested();
}

class LeaveCreateRequested extends LeaveEvent {
  final DateTime date;
  final String reasonType;
  final String? note;
  final File? attachment;

  const LeaveCreateRequested({
    required this.date,
    required this.reasonType,
    this.note,
    this.attachment,
  });

  @override
  List<Object?> get props => [date, reasonType, note, attachment];
}
