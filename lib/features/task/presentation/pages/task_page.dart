import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/language/app_language.dart';
import '../../../../core/language/app_strings.dart';
import '../../../../core/language/language_cubit.dart';
import '../../../../core/language/server_value_translator.dart';
import '../../data/models/task_model.dart';
import '../bloc/task_bloc.dart';
import '../widgets/attachment_gallery.dart';
import '../widgets/submit_task_sheet.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(const TaskLoadRequested());
  }

  void _openSubmitSheet(int taskId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        // BlocProvider.value WAJIB di sini: bottom sheet punya context
        // terpisah dari halaman ini, tanpa ini TaskBloc.of(sheetContext)
        // tidak akan ketemu providernya.
        return BlocProvider.value(
          value: context.read<TaskBloc>(),
          child: SubmitTaskSheet(taskId: taskId),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(title: Text(context.tr('tugas'))),
      body: BlocConsumer<TaskBloc, TaskState>(
        listenWhen: (prev, curr) => curr.errorMessage != prev.errorMessage,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.tasks.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.tasks.isEmpty) {
            return Center(
              child: Text(
                context.tr('belum_ada_tugas'),
                style: const TextStyle(color: Colors.grey),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<TaskBloc>().add(const TaskLoadRequested());
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.tasks.length,
              itemBuilder: (context, index) {
                final task = state.tasks[index];
                return _TaskCard(
                  task: task,
                  isProcessing: state.processingTaskId == task.id,
                  onStatusChange: (newStatus) {
                    context.read<TaskBloc>().add(
                          TaskStatusUpdateRequested(
                            taskId: task.id,
                            status: newStatus,
                          ),
                        );
                  },
                  onSubmitTask: () => _openSubmitSheet(task.id),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final TaskModel task;
  final bool isProcessing;
  final ValueChanged<String> onStatusChange;
  final VoidCallback onSubmitTask;

  const _TaskCard({
    required this.task,
    required this.isProcessing,
    required this.onStatusChange,
    required this.onSubmitTask,
  });

  Color _statusColor(String status) {
    switch (status) {
      case 'selesai':
        return const Color(0xFF22C55E);
      case 'sedang':
        return const Color(0xFF3B82F6);
      case 'submitted':
        return const Color(0xFF8B5CF6);
      case 'ditolak':
        return const Color(0xFFEF4444);
      case 'revisi':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  bool _isOverdue() {
    if (task.dueDate == null || task.status == 'selesai') return false;
    final today = DateTime.now();
    final due = task.dueDate!;
    return DateTime(due.year, due.month, due.day)
        .isBefore(DateTime(today.year, today.month, today.day));
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageCubit>().state;
    final overdue = _isOverdue();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: overdue ? Border.all(color: Colors.red.shade200) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(task.status).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  ServerValueTranslator.t(task.status, lang),
                  style: TextStyle(
                    color: _statusColor(task.status),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          if (task.description != null && task.description!.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              task.description!,
              style: const TextStyle(color: Color(0xFF475569), fontSize: 13),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.event_outlined,
                size: 15,
                color: overdue ? Colors.red : Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                task.dueDate == null
                    ? context.tr('tidak_ada_batas_waktu')
                    : '${context.tr('batas_waktu')}: '
                        '${DateFormat('dd MMM yyyy', 'id_ID').format(task.dueDate!)}'
                        '${overdue ? ' (${context.tr('terlambat')})' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  color: overdue ? Colors.red : Colors.grey,
                  fontWeight: overdue ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),

          // Catatan review dari admin (ditolak/revisi) -- ditampilkan
          // supaya user tahu apa yang perlu diperbaiki sebelum submit ulang.
          if ((task.status == 'ditolak' || task.status == 'revisi') &&
              task.adminNote != null &&
              task.adminNote!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _statusColor(task.status).withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('catatan_admin'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _statusColor(task.status),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(task.adminNote!, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ],

          // Catatan yang user isi sendiri saat submit (ditampilkan di semua
          // status setelah pernah submit, biar user inget apa yang ditulis).
          if (task.submissionNote != null &&
              task.submissionNote!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '${context.tr('catatan_kamu')}: ${task.submissionNote}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],

          const SizedBox(height: 12),

          if (isProcessing)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else ...[
            // Toggle belum/sedang cuma relevan sebelum pernah submit.
            if (task.canToggleStatus)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showStatusPicker(context),
                  icon: const Icon(Icons.swap_horiz, size: 16),
                  label: Text(context.tr('ubah_status')),
                ),
              ),

            // Galeri lampiran cuma muncul kalau sudah pernah ada yang
            // dikumpulkan. Tap salah satu foto -> preview IN-APP (bukan
            // buka tab browser luar seperti sebelumnya).
            if (task.hasAttachments) ...[
              if (task.canToggleStatus) const SizedBox(height: 8),
              Text(
                context.tr('lihat_file_terkumpul'),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              TaskAttachmentGallery(attachments: task.attachments),
            ],

            // Kumpulkan/Submit ulang -- boleh dipakai di semua status
            // KECUALI 'selesai' (final, backend nolak kalau dipaksa).
            if (task.canSubmit) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onSubmitTask,
                  icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                  label: Text(context.tr('kumpulkan_tugas')),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  void _showStatusPicker(BuildContext context) {
    final lang = context.read<LanguageCubit>().state;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // HANYA belum/sedang -- backend TaskController::updateStatus() cuma
        // terima 2 nilai ini (validator: 'status' => 'required|in:belum,sedang').
        // 'selesai' HARUS lewat alur submit->review admin, tidak bisa
        // di-set manual oleh user, makanya sengaja tidak ada di daftar ini.
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['belum', 'sedang'].map((status) {
              final selected = status == task.status;
              return ListTile(
                leading: Icon(
                  selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: _statusColor(status),
                ),
                title: Text(ServerValueTranslator.t(status, lang)),
                onTap: () {
                  Navigator.of(context).pop();
                  if (!selected) onStatusChange(status);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
