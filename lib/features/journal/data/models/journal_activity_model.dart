/// Satu baris aktivitas di dalam 1 jurnal (tabel journal_activities).
/// Satu jurnal (1 tanggal) bisa punya banyak activities.
class JournalActivityModel {
  final int? id;
  final String jamMulai; // format "HH:mm" saat dikirim, "HH:mm:ss" saat diterima
  final String jamSelesai;
  final String kegiatan;

  JournalActivityModel({
    this.id,
    required this.jamMulai,
    required this.jamSelesai,
    required this.kegiatan,
  });

  factory JournalActivityModel.fromJson(Map<String, dynamic> json) {
    return JournalActivityModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()),
      // Backend simpan "14:06:00" (ada detik), potong ke "HH:mm" biar rapi
      // ditampilkan, tanpa perlu package format tambahan.
      jamMulai: (json['jam_mulai'] ?? '').toString().substring(0, 5),
      jamSelesai: (json['jam_selesai'] ?? '').toString().substring(0, 5),
      kegiatan: json['kegiatan'] ?? '',
    );
  }

  /// Dipakai saat kirim ke POST /journals (field jam_mulai/jam_selesai
  /// backend butuh format "H:i", cukup "HH:mm" tanpa detik).
  Map<String, dynamic> toJson() => {
        'jam_mulai': jamMulai,
        'jam_selesai': jamSelesai,
        'kegiatan': kegiatan,
      };
}
