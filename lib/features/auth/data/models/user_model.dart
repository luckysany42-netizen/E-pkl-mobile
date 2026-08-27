import '../../../../core/constants/api_endpoints.dart';

/// Merepresentasikan tabel `users` di Laravel, termasuk field tambahan
/// `role` & `permission` yang otomatis nempel di response ($appends di User.php).
class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? photo;
  final String? nimNis;
  final String? asalInstansi;
  final String? posisi;
  final DateTime? tanggalMulai;
  final DateTime? tanggalSelesai;
  final int? atasanId;
  final String status; // aktif | selesai | nonaktif
  final List<String> roles;
  final List<String> permissions;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.photo,
    this.nimNis,
    this.asalInstansi,
    this.posisi,
    this.tanggalMulai,
    this.tanggalSelesai,
    this.atasanId,
    required this.status,
    this.roles = const [],
    this.permissions = const [],
  });

  /// URL foto profil yang siap dipakai Image.network (sudah digabung
  /// dengan base host), atau null kalau user belum punya foto.
  String? get photoUrl => (photo == null || photo!.isEmpty)
      ? null
      : ApiEndpoints.assetUrl(photo);

  bool get isIntern => roles.contains('karyawan');
  bool get isHrAdmin => roles.contains('hr-admin');
  bool get isAtasan => roles.contains('atasan');

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Field 'permission' dari backend berupa List<String> (hasil ->pluck('name')),
    // jadi List biasa aman diparsing pakai helper ini.
    List<String> parseNames(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) {
        return raw
            .map((e) => e is String ? e : (e is Map ? e['name']?.toString() : null))
            .whereType<String>()
            .toList();
      }
      return [];
    }

    // PENTING: field 'role' dari backend BUKAN array, melainkan SATU OBJECT
    // role tunggal (lihat User::getRoleAttribute() di Laravel yang balikin
    // $roles->first() / hasil firstWhere, bukan list). Makanya butuh parser
    // terpisah dari 'permission' yang memang array.
    List<String> parseRole(dynamic raw) {
      if (raw == null) return [];
      if (raw is Map && raw['name'] != null) return [raw['name'].toString()];
      if (raw is List) return parseNames(raw); // jaga-jaga kalau backend berubah jadi array
      return [];
    }

    DateTime? parseDate(dynamic raw) {
      if (raw == null || raw.toString().isEmpty) return null;
      // .toLocal() konsisten dengan journal_model.dart & attendance_model.dart
      // (lihat komentar di sana untuk penjelasan bug mundur 1 harinya).
      return DateTime.tryParse(raw.toString())?.toLocal();
    }

    return UserModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      photo: json['photo'],
      nimNis: json['nim_nis'],
      asalInstansi: json['asal_instansi'],
      posisi: json['posisi'],
      tanggalMulai: parseDate(json['tanggal_mulai']),
      tanggalSelesai: parseDate(json['tanggal_selesai']),
      atasanId: json['atasan_id'] == null
          ? null
          : int.tryParse(json['atasan_id'].toString()),
      status: json['status'] ?? 'aktif',
      roles: parseRole(json['role']),
      permissions: parseNames(json['permission']),
    );
  }
}
