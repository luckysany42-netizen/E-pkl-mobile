/// Kumpulan endpoint API, mengikuti struktur routes/api.php di project Laravel
/// (E-pkl-main). Sesuaikan [baseUrl] dengan alamat server backend kamu.
///
/// Kamu testing pakai HP fisik (bukan emulator) yang konek ke laptop lewat
/// WiFi yang sama, jadi HARUS pakai IP LAN laptop, bukan localhost/10.0.2.2.
/// Cek IP LAN laptop lewat: ipconfig (cari "IPv4 Address" di adapter WiFi).
/// Kalau IP laptop berubah (misal ganti WiFi / restart router), update lagi
/// nilai di bawah ini.
class ApiEndpoints {
  ApiEndpoints._();

  static const String _host = 'http://192.168.112.210:8000';
  static const String baseUrl = '$_host/api';

  /// Field seperti `photo`, `foto` dari backend cuma path relatif
  /// (contoh: "journals/xxx.png", TANPA prefix "/storage/" -- ini konvensi
  /// dari UserController/AttendanceController/JournalController yang
  /// nyimpen hasil ->store() apa adanya, beda dengan SettingController/
  /// Landing* yang eksplisit nambahin '/storage/' sendiri sebelum simpan
  /// ke DB). Pakai method ini buat dapetin URL utuh yang bisa dipakai
  /// Image.network / CachedNetworkImage.
  ///
  /// PENTING: balikin null (bukan string kosong '') kalau tidak ada foto.
  /// Image.network('') akan CRASH dengan error "Invalid argument(s): No
  /// host specified in URI file:///" -- jadi null di sini wajib supaya
  /// widget yang manggil bisa cek `if (url != null)` dengan benar.
  static String? assetUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) return null;
    if (relativePath.startsWith('http')) return relativePath;

    var path = relativePath.startsWith('/') ? relativePath : '/$relativePath';

    // Tambahkan '/storage/' kalau belum ada -- lihat catatan di atas soal
    // kenapa mayoritas field foto dari backend butuh ini ditambahkan manual.
    if (!path.startsWith('/storage/')) {
      path = '/storage$path';
    }

    return '$_host$path';
  }

  // ---------------------------------------------------------------------
  // AUTH
  // ---------------------------------------------------------------------
  static const String register = '/auth/register';
  static const String registerWithFace = '/auth/register-with-face';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // ---------------------------------------------------------------------
  // FACE RECOGNITION
  // ---------------------------------------------------------------------
  static const String faceProfiles = '/face/profiles';
  static const String faceLogin = '/face/login';
  static const String faceRegister = '/face/register';

  // ---------------------------------------------------------------------
  // PROFILE
  // ---------------------------------------------------------------------
  static const String profile = '/profile';
  static const String changeEmail = '/profile/change-email';
  static const String changePassword = '/profile/change-password';

  // ---------------------------------------------------------------------
  // TASK / INTERN
  // ---------------------------------------------------------------------
  static const String internTasks = '/intern/tasks';
  static const String tasks = '/tasks';
  static String taskStatus(String taskId) => '/tasks/$taskId/status';
  static String taskSubmit(String taskId) => '/tasks/$taskId/submit';
  // TODO: endpoint ini butuh Authorization header (JWT), jadi TIDAK BISA
  // dibuka langsung lewat url_launcher (browser luar tidak bawa token kita).
  // Untuk dipakai nanti, harus di-download dulu via Dio (dengan header
  // Authorization otomatis dari ApiClient) ke folder temp, baru dibuka
  // pakai package seperti open_file. Belum diimplementasikan di UI.
  static String taskAttachmentsZip(String taskId) =>
      '$baseUrl/tasks/$taskId/attachments/zip';

  // ---------------------------------------------------------------------
  // JOURNAL
  // ---------------------------------------------------------------------
  static const String journals = '/journals';
  static const String journalHistory = '/journals/history';
  static const String journalDatesTaken = '/journals/dates-taken';
  static String journalUpdate(String id) => '/journals/$id';
  static String journalApprove(String id) => '/journals/$id/approve';
  static String journalReject(String id) => '/journals/$id/reject';

  // ---------------------------------------------------------------------
  // ATTENDANCE
  // ---------------------------------------------------------------------
  static const String attendances = '/attendances';

  // ---------------------------------------------------------------------
  // SETTING
  // ---------------------------------------------------------------------
  static const String setting = '/setting';
}
