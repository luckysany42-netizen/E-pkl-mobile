import 'dart:io';

import '../../../../core/network/result.dart';
import '../../data/models/journal_activity_model.dart';
import '../../data/models/journal_model.dart';

abstract class JournalRepository {
  /// GET /journals/history -> riwayat jurnal MILIK SENDIRI, terbaru dulu.
  /// (Bukan GET /journals biasa -- endpoint itu di backend cuma stub kosong,
  /// belum diimplementasikan buat listing.)
  Future<Result<List<JournalModel>>> getHistory();

  /// POST /journals -> bikin 1 jurnal untuk 1 tanggal, bisa banyak activities
  /// sekaligus. Foto opsional (bukti kegiatan hari itu).
  Future<Result<JournalModel>> create({
    required DateTime date,
    required List<JournalActivityModel> activities,
    File? foto,
  });
}
