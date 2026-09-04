import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/leave_request_model.dart';
import '../../domain/repositories/leave_repository.dart';

part 'leave_event.dart';
part 'leave_state.dart';

class LeaveBloc extends Bloc<LeaveEvent, LeaveState> {
  final LeaveRepository _repository;

  LeaveBloc(this._repository) : super(const LeaveState()) {
    on<LeaveLoadRequested>(_load);
    on<LeaveCreateRequested>(_create);
  }

  Future<void> _load(
    LeaveLoadRequested event,
    Emitter<LeaveState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    final result = await _repository.getLeaveRequests();
    if (result.isSuccess) {
      emit(state.copyWith(isLoading: false, requests: result.data));
    } else {
      emit(state.copyWith(isLoading: false, errorMessage: result.errorMessage));
    }
  }

  Future<void> _create(
    LeaveCreateRequested event,
    Emitter<LeaveState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    final result = await _repository.createLeaveRequest(
      date: event.date,
      reasonType: event.reasonType,
      note: event.note,
      attachment: event.attachment,
    );
    if (result.isSuccess) {
      emit(state.copyWith(isSubmitting: false, createSuccess: true));
      add(const LeaveLoadRequested());
    } else {
      emit(state.copyWith(isSubmitting: false, errorMessage: result.errorMessage));
    }
  }
}
