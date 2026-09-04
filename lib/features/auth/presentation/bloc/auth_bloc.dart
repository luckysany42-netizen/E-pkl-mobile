import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Pesan ditampilkan kalau akun yang login bukan role intern. Role selain
/// 'karyawan' (hr-admin, atasan) SENGAJA ditolak di mobile — akses mereka
/// cuma lewat web, sesuai keputusan produk.
const _kNonInternRoleMessage =
    'Akun ini bukan akun intern. Silakan gunakan website untuk mengakses '
    'sebagai Admin/Atasan.';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  /// true kalau user BOLEH masuk ke app mobile ini (harus intern/karyawan).
  /// Kalau user belum pernah dapat role apapun (roles kosong), tetap
  /// diizinkan — kasus akun baru daftar sendiri yang defaultnya karyawan
  /// tapi assignment role-nya mungkin async di backend.
  bool _isAllowedOnMobile(UserModel user) {
    if (user.roles.isEmpty) return true;
    return user.isIntern;
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _authRepository.getMe();

    if (result.isSuccess) {
      final user = result.data!;
      if (!_isAllowedOnMobile(user)) {
        await _authRepository.logout();
        emit(const AuthFailure(_kNonInternRoleMessage));
        return;
      }
      emit(AuthAuthenticated(user));
    } else {
      // Gagal ambil /auth/me artinya token tidak ada / sudah expired /
      // invalid -> anggap belum login, arahkan ke halaman login.
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _authRepository.login(
      email: event.email,
      password: event.password,
    );

    if (result.isSuccess) {
      final user = result.data!.user;
      if (!_isAllowedOnMobile(user)) {
        await _authRepository.logout();
        emit(const AuthFailure(_kNonInternRoleMessage));
        return;
      }
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthFailure(result.errorMessage ?? 'Login gagal'));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _authRepository.register(
      name: event.name,
      email: event.email,
      phone: event.phone,
      nimNis: event.nimNis,
      asalInstansi: event.asalInstansi,
      password: event.password,
      passwordConfirmation: event.passwordConfirmation,
    );

    if (result.isSuccess) {
      // SENGAJA tidak emit AuthAuthenticated di sini (lihat dokumentasi di
      // AuthRegisterSuccess). Backend sebenarnya balikin token yang valid,
      // tapi repository.register() sudah diubah untuk TIDAK menyimpannya
      // (lihat auth_repository_impl.dart), jadi user harus login manual.
      emit(const AuthRegisterSuccess());
      emit(const AuthUnauthenticated());
    } else {
      emit(AuthFailure(result.errorMessage ?? 'Registrasi gagal'));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(const AuthUnauthenticated());
  }
}
