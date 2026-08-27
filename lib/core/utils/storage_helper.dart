import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Simpan/ambil/hapus token login pakai secure storage (Keystore di Android),
/// jadi lebih aman dibanding SharedPreferences biasa.
class StorageHelper {
  StorageHelper._();

  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  static Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  static const _languageKey = 'app_language';

  static Future<String?> getLanguage() async {
    return _storage.read(key: _languageKey);
  }

  static Future<void> saveLanguage(String code) async {
    await _storage.write(key: _languageKey, value: code);
  }
}
