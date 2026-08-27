import 'package:dio/dio.dart';

import '../constants/api_endpoints.dart';
import '../utils/storage_helper.dart';

/// Wrapper tipis di atas Dio.
/// Semua repository (auth, attendance, journal, dst) memakai instance ini
/// supaya base URL, header, dan token auth konsisten di satu tempat.
class ApiClient {
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          // WAJIB: backend Laravel pakai middleware EnsureApiJson yang
          // nge-abort(404) kalau request tidak wantsJson(). Tanpa header ini
          // SEMUA request bakal dapet 404 walau endpoint & datanya benar.
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await StorageHelper.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // Token JWT expired (24 jam) / invalid -> backend balikin 401.
          // Hapus token lokal biar UI tahu harus balik ke halaman login.
          // (Navigasi balik ke login ditangani oleh AuthBloc yang dengar
          // kondisi ini, bukan di sini, biar ApiClient tetap tidak tahu-menahu
          // soal UI/routing.)
          if (error.response?.statusCode == 401) {
            await StorageHelper.clearToken();
          }
          handler.next(error);
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._internal();

  late final Dio _dio;

  Dio get dio => _dio;
}
