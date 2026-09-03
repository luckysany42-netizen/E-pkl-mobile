/// Satu file lampiran dari submission tugas (tabel `task_attachments`).
/// Backend sekarang mendukung BANYAK lampiran per submission (dulu cuma 1).
class TaskAttachmentModel {
  final int id;
  final String url; // sudah full URL dari backend ($appends 'url')
  final String? originalName;
  final String? mimeType;
  final bool isImage;

  TaskAttachmentModel({
    required this.id,
    required this.url,
    this.originalName,
    this.mimeType,
    required this.isImage,
  });

  factory TaskAttachmentModel.fromJson(Map<String, dynamic> json) {
    return TaskAttachmentModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      url: json['url'] ?? '',
      originalName: json['original_name'],
      mimeType: json['mime_type'],
      isImage: json['is_image'] == true,
    );
  }
}
