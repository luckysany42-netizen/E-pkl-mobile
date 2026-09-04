import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../data/models/leave_request_model.dart';
import '../bloc/leave_bloc.dart';

class LeavePage extends StatefulWidget {
  const LeavePage({super.key});

  @override
  State<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> {
  @override
  void initState() {
    super.initState();
    context.read<LeaveBloc>().add(const LeaveLoadRequested());
  }

  Future<void> _openForm() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LeaveFormPage()),
    );
    if (mounted) context.read<LeaveBloc>().add(const LeaveLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Izin Saya')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        icon: const Icon(Icons.add),
        label: const Text('Ajukan Izin'),
      ),
      body: BlocBuilder<LeaveBloc, LeaveState>(
        builder: (context, state) {
          if (state.isLoading && state.requests.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.requests.isEmpty) {
            return const Center(child: Text('Belum ada pengajuan izin'));
          }
          return RefreshIndicator(
            onRefresh: () async => context
                .read<LeaveBloc>()
                .add(const LeaveLoadRequested()),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.requests.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, index) => _LeaveCard(state.requests[index]),
            ),
          );
        },
      ),
    );
  }
}

class LeaveFormPage extends StatefulWidget {
  const LeaveFormPage({super.key});

  @override
  State<LeaveFormPage> createState() => _LeaveFormPageState();
}

class _LeaveFormPageState extends State<LeaveFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  DateTime? _date;
  String _reasonType = 'tanpa_keterangan';
  File? _attachment;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _chooseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _chooseAttachment() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    final path = result?.files.single.path;
    if (path != null) setState(() => _attachment = File(path));
  }

  void _submit() {
    if (!_formKey.currentState!.validate() || _date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal izin wajib dipilih')),
      );
      return;
    }
    if (_reasonType == 'sakit' && _attachment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lampiran surat dokter wajib dipilih')),
      );
      return;
    }
    context.read<LeaveBloc>().add(LeaveCreateRequested(
          date: _date!,
          reasonType: _reasonType,
          note: _noteController.text,
          attachment: _attachment,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LeaveBloc, LeaveState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
        if (state.createSuccess) Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Ajukan Izin')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              OutlinedButton.icon(
                onPressed: _chooseDate,
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text(_date == null
                    ? 'Pilih tanggal izin'
                    : DateFormat('dd MMMM yyyy', 'id_ID').format(_date!)),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: _reasonType,
                decoration: const InputDecoration(
                  labelText: 'Alasan',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'tanpa_keterangan',
                    child: Text('Tanpa keterangan'),
                  ),
                  DropdownMenuItem(
                    value: 'sakit',
                    child: Text('Sakit'),
                  ),
                  DropdownMenuItem(
                    value: 'acara_keluarga',
                    child: Text('Acara keluarga'),
                  ),
                ],
                onChanged: (value) => setState(() => _reasonType = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Catatan (opsional)',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_reasonType == 'sakit') ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _chooseAttachment,
                  icon: const Icon(Icons.attach_file),
                  label: Text(_attachment == null
                      ? 'Pilih surat dokter'
                      : 'Lampiran dipilih'),
                ),
              ],
              const SizedBox(height: 28),
              BlocBuilder<LeaveBloc, LeaveState>(
                builder: (context, state) => ElevatedButton(
                  onPressed: state.isSubmitting ? null : _submit,
                  child: state.isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text('Kirim Pengajuan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeaveCard extends StatelessWidget {
  final LeaveRequestModel request;

  const _LeaveCard(this.request);

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (request.status) {
      'approved' => Colors.green,
      'rejected' => Colors.red,
      _ => Colors.orange,
    };
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.12),
          child: Icon(Icons.event_note, color: statusColor),
        ),
        title: Text(DateFormat('dd MMM yyyy', 'id_ID').format(request.date)),
        subtitle: Text(_reasonLabel(request.reasonType)),
        trailing: Text(
          _statusLabel(request.status),
          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  String _reasonLabel(String value) => switch (value) {
        'sakit' => 'Sakit',
        'acara_keluarga' => 'Acara keluarga',
        _ => 'Tanpa keterangan',
      };

  String _statusLabel(String value) => switch (value) {
        'approved' => 'Disetujui',
        'rejected' => 'Ditolak',
        _ => 'Menunggu',
      };
}
