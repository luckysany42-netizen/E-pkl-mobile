import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
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
    on<JournalDatesTakenLoadRequested>(_onDatesTakenLoadRequested);
    on<JournalCreateRequested>(_onCreateRequested);
    on<JournalUpdateRequested>(_onUpdateRequested);
  }

  Future<void> _onLoadRequested(
    JournalLoadRequested event,
    Emitter<JournalState> emit,
  ) async {
    debugPrint('[JournalBloc] _onLoadRequested START');

    // submitSuccess harus di-reset ketika mulai refresh history.
    // Kalau tidak, state submitSuccess=true dari proses create/update
    // akan ikut terbawa ke state berikutnya dan listener halaman form
    // bisa memanggil Navigator.pop() lagi.
    emit(
      state.copyWith(
        isLoading: true,
        clearError: true,
        submitSuccess: false,
      ),
    );

    final result = await _repository.getHistory();

    if (result.isSuccess) {
      debugPrint('[JournalBloc] _onLoadRequested SUKSES');

      emit(
        state.copyWith(
          isLoading: false,
          history: result.data,
          submitSuccess: false,
        ),
      );
    } else {
      debugPrint(
        '[JournalBloc] _onLoadRequested GAGAL, '
        'error=${result.errorMessage}',
      );

      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: result.errorMessage,
          submitSuccess: false,
        ),
      );
    }
  }

  Future<void> _onDatesTakenLoadRequested(
    JournalDatesTakenLoadRequested event,
    Emitter<JournalState> emit,
  ) async {
    final result = await _repository.getDatesTaken();

    if (result.isSuccess) {
      emit(
        state.copyWith(
          datesTaken: result.data,
        ),
      );
    }

    // Sengaja tidak emit error kalau ini gagal -- bukan blocker fatal
    // buat buka form, cuma berarti validasi tanggal dobel jadi cuma
    // dicek di backend (submit tetap akan ditolak backend kalau memang
    // bentrok).
  }

  Future<void> _onCreateRequested(
    JournalCreateRequested event,
    Emitter<JournalState> emit,
  ) async {
    debugPrint('[JournalBloc] _onCreateRequested START');

    // Reset submitSuccess sebelum memulai submit baru.
    emit(
      state.copyWith(
        isSubmitting: true,
        clearError: true,
        submitSuccess: false,
      ),
    );

    final result = await _repository.create(
      date: event.date,
      activities: event.activities,
      foto: event.foto,
    );

    debugPrint(
      '[JournalBloc] repository.create() SELESAI, '
      'isSuccess=${result.isSuccess}, '
      'error=${result.errorMessage}',
    );

    if (result.isSuccess) {
      debugPrint('[JournalBloc] emit submitSuccess=true');

      // State sukses hanya digunakan sebagai trigger untuk halaman form.
      emit(
        state.copyWith(
          isSubmitting: false,
          submitSuccess: true,
        ),
      );

      // Refresh riwayat setelah data berhasil disimpan.
      // _onLoadRequested() akan langsung me-reset submitSuccess=false.
      add(const JournalLoadRequested());
    } else {
      debugPrint(
        '[JournalBloc] emit errorMessage=${result.errorMessage}',
      );

      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: result.errorMessage,
          submitSuccess: false,
        ),
      );
    }
  }

  Future<void> _onUpdateRequested(
    JournalUpdateRequested event,
    Emitter<JournalState> emit,
  ) async {
    debugPrint(
      '[JournalBloc] _onUpdateRequested START '
      'journalId=${event.journalId}',
    );

    // Reset submitSuccess sebelum memulai update baru.
    emit(
      state.copyWith(
        isSubmitting: true,
        clearError: true,
        submitSuccess: false,
      ),
    );

    final result = await _repository.update(
      journalId: event.journalId,
      activities: event.activities,
      foto: event.foto,
    );

    debugPrint(
      '[JournalBloc] repository.update() SELESAI, '
      'isSuccess=${result.isSuccess}, '
      'error=${result.errorMessage}',
    );

    if (result.isSuccess) {
      debugPrint('[JournalBloc] emit submitSuccess=true');

      emit(
        state.copyWith(
          isSubmitting: false,
          submitSuccess: true,
        ),
      );

      // Refresh riwayat setelah data berhasil di-update.
      // _onLoadRequested() akan me-reset submitSuccess=false.
      add(const JournalLoadRequested());
    } else {
      debugPrint(
        '[JournalBloc] emit errorMessage=${result.errorMessage}',
      );

      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: result.errorMessage,
          submitSuccess: false,
        ),
      );
    }
  }
}