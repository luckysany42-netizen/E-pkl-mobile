import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

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
        connectTimeout: const Duration(seconds: 20),
        // receiveTimeout: waktu tunggu BALASAN dari server. Dinaikkan dari
        // 15s -> 30s karena proses submit tugas/jurnal di backend butuh
        // waktu (hapus file lama, simpan file baru, generate URL, dst),
        // apalagi kalau banyak lampiran sekaligus.
        receiveTimeout: const Duration(seconds: 30),
        // sendTimeout: SEBELUMNYA TIDAK ADA SAMA SEKALI -- ini bug utama
        // yang bikin "loading tak berhenti" saat upload foto/file macet di
        // jaringan lambat. Tanpa batas ini, kalau koneksi lag/putus di
        // tengah proses KIRIM data (bukan nunggu balasan), request bisa
        // menggantung selamanya: tidak sukses, tidak juga gagal, sehingga
        // tombol loading tidak akan pernah berhenti. Dengan sendTimeout,
        // Dio otomatis melempar error setelah waktu ini, yang lalu
        // ditangani repository (Result.failure) dan bloc (clear loading
        // state + tampilkan pesan error) -- jadi UI dijamin tidak
        // menggantung selamanya.
        sendTimeout: const Duration(seconds: 60),
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
          debugPrint('[Dio] --> ${options.method} ${options.uri}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('[Dio] <-- ${response.statusCode} ${response.requestOptions.uri}');
          handler.next(response);
        },
        onError: (error, handler) async {
          debugPrint('[Dio] XXX ERROR ${error.type} ${error.requestOptions.uri}: ${error.message}');
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
