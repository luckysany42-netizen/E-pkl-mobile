import '../../../../core/constants/api_endpoints.dart';
import 'journal_activity_model.dart';

class JournalModel {
  final int id;
  final DateTime date;
  final String? foto;
  final String status; // pending | approved | rejected
  final String? catatanApproval; // alasan ditolak, cuma ada kalau status=rejected
  final List<JournalActivityModel> activities;

  JournalModel({
    required this.id,
    required this.date,
    this.foto,
    required this.status,
    this.catatanApproval,
    this.activities = const [],
  });

  String? get fotoUrl => ApiEndpoints.assetUrl(foto);

  factory JournalModel.fromJson(Map<String, dynamic> json) {
    return JournalModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      // .toLocal() WAJIB: backend ngirim tanggal dengan sufiks "Z" (UTC).
      // Tanpa ini, midnight WIB (UTC+7) kebaca sebagai UTC murni, jadi
      // mundur 1 hari kalau langsung diformat (misal 10 Agustus 00:00 WIB
      // == 9 Agustus 17:00 UTC -> tanpa toLocal() akan tampil "9 Agustus").
      date: DateTime.parse(json['date'].toString()).toLocal(),
      foto: json['foto'],
      status: json['status'] ?? 'pending',
      catatanApproval: json['catatan_approval'],
      activities: (json['activities'] as List? ?? [])
          .map((e) => JournalActivityModel.fromJson(e))
          .toList(),
    );
  }
}
