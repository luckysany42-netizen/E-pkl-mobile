import 'dart:io';

import '../../../../core/network/result.dart';
import '../../data/models/attendance_model.dart';

abstract class AttendanceRepository {
  /// GET /attendances -> semua riwayat milik user yang login, terbaru dulu.
  /// Difilter jadi "minggu ini" / "bulan ini" di sisi app (bukan backend),
  /// karena backend belum punya endpoint filter tanggal.
  Future<Result<List<AttendanceModel>>> getHistory();

  /// GET /attendances/today -> null di dalam Result kalau belum absen sama
  /// sekali hari ini (backend balikin data: null, bukan error).
  Future<Result<AttendanceModel?>> getToday();

  /// POST /attendances/check-in (multipart, field: photo [wajib], location
  /// [opsional]).
  Future<Result<AttendanceModel>> checkIn({
    required File photo,
    String? location,
  });

  /// POST /attendances/check-out (JSON, field: photo berupa base64 string).
  Future<Result<AttendanceModel>> checkOut({required String base64Photo});
}
