part of 'journal_bloc.dart';

abstract class JournalEvent extends Equatable {
  const JournalEvent();

  @override
  List<Object?> get props => [];
}

class JournalLoadRequested extends JournalEvent {
  const JournalLoadRequested();
}

class JournalCreateRequested extends JournalEvent {
  final DateTime date;
  final List<JournalActivityModel> activities;
  final File? foto;

  const JournalCreateRequested({
    required this.date,
    required this.activities,
    this.foto,
  });

  @override
  List<Object?> get props => [date, activities, foto];
}
