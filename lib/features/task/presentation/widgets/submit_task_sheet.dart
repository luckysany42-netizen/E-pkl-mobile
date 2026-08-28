import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/language/app_strings.dart';
import '../bloc/task_bloc.dart';

/// Bottom sheet "Kumpulkan Tugas", mirip form di web: pilih file (gambar
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
  File? _file;
  String? _fileName;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    // Daftar ekstensi ini WAJIB sama persis dengan validasi backend
    // (TaskController::submit(): mimes:jpeg,png,jpg,webp,pdf,doc,docx,xls,xlsx,zip)
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'jpeg', 'png', 'jpg', 'webp', 'pdf', 'doc', 'docx', 'xls', 'xlsx', 'zip',
      ],
    );

    if (result == null || result.files.single.path == null) return;

    setState(() {
      _file = File(result.files.single.path!);
      _fileName = result.files.single.name;
    });
  }

  void _submit() {
    if (_file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('pilih_file_dulu'))),
      );
      return;
    }

    context.read<TaskBloc>().add(
          TaskSubmitRequested(
            taskId: widget.taskId,
            attachment: _file!,
            note: _noteController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskBloc, TaskState>(
      listenWhen: (prev, curr) =>
          curr.submitSuccess || curr.errorMessage != prev.errorMessage,
      listener: (context, state) {
        if (state.submitSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('tugas_berhasil_dikumpulkan')),
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
        final isSubmitting = state.processingTaskId == widget.taskId;

        return Padding(
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
              Text(
                context.tr('file_gambar_tugas'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: _pickFile,
                    child: Text(context.tr('pilih_file')),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _fileName ?? context.tr('tidak_ada_file_dipilih'),
                      style: TextStyle(
                        color: _fileName == null ? Colors.grey : Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
                      onPressed: isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: Text(context.tr('batal')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : _submit,
                      child: isSubmitting
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
        );
      },
    );
  }
}
