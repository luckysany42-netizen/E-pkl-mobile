import 'dart:io';

import '../../../../core/network/result.dart';
import '../../data/models/task_model.dart';

abstract class TaskRepository {
  /// GET /intern/tasks -> tugas milik user yang login, sudah diurutkan
  /// backend (revisi -> sedang -> belum -> submitted -> selesai -> ditolak).
  Future<Result<List<TaskModel>>> getTasks();

  /// PATCH /tasks/{id}/status -> HANYA terima 'belum' atau 'sedang'.
  /// Backend nolak (403) kalau task itu bukan punya user yang login, dan
  /// nolak (422) kalau status di luar belum/sedang (misal 'selesai').
  Future<Result<TaskModel>> updateStatus({
    required int taskId,
    required String status,
  });

  /// POST /tasks/{id}/submit (multipart) -> kumpulkan tugas dengan BANYAK
  /// file sekaligus (min 1) + catatan opsional. Backend nolak (422) kalau
  /// task sudah berstatus 'selesai'. Berhasil submit -> status jadi
  /// 'submitted', dan lampiran LAMA (kalau ada, dari submission sebelumnya
  /// yang direvisi/ditolak) otomatis dihapus & diganti yang baru.
  Future<Result<TaskModel>> submitTask({
    required int taskId,
    required List<File> attachments,
    String? note,
  });
}
