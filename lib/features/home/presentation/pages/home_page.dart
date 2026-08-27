import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';

/// Halaman sederhana buat validasi: kalau ini muncul dengan data user yang
/// benar, berarti alur login -> simpan token -> /auth/me sudah jalan semua.
/// Nanti halaman ini diganti jadi dashboard beneran (dengan tab attendance,
/// journal, task, dll) setelah fitur-fitur itu dibuat.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-PKL Mobile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = state.user;

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: user.photoUrl != null
                        ? NetworkImage(user.photoUrl!)
                        : null,
                    child: user.photoUrl == null
                        ? const Icon(Icons.person, size: 40)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(user.email),
                  const SizedBox(height: 8),
                  if (user.roles.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: user.roles
                          .map((r) => Chip(label: Text(r)))
                          .toList(),
                    ),
                  const SizedBox(height: 8),
                  Text('Status: ${user.status}'),
                  if (user.posisi != null) Text('Posisi: ${user.posisi}'),
                  if (user.tanggalMulai != null)
                    Text(
                      'Periode: ${user.tanggalMulai!.toString().split(' ').first} '
                      's/d ${user.tanggalSelesai?.toString().split(' ').first ?? '-'}',
                    ),
                  const SizedBox(height: 24),
                  const Text(
                    '\u2705 Login & sesi JWT berhasil tervalidasi.\n'
                    'Fitur attendance, journal, task menyusul.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
