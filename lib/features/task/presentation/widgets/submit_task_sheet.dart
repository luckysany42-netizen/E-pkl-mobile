import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/language/app_strings.dart';
import '../bloc/task_bloc.dart';

/// Bottom sheet "Kumpulkan Tugas": pilih BANYAK file sekaligus (gambar
/// atau dokumen) + catatan opsional + tombol Kirim.
///
/// Dipanggil dengan showModalBottomSheet, HARUS di-wrap BlocProvider.value
/// dari pemanggil supaya TaskBloc yang sama (bukan instance baru) yang
/// dipakai -- lihat cara pakainya di task_page.dart.
class SubmitTaskSheet extends StatefulWidget {
  final int taskId;

  const SubmitTaskSheet({super.key, required this.taskId});

  @override
  State<SubmitTaskSheet> createState() => _SubmitTaskSheetState();
}

class _SubmitTaskSheetState extends State<SubmitTaskSheet> {
  final List<File> _files = [];
  final _noteController = TextEditingController();

  // Loading tombol ini SENGAJA dikontrol LOKAL (bukan cuma baca
  // state.processingTaskId dari bloc). Sebelumnya tombol "Kirim" bisa
  // loading tak berhenti kalau request upload macet di jaringan (lihat
  // fix sendTimeout di api_client.dart). Dengan flag lokal + timer
  // pengaman di bawah, tombol DIJAMIN berhenti loading maksimal ~65 detik
  // apapun yang terjadi di level network/bloc, jadi user tidak pernah
  // benar-benar "terjebak" walau ada masalah tak terduga lainnya.
  bool _isSubmitting = false;
  Timer? _safetyTimer;

  @override
  void dispose() {
    _noteController.dispose();
    _safetyTimer?.cancel();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    // Daftar ekstensi ini WAJIB sama persis dengan validasi backend
    // (TaskController::submit(): mimes:jpeg,png,jpg,webp,pdf,doc,docx,xls,xlsx,zip)
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: [
        'jpeg', 'png', 'jpg', 'webp', 'pdf', 'doc', 'docx', 'xls', 'xlsx', 'zip',
      ],
    );

    if (result == null) return;

    setState(() {
      _files.addAll(
        result.files.where((f) => f.path != null).map((f) => File(f.path!)),
      );
    });
  }

  void _removeFile(int index) {
    setState(() => _files.removeAt(index));
  }

  void _submit() {
    if (_files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.trRead('pilih_file_dulu'))),
      );
      return;
    }

    debugPrint('[SubmitTaskSheet] _submit() called, ${_files.length} files, taskId=${widget.taskId}');
    setState(() => _isSubmitting = true);

    // Pengaman terakhir: kalau entah kenapa listener di bawah tidak pernah
    // ter-trigger (misal edge-case yang belum kepikiran), paksa tombol
    // berhenti loading setelah 65 detik (5 detik lebih lama dari
    // sendTimeout Dio) supaya user tidak PERNAH benar-benar terjebak.
    _safetyTimer?.cancel();
    _safetyTimer = Timer(const Duration(seconds: 65), () {
      debugPrint('[SubmitTaskSheet] SAFETY TIMER FIRED (65s) -- listener tidak pernah kepanggil!');
      if (mounted && _isSubmitting) setState(() => _isSubmitting = false);
    });

    context.read<TaskBloc>().add(
          TaskSubmitRequested(
            taskId: widget.taskId,
            attachments: _files,
            note: _noteController.text,
          ),
        );
    debugPrint('[SubmitTaskSheet] event dispatched to bloc');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskBloc, TaskState>(
      listenWhen: (prev, curr) =>
          curr.submitSuccess || curr.errorMessage != prev.errorMessage,
      listener: (context, state) {
        _safetyTimer?.cancel();
        if (state.submitSuccess) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.trRead('tugas_berhasil_dikumpulkan')),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        } else if (state.errorMessage != null) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('kumpulkan_tugas'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr('file_gambar_tugas'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextButton.icon(
                  onPressed: _pickFiles,
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(context.tr('pilih_file')),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (_files.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  context.tr('tidak_ada_file_dipilih'),
                  style: const TextStyle(color: Colors.grey),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 160),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _files.length,
                  itemBuilder: (context, index) {
                    final file = _files[index];
                    final name = file.path.split('/').last;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.insert_drive_file_outlined, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          InkWell(
                            onTap: () => _removeFile(index),
                            child: const Icon(Icons.close, size: 18, color: Colors.red),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            Text(
              context.tr('catatan_opsional'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: context.tr('catatan_placeholder'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: Text(context.tr('batal')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(context.tr('kirim')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
