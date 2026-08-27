import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/language/app_strings.dart';
import '../../data/models/journal_activity_model.dart';
import '../bloc/journal_bloc.dart';

/// Form field lokal (belum tentu valid), dibedain dari JournalActivityModel
/// yang dikirim ke API supaya gampang nge-track TextEditingController per
/// baris tanpa bikin ulang widget tiap kali user ngetik.
class _ActivityFormRow {
  final TextEditingController kegiatanController = TextEditingController();
  TimeOfDay? jamMulai;
  TimeOfDay? jamSelesai;

  void dispose() => kegiatanController.dispose();
}

class CreateJournalPage extends StatefulWidget {
  const CreateJournalPage({super.key});

  @override
  State<CreateJournalPage> createState() => _CreateJournalPageState();
}

class _CreateJournalPageState extends State<CreateJournalPage> {
  DateTime _date = DateTime.now();
  final List<_ActivityFormRow> _activities = [_ActivityFormRow()];
  File? _foto;
  final _picker = ImagePicker();

  @override
  void dispose() {
    for (final a in _activities) {
      a.dispose();
    }
    super.dispose();
  }

  String _fmtTime(TimeOfDay? t) {
    if (t == null) return '--:--';
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      // Jurnal untuk hari yang belum terjadi tidak masuk akal, backend juga
      // tidak melarang, tapi dibatasi di app biar user tidak salah isi.
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime(_ActivityFormRow row, bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: (isStart ? row.jamMulai : row.jamSelesai) ??
          TimeOfDay.now(),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        row.jamMulai = picked;
      } else {
        row.jamSelesai = picked;
      }
    });
  }

  Future<void> _pickPhoto() async {
    final photo = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (photo != null) setState(() => _foto = File(photo.path));
  }

  bool get _isValid {
    for (final a in _activities) {
      if (a.jamMulai == null ||
          a.jamSelesai == null ||
          a.kegiatanController.text.trim().isEmpty) {
        return false;
      }
      final startMinutes = a.jamMulai!.hour * 60 + a.jamMulai!.minute;
      final endMinutes = a.jamSelesai!.hour * 60 + a.jamSelesai!.minute;
      if (endMinutes <= startMinutes) return false;
    }
    return _activities.isNotEmpty;
  }

  void _submit() {
    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('lengkapi_minimal_1_aktivitas'))),
      );
      return;
    }

    final activityModels = _activities
        .map(
          (a) => JournalActivityModel(
            jamMulai: _fmtTime(a.jamMulai),
            jamSelesai: _fmtTime(a.jamSelesai),
            kegiatan: a.kegiatanController.text.trim(),
          ),
        )
        .toList();

    context.read<JournalBloc>().add(
          JournalCreateRequested(
            date: _date,
            activities: activityModels,
            foto: _foto,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('tambah_jurnal'))),
      body: BlocConsumer<JournalBloc, JournalState>(
        listenWhen: (prev, curr) =>
            curr.submitSuccess || curr.errorMessage != prev.errorMessage,
        listener: (context, state) {
          if (state.submitSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.tr('jurnal_berhasil_disimpan')),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          } else if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                children: [
                  Text(
                    context.tr('tanggal'),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat('dd MMMM yyyy', 'id_ID').format(_date)),
                          const Icon(Icons.calendar_today, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.tr('aktivitas'),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextButton.icon(
                        onPressed: () =>
                            setState(() => _activities.add(_ActivityFormRow())),
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(context.tr('tambah_aktivitas')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._activities.asMap().entries.map((entry) {
                    final index = entry.key;
                    final row = entry.value;
                    return _ActivityFormCard(
                      row: row,
                      index: index,
                      canDelete: _activities.length > 1,
                      onDelete: () {
                        setState(() {
                          row.dispose();
                          _activities.removeAt(index);
                        });
                      },
                      onPickTime: (isStart) => _pickTime(row, isStart),
                      fmtTime: _fmtTime,
                    );
                  }),
                  const SizedBox(height: 12),
                  Text(
                    context.tr('foto_bukti_opsional'),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  if (_foto != null)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(_foto!, height: 140, width: double.infinity, fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            style: IconButton.styleFrom(backgroundColor: Colors.black45),
                            onPressed: () => setState(() => _foto = null),
                          ),
                        ),
                      ],
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: _pickPhoto,
                      icon: const Icon(Icons.image_outlined),
                      label: Text(context.tr('pilih_foto')),
                    ),
                ],
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: state.isSubmitting ? null : _submit,
                    child: state.isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(context.tr('simpan_jurnal')),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ActivityFormCard extends StatelessWidget {
  final _ActivityFormRow row;
  final int index;
  final bool canDelete;
  final VoidCallback onDelete;
  final void Function(bool isStart) onPickTime;
  final String Function(TimeOfDay?) fmtTime;

  const _ActivityFormCard({
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
                child: _TimeField(
                  label: context.tr('jam_mulai'),
                  value: fmtTime(row.jamMulai),
                  onTap: () => onPickTime(true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _TimeField(
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

class _TimeField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _TimeField({required this.label, required this.value, required this.onTap});

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
