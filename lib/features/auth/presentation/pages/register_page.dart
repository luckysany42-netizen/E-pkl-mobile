import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';

/// Halaman Daftar terpisah dari Login, tema sama (dark navy, KyPay-style).
///
/// Catatan penting: form ini SENGAJA belum menyertakan langkah ambil foto
/// wajah. Endpoint yang dipakai sekarang /auth/register (tanpa wajah).
/// Begitu modul Face Recognition siap, tambahkan 1 step kamera SEBELUM
/// tombol "Daftar" di bawah, lalu ganti event yang di-dispatch dari
/// AuthRegisterRequested ke AuthRegisterWithFaceRequested (event baru,
/// tinggal ditambah di auth_event.dart) — field-field di form ini tidak
/// perlu diubah sama sekali.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.authBackground,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade700,
              ),
            );
          }
          if (state is AuthRegisterSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registrasi berhasil! Silakan masuk.'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Buat Akun Baru',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Daftar sebagai intern E-PKL',
                            style: TextStyle(color: AppColors.authTextSecondary),
                          ),
                          const SizedBox(height: 28),
                          AuthTextField(
                            controller: _nameController,
                            label: 'Nama Lengkap',
                            icon: Icons.person_outline,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Nama wajib diisi'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          AuthTextField(
                            controller: _emailController,
                            label: 'Email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Email wajib diisi';
                              }
                              if (!v.contains('@')) return 'Format email tidak valid';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          AuthTextField(
                            controller: _phoneController,
                            label: 'No. HP (opsional)',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                          AuthTextField(
                            controller: _passwordController,
                            label: 'Password',
                            icon: Icons.lock_outline,
                            isPassword: true,
                            validator: (v) => (v == null || v.length < 8)
                                ? 'Password minimal 8 karakter'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          AuthTextField(
                            controller: _passwordConfirmController,
                            label: 'Konfirmasi Password',
                            icon: Icons.lock_outline,
                            isPassword: true,
                            validator: (v) => v != _passwordController.text
                                ? 'Konfirmasi password tidak cocok'
                                : null,
                          ),
                          const SizedBox(height: 28),
                          AuthButton(
                            label: 'Daftar',
                            isLoading: isLoading,
                            onPressed: () {
                              if (!_formKey.currentState!.validate()) return;
                              context.read<AuthBloc>().add(
                                    AuthRegisterRequested(
                                      name: _nameController.text.trim(),
                                      email: _emailController.text.trim(),
                                      phone: _phoneController.text.trim().isEmpty
                                          ? null
                                          : _phoneController.text.trim(),
                                      password: _passwordController.text,
                                      passwordConfirmation:
                                          _passwordConfirmController.text,
                                    ),
                                  );
                            },
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Sudah punya akun? ',
                                style: TextStyle(
                                  color: AppColors.authTextSecondary,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: const Text(
                                  'Masuk sekarang',
                                  style: TextStyle(
                                    color: AppColors.authAccent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
