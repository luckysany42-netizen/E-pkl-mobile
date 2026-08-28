/// Merepresentasikan 1 baris tabel `tasks` milik user yang login.
///
/// Status yang mungkin: belum, sedang, submitted, selesai, ditolak, revisi.
/// - belum/sedang: user bisa toggle sendiri (PATCH /tasks/{id}/status)
/// - submitted: sudah dikumpulkan (attachment+note), tinggal nunggu admin
/// - selesai: direview & diterima admin -> FINAL, tidak bisa submit ulang
/// - ditolak/revisi: direview & ditolak/perlu revisi -> boleh submit ulang
class TaskModel {
  final int id;
  final String title;
  final String? description;
  final String status;
  final DateTime? dueDate;
  final String? attachmentUrl; // sudah full URL dari backend ($appends)
  final String? submissionNote; // catatan dari intern saat submit
  final String? adminNote; // catatan dari admin saat review (accept/reject/revise)

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    this.dueDate,
    this.attachmentUrl,
    this.submissionNote,
    this.adminNote,
  });

  /// Backend cuma nolak submit ulang kalau status sudah 'selesai' (lihat
  /// TaskController::submit()) -- status lain (termasuk ditolak/revisi)
  /// tetap boleh dikumpulkan lagi.
  bool get canSubmit => status != 'selesai';

  /// Toggle belum/sedang cuma masuk akal sebelum ada submission.
  bool get canToggleStatus => status == 'belum' || status == 'sedang';

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      description: json['description'],
      status: json['status'] ?? 'belum',
      dueDate: json['due_date'] == null
          ? null
          : DateTime.tryParse(json['due_date'].toString())?.toLocal(),
      attachmentUrl: json['attachment_url'],
      submissionNote: json['submission_note'],
      adminNote: json['admin_note'],
    );
  }
}
