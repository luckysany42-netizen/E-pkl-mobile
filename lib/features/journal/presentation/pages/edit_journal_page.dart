import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/language/app_strings.dart';
import '../../data/models/journal_activity_model.dart';
import '../../data/models/journal_model.dart';
import '../bloc/journal_bloc.dart';
import '../widgets/journal_form_widgets.dart';

/// Edit jurnal yang SUDAH ADA. Tanggal tidak bisa diubah (kalau mau catat
/// tanggal lain, itu jurnal baru lewat Tambah Jurnal, bukan edit).
///
/// Kalau status jurnal ini sebelumnya approved/rejected, backend OTOMATIS
/// mengembalikan status ke pending setelah edit berhasil -- itu ditangani
/// sepenuhnya di backend (JournalController::update()), tidak perlu logic
/// tambahan di sisi app selain menampilkan pesannya.
class EditJournalPage extends StatefulWidget {
  final JournalModel journal;

  const EditJournalPage({super.key, required this.journal});

  @override
  State<EditJournalPage> createState() => _EditJournalPageState();
}

class _EditJournalPageState extends State<EditJournalPage> {
  late final List<ActivityFormRow> _activities;
  File? _newFoto;
  final _picker = ImagePicker();

  // Loading tombol dikontrol LOKAL + safety timer, pola sama seperti
  // create_journal_page.dart & submit_task_sheet.dart -- jaga-jaga request
  // macet di jaringan (walau sendTimeout Dio 60s sudah jadi lapis pertama).
  bool _isSubmitting = false;
  Timer? _safetyTimer;

  @override
  void initState() {
    super.initState();
    // Prefill dari data jurnal yang sudah ada.
    _activities = widget.journal.activities
        .map(
          (a) => ActivityFormRow(
            initialKegiatan: a.kegiatan,
            jamMulai: parseTimeOfDay(a.jamMulai),
            jamSelesai: parseTimeOfDay(a.jamSelesai),
          ),
        )
        .toList();
    if (_activities.isEmpty) _activities.add(ActivityFormRow());
  }

  @override
  void dispose() {
    for (final a in _activities) {
      a.dispose();
    }
    _safetyTimer?.cancel();
    super.dispose();
  }

  Future<void> _pickTime(ActivityFormRow row, bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: (isStart ? row.jamMulai : row.jamSelesai) ?? TimeOfDay.now(),
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
    if (photo != null) setState(() => _newFoto = File(photo.path));
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
        SnackBar(content: Text(context.trRead('lengkapi_minimal_1_aktivitas'))),
      );
      return;
    }

    debugPrint('[EditJournalPage] _submit() dipanggil, journalId=${widget.journal.id}');
    setState(() => _isSubmitting = true);

    _safetyTimer?.cancel();
    _safetyTimer = Timer(const Duration(seconds: 65), () {
      debugPrint('[EditJournalPage] SAFETY TIMER KEPICU (65 detik)');
      if (mounted && _isSubmitting) setState(() => _isSubmitting = false);
    });

    final activityModels = _activities
        .map(
          (a) => JournalActivityModel(
            jamMulai: formatTimeOfDay(a.jamMulai),
            jamSelesai: formatTimeOfDay(a.jamSelesai),
            kegiatan: a.kegiatanController.text.trim(),
          ),
        )
        .toList();

    debugPrint('[EditJournalPage] dispatch JournalUpdateRequested...');
    context.read<JournalBloc>().add(
          JournalUpdateRequested(
            journalId: widget.journal.id,
            activities: activityModels,
            foto: _newFoto, // null -> backend pertahankan foto lama
          ),
        );
    debugPrint('[EditJournalPage] event sudah di-dispatch');
  }

  @override
  Widget build(BuildContext context) {
    final wasDecided = widget.journal.status == 'approved' ||
        widget.journal.status == 'rejected';

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('edit_jurnal'))),
      body: BlocConsumer<JournalBloc, JournalState>(
        listenWhen: (prev, curr) =>
            curr.submitSuccess || curr.errorMessage != prev.errorMessage,
        listener: (context, state) {
          debugPrint('[EditJournalPage] LISTENER KEPANGGIL, submitSuccess=${state.submitSuccess}, error=${state.errorMessage}');
          _safetyTimer?.cancel();
          if (state.submitSuccess) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  wasDecided
                      ? context.trRead('jurnal_diperbarui_pending')
                      : context.trRead('jurnal_berhasil_disimpan'),
                ),
                backgroundColor: Colors.green,
              ),
            );
            debugPrint('[EditJournalPage] memanggil Navigator.pop()...');
            Navigator.of(context).pop();
            debugPrint('[EditJournalPage] Navigator.pop() selesai dipanggil');
          } else if (state.errorMessage != null) {
            setState(() => _isSubmitting = false);
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
                  if (wasDecided)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange.shade800, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              context.tr('peringatan_edit_reset_status'),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Text(
                    context.tr('tanggal'),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  // Tanggal READ-ONLY sengaja: bukan InkWell/date-picker,
                  // karena backend tidak izinkan ubah tanggal lewat edit.
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('dd MMMM yyyy', 'id_ID')
                              .format(widget.journal.date),
                        ),
                        const Icon(Icons.lock_outline, size: 16, color: Colors.grey),
                      ],
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
                            setState(() => _activities.add(ActivityFormRow())),
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(context.tr('tambah_aktivitas')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._activities.asMap().entries.map((entry) {
                    final index = entry.key;
                    final row = entry.value;
                    return ActivityFormCard(
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
                      fmtTime: formatTimeOfDay,
                    );
                  }),
                  const SizedBox(height: 12),
                  Text(
                    context.tr('foto_bukti_opsional'),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  if (_newFoto != null)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(_newFoto!, height: 140, width: double.infinity, fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            style: IconButton.styleFrom(backgroundColor: Colors.black45),
                            onPressed: () => setState(() => _newFoto = null),
                          ),
                        ),
                      ],
                    )
                  else if (widget.journal.fotoUrl != null)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            widget.journal.fotoUrl!,
                            height: 140,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              context.tr('foto_lama'),
                              style: const TextStyle(color: Colors.white, fontSize: 11),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    const SizedBox.shrink(),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _pickPhoto,
                    icon: const Icon(Icons.image_outlined),
                    label: Text(
                      widget.journal.fotoUrl != null || _newFoto != null
                          ? context.tr('ganti_foto')
                          : context.tr('pilih_foto'),
                    ),
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
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(context.tr('simpan_perubahan')),
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
