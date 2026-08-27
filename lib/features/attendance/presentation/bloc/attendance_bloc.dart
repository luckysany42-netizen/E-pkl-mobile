import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/attendance_model.dart';
import '../../domain/repositories/attendance_repository.dart';

part 'attendance_event.dart';
part 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceRepository _repository;

  AttendanceBloc(this._repository) : super(const AttendanceState()) {
    on<AttendanceLoadRequested>(_onLoadRequested);
    on<AttendanceCheckInRequested>(_onCheckInRequested);
    on<AttendanceCheckOutRequested>(_onCheckOutRequested);
  }

  Future<void> _onLoadRequested(
    AttendanceLoadRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final todayResult = await _repository.getToday();
    final historyResult = await _repository.getHistory();

    emit(
      state.copyWith(
        isLoading: false,
        today: todayResult.isSuccess ? todayResult.data : null,
        clearToday: todayResult.isSuccess && todayResult.data == null,
        history: historyResult.isSuccess ? historyResult.data : state.history,
        errorMessage: (!todayResult.isSuccess)
            ? todayResult.errorMessage
            : (!historyResult.isSuccess ? historyResult.errorMessage : null),
      ),
    );
  }

  Future<void> _onCheckInRequested(
    AttendanceCheckInRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));

    final result = await _repository.checkIn(photo: event.photo);

    if (result.isSuccess) {
      emit(state.copyWith(isSubmitting: false, today: result.data));
      add(const AttendanceLoadRequested()); // refresh riwayat juga
    } else {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: result.errorMessage,
        ),
      );
    }
  }

  Future<void> _onCheckOutRequested(
    AttendanceCheckOutRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));

    final result = await _repository.checkOut(base64Photo: event.base64Photo);

    if (result.isSuccess) {
      emit(state.copyWith(isSubmitting: false, today: result.data));
      add(const AttendanceLoadRequested());
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
