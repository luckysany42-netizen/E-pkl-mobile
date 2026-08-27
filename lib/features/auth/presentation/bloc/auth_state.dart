part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserModel user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Dipancarkan sesaat setelah Daftar berhasil (SEBELUM AuthUnauthenticated).
/// Sengaja TIDAK auto-login: sesuai keputusan produk, user daftar dulu lalu
/// diarahkan balik ke form Login secara manual. RegisterPage dengar state
/// ini untuk nampilin snackbar sukses + pop kembali ke LoginPage.
class AuthRegisterSuccess extends AuthState {
  const AuthRegisterSuccess();
}
