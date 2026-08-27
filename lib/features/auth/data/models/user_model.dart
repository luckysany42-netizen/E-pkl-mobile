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
    // Field 'role' dan 'permission' dari backend kadang berupa List<String>,
    // kadang List<Map> (nama role di key 'name') tergantung versi Spatie.
    // Ditangani dua-duanya biar aman.
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

    DateTime? parseDate(dynamic raw) {
      if (raw == null || raw.toString().isEmpty) return null;
      return DateTime.tryParse(raw.toString());
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
      roles: parseNames(json['role'] ?? json['roles']),
      permissions: parseNames(json['permission'] ?? json['permissions']),
    );
  }
}
