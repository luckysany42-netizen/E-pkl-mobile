import '../../../../core/network/result.dart';
import '../../data/models/user_model.dart';

/// Kontrak yang dipakai AuthBloc. Bloc tidak tahu (dan tidak peduli) apakah
/// implementasinya pakai Dio, GraphQL, atau mock buat testing.
abstract class AuthRepository {
  Future<Result<({UserModel user, String token})>> login({
    required String email,
    required String password,
  });

  /// Daftar akun baru tanpa wajah (endpoint /auth/register, deprecated di
  /// backend tapi masih aktif). Dipertahankan sebagai jalur sementara sampai
  /// modul Face Recognition siap, lalu diganti/ditambah register() yang
  /// menyertakan descriptors wajah (endpoint /auth/register-with-face).
  Future<Result<({UserModel user, String token})>> register({
    required String name,
    required String email,
    String? phone,
    required String nimNis,
    required String asalInstansi,
    required String password,
    required String passwordConfirmation,
  });

  /// Ambil data user yang sedang login dari server (GET /auth/me),
  /// dipakai buat validasi token tersimpan masih berlaku saat app dibuka lagi.
  Future<Result<UserModel>> getMe();

  Future<Result<void>> logout();
}
