import 'dart:io';

import '../../../../core/network/result.dart';
import '../../data/models/journal_activity_model.dart';
import '../../data/models/journal_model.dart';

abstract class JournalRepository {
  /// GET /journals/history -> riwayat jurnal MILIK SENDIRI, terbaru dulu.
  /// (Bukan GET /journals biasa -- endpoint itu di backend cuma stub kosong,
  /// belum diimplementasikan buat listing.)
  Future<Result<List<JournalModel>>> getHistory();

  /// GET /journals/dates-taken -> daftar tanggal yang SUDAH punya jurnal
  /// milik user ini. Dipakai buat nge-disable tanggal itu di date picker
  /// form Tambah Jurnal (backend cuma izinkan 1 jurnal per tanggal per user).
  Future<Result<List<DateTime>>> getDatesTaken();

  /// POST /journals -> bikin 1 jurnal untuk 1 tanggal, bisa banyak activities
  /// sekaligus. Foto opsional (bukti kegiatan hari itu). Backend akan
  /// menolak (422) kalau tanggal ini sudah pernah dipakai user yang sama.
  Future<Result<JournalModel>> create({
    required DateTime date,
    required List<JournalActivityModel> activities,
    File? foto,
  });

  /// PUT /journals/{id} -> edit jurnal yang sudah ada (activities & foto,
  /// TANGGAL TIDAK BISA diubah). Kalau status sebelumnya approved/rejected,
  /// backend otomatis balikin ke pending setelah diedit.
  Future<Result<JournalModel>> update({
    required int journalId,
    required List<JournalActivityModel> activities,
    File? foto,
  });
}
