import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/profile_bloc.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final _emailFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailPasswordController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _emailPasswordController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        } else if (state.submitSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perubahan berhasil disimpan')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Keamanan Akun')),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'Ubah Email',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Form(
              key: _emailFormKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email baru',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || !value.contains('@')
                        ? 'Email tidak valid'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password saat ini',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Password wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!_emailFormKey.currentState!.validate()) return;
                        context.read<ProfileBloc>().add(
                              ProfileChangeEmailRequested(
                                newEmail: _emailController.text.trim(),
                                currentPassword:
                                    _emailPasswordController.text,
                              ),
                            );
                      },
                      child: const Text('Simpan Email'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            const Text(
              'Ubah Password',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Form(
              key: _passwordFormKey,
              child: Column(
                children: [
                  _passwordField(_currentPasswordController, 'Password saat ini'),
                  const SizedBox(height: 12),
                  _passwordField(
                    _newPasswordController,
                    'Password baru',
                    validator: (value) => value == null || value.length < 8
                        ? 'Minimal 8 karakter'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  _passwordField(
                    _confirmPasswordController,
                    'Konfirmasi password baru',
                    validator: (value) => value != _newPasswordController.text
                        ? 'Password tidak cocok'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!_passwordFormKey.currentState!.validate()) return;
                        context.read<ProfileBloc>().add(
                              ProfileChangePasswordRequested(
                                currentPassword:
                                    _currentPasswordController.text,
                                newPassword: _newPasswordController.text,
                                confirmPassword: _confirmPasswordController.text,
                              ),
                            );
                      },
                      child: const Text('Simpan Password'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _passwordField(
    TextEditingController controller,
    String label, {
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: validator ??
          (value) => value == null || value.isEmpty
              ? 'Password wajib diisi'
              : null,
    );
  }
}
