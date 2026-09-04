import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/language/app_strings.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import 'edit_profile_page.dart';
import 'security_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = state.user;
          final subtitle = user.posisi?.isNotEmpty == true
              ? user.posisi!
              : 'Siswa PKL';
          final school = user.asalInstansi?.isNotEmpty == true
              ? user.asalInstansi!
              : 'Asal sekolah belum diisi';

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
              children: [
                Text(
                  context.tr('profil'),
                  style: const TextStyle(
                    color: Color(0xFF111A31),
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 28),
                _ProfileHeader(
                  photoUrl: user.photoUrl,
                  name: user.name,
                  subtitle: subtitle,
                  school: school,
                ),
                const SizedBox(height: 28),
                const Text(
                  'Data Pribadi',
                  style: TextStyle(
                    color: Color(0xFF111A31),
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                _PersonalDataCard(
                  items: [
                    ('NIS', user.nimNis ?? '-'),
                    ('Email', user.email),
                    ('No Telepon', user.phone ?? '-'),
                  ],
                ),
                const SizedBox(height: 28),
                _ActionCard(
                  children: [
                    _ActionRow(
                      icon: Icons.manage_accounts_outlined,
                      label: 'Edit Profil',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfilePage(),
                          ),
                        );
                      },
                    ),
                    _ActionRow(
                      icon: Icons.no_encryption_outlined,
                      label: 'Keamanan Akun',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SecurityPage(),
                          ),
                        );
                      },
                    ),
                    _ActionRow(
                      icon: Icons.settings_outlined,
                      label: 'Pengaturan',
                      onTap: () => _showUnavailable(context, 'Pengaturan'),
                    ),
                    _ActionRow(
                      icon: Icons.logout_outlined,
                      label: 'Keluar',
                      isDestructive: true,
                      onTap: () {
                        context.read<AuthBloc>().add(
                              const AuthLogoutRequested(),
                            );
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showUnavailable(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label belum tersedia')),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String? photoUrl;
  final String name;
  final String subtitle;
  final String school;

  const _ProfileHeader({
    required this.photoUrl,
    required this.name,
    required this.subtitle,
    required this.school,
  });

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: const Color(0xFFD8DEE7),
            backgroundImage: photoUrl == null ? null : NetworkImage(photoUrl!),
            child: photoUrl == null
                ? const Icon(Icons.person, size: 48, color: Color(0xFF536176))
                : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF111A31),
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF536176),
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.business_outlined,
                      color: Color(0xFF2868EA),
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        school,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF2868EA),
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonalDataCard extends StatelessWidget {
  final List<(String, String)> items;

  const _PersonalDataCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    items[index].$1,
                    style: const TextStyle(
                      color: Color(0xFF536176),
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      items[index].$2,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        color: Color(0xFF111A31),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (index < items.length - 1)
              const Divider(height: 1, indent: 24, endIndent: 24),
          ],
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final List<Widget> children;

  const _ActionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index < children.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? const Color(0xFFFF3F46)
        : const Color(0xFF536176);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isDestructive
                      ? const Color(0xFFFF3F46)
                      : const Color(0xFF111A31),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: color, size: 28),
          ],
        ),
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _SurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDCE3EE)),
      ),
      child: child,
    );
  }
}
