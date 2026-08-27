import '../../../../core/constants/api_endpoints.dart';

/// Merepresentasikan 1 baris tabel `attendances`. Satu baris = satu HARI
/// (check-in & check-out ada di kolom yang sama, bukan 2 row terpisah).
class AttendanceModel {
  final int id;
  final DateTime date;
  final String? checkInTime; // format "HH:mm:ss" dari Laravel
  final String? checkInPhoto;
  final String? checkOutTime;
  final String? checkOutPhoto;
  final String? location;
  final String status; // hadir | izin | sakit | alpha

  AttendanceModel({
    required this.id,
    required this.date,
    this.checkInTime,
    this.checkInPhoto,
    this.checkOutTime,
    this.checkOutPhoto,
    this.location,
    required this.status,
  });

  bool get hasCheckedIn => checkInTime != null;
  bool get hasCheckedOut => checkOutTime != null;

  String? get checkInPhotoUrl => ApiEndpoints.assetUrl(checkInPhoto);
  String? get checkOutPhotoUrl => ApiEndpoints.assetUrl(checkOutPhoto);

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      // .toLocal() WAJIB: sama seperti di journal_model.dart, backend
      // ngirim tanggal ber-sufiks "Z" (UTC), tanpa konversi ini tanggal
      // bisa mundur 1 hari saat ditampilkan.
      date: DateTime.parse(json['date'].toString()).toLocal(),
      checkInTime: json['check_in_time'],
      checkInPhoto: json['check_in_photo'],
      checkOutTime: json['check_out_time'],
      checkOutPhoto: json['check_out_photo'],
      location: json['location'],
      status: json['status'] ?? 'hadir',
    );
  }
}
