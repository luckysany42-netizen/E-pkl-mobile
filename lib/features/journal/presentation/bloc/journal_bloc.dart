import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/journal_activity_model.dart';
import '../../data/models/journal_model.dart';
import '../../domain/repositories/journal_repository.dart';

part 'journal_event.dart';
part 'journal_state.dart';

class JournalBloc extends Bloc<JournalEvent, JournalState> {
  final JournalRepository _repository;

  JournalBloc(this._repository) : super(const JournalState()) {
    on<JournalLoadRequested>(_onLoadRequested);
    on<JournalCreateRequested>(_onCreateRequested);
  }

  Future<void> _onLoadRequested(
    JournalLoadRequested event,
    Emitter<JournalState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _repository.getHistory();

    if (result.isSuccess) {
      emit(state.copyWith(isLoading: false, history: result.data));
    } else {
      emit(
        state.copyWith(isLoading: false, errorMessage: result.errorMessage),
      );
    }
  }

  Future<void> _onCreateRequested(
    JournalCreateRequested event,
    Emitter<JournalState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));

    final result = await _repository.create(
      date: event.date,
      activities: event.activities,
      foto: event.foto,
    );

    if (result.isSuccess) {
      emit(state.copyWith(isSubmitting: false, submitSuccess: true));
      add(const JournalLoadRequested()); // refresh riwayat
    } else {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: result.errorMessage,
        ),
      );
    }
  }
}
