import 'app_language.dart';

/// Terjemahan untuk value tetap/enum yang datang dari backend Laravel,
/// misal status 'hadir', role 'karyawan', dst. TIDAK dipakai untuk teks
/// bebas dari server (nama orang, isi jurnal, dsb) karena itu bukan enum
/// tetap — tidak bisa diterjemahkan otomatis tanpa API terjemahan
/// (misal Google Translate API), yang belum dipasang di project ini.
class ServerValueTranslator {
  ServerValueTranslator._();

  static const Map<String, Map<AppLanguage, String>> _values = {
    // status attendance & user
    'hadir': {AppLanguage.id: 'Hadir', AppLanguage.en: 'Present'},
    'izin': {AppLanguage.id: 'Izin', AppLanguage.en: 'Leave'},
    'sakit': {AppLanguage.id: 'Sakit', AppLanguage.en: 'Sick'},
    'alpha': {AppLanguage.id: 'Alpha', AppLanguage.en: 'Absent'},
    'aktif': {AppLanguage.id: 'Aktif', AppLanguage.en: 'Active'},
    'selesai': {AppLanguage.id: 'Selesai', AppLanguage.en: 'Completed'},
    'nonaktif': {AppLanguage.id: 'Nonaktif', AppLanguage.en: 'Inactive'},
    // status task
    'belum': {AppLanguage.id: 'Belum Dikerjakan', AppLanguage.en: 'Not Started'},
    'sedang': {AppLanguage.id: 'Sedang Dikerjakan', AppLanguage.en: 'In Progress'},
    'submitted': {
      AppLanguage.id: 'Menunggu Review',
      AppLanguage.en: 'Pending Review',
    },
    'ditolak': {AppLanguage.id: 'Ditolak', AppLanguage.en: 'Rejected'},
    'revisi': {
      AppLanguage.id: 'Perlu Revisi',
      AppLanguage.en: 'Needs Revision',
    },
    // status journal / task
    'pending': {AppLanguage.id: 'Menunggu', AppLanguage.en: 'Pending'},
    'approved': {AppLanguage.id: 'Disetujui', AppLanguage.en: 'Approved'},
    'rejected': {AppLanguage.id: 'Ditolak', AppLanguage.en: 'Rejected'},
    // role
    'karyawan': {AppLanguage.id: 'Intern', AppLanguage.en: 'Intern'},
    'hr-admin': {AppLanguage.id: 'Admin HR', AppLanguage.en: 'HR Admin'},
    'atasan': {AppLanguage.id: 'Atasan', AppLanguage.en: 'Supervisor'},
  };

  /// Kalau value dari server tidak ada di kamus (misal typo atau status baru
  /// yang belum didaftarkan di sini), tampilkan apa adanya daripada error.
  static String t(String? serverValue, AppLanguage lang) {
    if (serverValue == null) return '-';
    return _values[serverValue.toLowerCase()]?[lang] ?? serverValue;
  }
}
