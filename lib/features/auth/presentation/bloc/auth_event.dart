part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Dipanggil saat splash screen / app start untuk cek apakah user
/// masih punya sesi login tersimpan (GET /auth/me).
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Daftar akun baru TANPA wajah (endpoint /auth/register).
/// Nanti kalau modul Face Recognition sudah siap, event ini akan diganti /
/// ditambah AuthRegisterWithFaceRequested yang menyertakan descriptors.
/// Sengaja dipisah dari AuthLoginRequested biar gampang di-swap nanti
/// tanpa mengubah bentuk form/UI.
class AuthRegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String? phone;
  final String password;
  final String passwordConfirmation;

  const AuthRegisterRequested({
    required this.name,
    required this.email,
    this.phone,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  List<Object?> get props => [name, email, phone, password, passwordConfirmation];
}
