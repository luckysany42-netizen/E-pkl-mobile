import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/language/app_language.dart';
import '../../../../core/language/app_strings.dart';
import '../../../../core/language/language_cubit.dart';
import '../../../../core/language/server_value_translator.dart';
import '../../../attendance/data/models/attendance_model.dart';
import '../../../attendance/presentation/bloc/attendance_bloc.dart';

enum _HistoryRange { week, month }

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  _HistoryRange _range = _HistoryRange.week;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    context.read<AttendanceBloc>().add(const AttendanceLoadRequested());
  }

  Future<void> _handleCheckIn() async {
    final photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (photo == null || !mounted) return;

    context.read<AttendanceBloc>().add(
          AttendanceCheckInRequested(File(photo.path)),
        );
  }

  Future<void> _handleCheckOut() async {
    final photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (photo == null || !mounted) return;

    final bytes = await File(photo.path).readAsBytes();
    final base64Photo = 'data:image/jpeg;base64,${base64Encode(bytes)}';

    if (!mounted) return;
    context.read<AttendanceBloc>().add(
          AttendanceCheckOutRequested(base64Photo),
        );
  }

  List<AttendanceModel> _filterHistory(List<AttendanceModel> history) {
    final now = DateTime.now();
    if (_range == _HistoryRange.week) {
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startDate =
          DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      return history.where((a) => !a.date.isBefore(startDate)).toList();
    } else {
      final startOfMonth = DateTime(now.year, now.month, 1);
      return history.where((a) => !a.date.isBefore(startOfMonth)).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: BlocConsumer<AttendanceBloc, AttendanceState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            }
          },
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<AttendanceBloc>()
                    .add(const AttendanceLoadRequested());
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const _TopBar(),
                  const SizedBox(height: 20),
                  Text(
                    context.tr('pilih_kehadiran'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _AttendanceActionCard(
                          color: const Color(0xFF3B82F6),
                          icon: Icons.wb_sunny_outlined,
                          title: context.tr('masuk'),
                          subtitle: context.tr('presensi_pagi'),
                          enabled: !(state.today?.hasCheckedIn ?? false),
                          isLoading: state.isSubmitting,
                          onTap: _handleCheckIn,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _AttendanceActionCard(
                          color: const Color(0xFFF59E0B),
                          icon: Icons.wb_twilight_outlined,
                          title: context.tr('pulang'),
                          subtitle: context.tr('presensi_sore'),
                          enabled: (state.today?.hasCheckedIn ?? false) &&
                              !(state.today?.hasCheckedOut ?? false),
                          isLoading: state.isSubmitting,
                          onTap: _handleCheckOut,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Fitur izin/sakit: endpoint backend belum ada, jadi
                  // tombol ini nonaktif dulu (coming soon) sesuai keputusan
                  // produk. Begitu endpoint /attendances/leave (atau serupa)
                  // dibuat di Laravel, tinggal aktifkan onTap di sini.
                  _ComingSoonBanner(
                    icon: Icons.block,
                    title: context.tr('absensi_izin_sakit'),
                    subtitle: context.tr('ketidakhadiran_perizinan'),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _range == _HistoryRange.week
                              ? context.tr('kehadiran_minggu_ini')
                              : context.tr('kehadiran_bulan_ini'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _RangeToggle(
                        range: _range,
                        onChanged: (r) => setState(() => _range = r),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (state.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    _HistoryList(items: _filterHistory(state.history)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // TODO: ganti dengan logo asli E-PKL (Image.asset).
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.school_rounded, color: Colors.white, size: 22),
        ),
        BlocBuilder<LanguageCubit, AppLanguage>(
          builder: (context, lang) {
            return GestureDetector(
              onTap: () => context.read<LanguageCubit>().toggle(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(lang == AppLanguage.id
                        ? '\u{1F1EE}\u{1F1E9}'
                        : '\u{1F1EC}\u{1F1E7}'),
                    const SizedBox(width: 6),
                    Text(
                      lang == AppLanguage.id ? 'Ind' : 'Eng',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Icon(Icons.keyboard_arrow_down, size: 18),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _AttendanceActionCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final bool isLoading;
  final VoidCallback onTap;

  const _AttendanceActionCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: enabled && !isLoading ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: Colors.white, size: 28),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ComingSoonBanner extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ComingSoonBanner({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.6,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFEF5350),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                context.tr('segera_hadir'),
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RangeToggle extends StatelessWidget {
  final _HistoryRange range;
  final ValueChanged<_HistoryRange> onChanged;

  const _RangeToggle({required this.range, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _rangeChip(context, _HistoryRange.week, context.tr('toggle_minggu')),
          _rangeChip(context, _HistoryRange.month, context.tr('toggle_bulan')),
        ],
      ),
    );
  }

  Widget _rangeChip(BuildContext context, _HistoryRange value, String label) {
    final selected = value == range;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  final List<AttendanceModel> items;

  const _HistoryList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            context.tr('belum_ada_riwayat'),
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final lang = context.watch<LanguageCubit>().state;
    final dateFormat = DateFormat('EEEE, dd/MM/yyyy', 'id_ID');

    return Column(
      children: items.expand((a) sync* {
        if (a.hasCheckedIn) {
          yield _HistoryTile(
            label: 'LURING - IN',
            statusLabel: ServerValueTranslator.t(a.status, lang),
            dateText: '${dateFormat.format(a.date)} ${a.checkInTime}',
          );
        }
        if (a.hasCheckedOut) {
          yield _HistoryTile(
            label: 'LURING - OUT',
            statusLabel: ServerValueTranslator.t(a.status, lang),
            dateText: '${dateFormat.format(a.date)} ${a.checkOutTime}',
          );
        }
      }).toList(),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final String label;
  final String statusLabel;
  final String dateText;

  const _HistoryTile({
    required this.label,
    required this.statusLabel,
    required this.dateText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dateText,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
