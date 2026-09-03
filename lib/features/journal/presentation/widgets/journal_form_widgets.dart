import 'package:flutter/material.dart';

import '../../../../core/language/app_strings.dart';

/// Form field lokal (belum tentu valid), dibedain dari JournalActivityModel
/// yang dikirim ke API supaya gampang nge-track TextEditingController per
/// baris tanpa bikin ulang widget tiap kali user ngetik.
class ActivityFormRow {
  final TextEditingController kegiatanController;
  TimeOfDay? jamMulai;
  TimeOfDay? jamSelesai;

  ActivityFormRow({
    String? initialKegiatan,
    this.jamMulai,
    this.jamSelesai,
  }) : kegiatanController = TextEditingController(text: initialKegiatan ?? '');

  void dispose() => kegiatanController.dispose();
}

class ActivityFormCard extends StatelessWidget {
  final ActivityFormRow row;
  final int index;
  final bool canDelete;
  final VoidCallback onDelete;
  final void Function(bool isStart) onPickTime;
  final String Function(TimeOfDay?) fmtTime;

  const ActivityFormCard({
    super.key,
    required this.row,
    required this.index,
    required this.canDelete,
    required this.onDelete,
    required this.onPickTime,
    required this.fmtTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${context.tr('aktivitas')} ${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              if (canDelete)
                InkWell(
                  onTap: onDelete,
                  child: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TimeField(
                  label: context.tr('jam_mulai'),
                  value: fmtTime(row.jamMulai),
                  onTap: () => onPickTime(true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TimeField(
                  label: context.tr('jam_selesai'),
                  value: fmtTime(row.jamSelesai),
                  onTap: () => onPickTime(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: row.kegiatanController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: context.tr('kegiatan'),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}

class TimeField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const TimeField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

/// Helper format "HH:mm" dari TimeOfDay, dipakai Create & Edit page.
String formatTimeOfDay(TimeOfDay? t) {
  if (t == null) return '--:--';
  return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

/// Parse "HH:mm" (string dari backend) balik jadi TimeOfDay, dipakai buat
/// prefill form Edit dari data jurnal yang sudah ada.
TimeOfDay? parseTimeOfDay(String value) {
  final parts = value.split(':');
  if (parts.length < 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  return TimeOfDay(hour: hour, minute: minute);
}
