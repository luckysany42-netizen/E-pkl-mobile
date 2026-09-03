import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/language/app_strings.dart';
import '../../data/models/journal_activity_model.dart';
import '../bloc/journal_bloc.dart';
import '../widgets/journal_form_widgets.dart';

class CreateJournalPage extends StatefulWidget {
  const CreateJournalPage({super.key});

  @override
  State<CreateJournalPage> createState() => _CreateJournalPageState();
}

class _CreateJournalPageState extends State<CreateJournalPage> {
  DateTime _date = DateTime.now();
  final List<ActivityFormRow> _activities = [ActivityFormRow()];
  File? _foto;
  final _picker = ImagePicker();

  // Loading tombol dikontrol LOKAL.
  // Safety timer menjamin tombol tidak menggantung selamanya
  // jika terjadi masalah jaringan yang tidak terduga.
  bool _isSubmitting = false;
  Timer? _safetyTimer;

  // Mencegah hasil submit yang sama diproses lebih dari satu kali.
  //
  // Ini adalah safety guard tambahan supaya Navigator.pop()
  // tidak pernah dipanggil dua kali untuk satu proses submit.
  bool _hasHandledSubmitResult = false;

  @override
  void initState() {
    super.initState();

    // Ambil daftar tanggal yang sudah punya jurnal, buat di-disable
    // di date picker.
    context.read<JournalBloc>().add(
          const JournalDatesTakenLoadRequested(),
        );
  }

  @override
  void dispose() {
    for (final a in _activities) {
      a.dispose();
    }

    _safetyTimer?.cancel();

    super.dispose();
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year &&
      a.month == b.month &&
      a.day == b.day;

  Future<void> _pickDate(List<DateTime> datesTaken) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(
        const Duration(days: 30),
      ),
      // Jurnal untuk hari yang belum terjadi tidak masuk akal,
      // backend juga tidak melarang, tapi dibatasi di app.
      lastDate: DateTime.now(),
      // Tanggal yang SUDAH punya jurnal tidak bisa dipilih lagi.
      selectableDayPredicate: (day) =>
          !datesTaken.any(
            (taken) => _isSameDate(taken, day),
          ),
    );

    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _pickTime(
    ActivityFormRow row,
    bool isStart,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          (isStart ? row.jamMulai : row.jamSelesai) ??
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

    if (photo != null) {
      setState(() => _foto = File(photo.path));
    }
  }

  bool get _isValid {
    for (final a in _activities) {
      if (a.jamMulai == null ||
          a.jamSelesai == null ||
          a.kegiatanController.text.trim().isEmpty) {
        return false;
      }

      final startMinutes =
          a.jamMulai!.hour * 60 + a.jamMulai!.minute;

      final endMinutes =
          a.jamSelesai!.hour * 60 + a.jamSelesai!.minute;

      if (endMinutes <= startMinutes) {
        return false;
      }
    }

    return _activities.isNotEmpty;
  }

  void _submit() {
    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.trRead(
              'lengkapi_minimal_1_aktivitas',
            ),
          ),
        ),
      );
      return;
    }

    debugPrint(
      '[CreateJournalPage] _submit() dipanggil, '
      'activities=${_activities.length}',
    );

    // Reset guard untuk proses submit baru.
    _hasHandledSubmitResult = false;

    setState(() => _isSubmitting = true);

    _safetyTimer?.cancel();

    _safetyTimer = Timer(
      const Duration(seconds: 65),
      () {
        debugPrint(
          '[CreateJournalPage] SAFETY TIMER KEPICU (65 detik)',
        );

        if (mounted && _isSubmitting) {
          setState(() => _isSubmitting = false);
        }
      },
    );

    final activityModels = _activities
        .map(
          (a) => JournalActivityModel(
            jamMulai: formatTimeOfDay(a.jamMulai),
            jamSelesai: formatTimeOfDay(a.jamSelesai),
            kegiatan:
                a.kegiatanController.text.trim(),
          ),
        )
        .toList();

    debugPrint(
      '[CreateJournalPage] dispatch JournalCreateRequested...',
    );

    context.read<JournalBloc>().add(
          JournalCreateRequested(
            date: _date,
            activities: activityModels,
            foto: _foto,
          ),
        );

    debugPrint(
      '[CreateJournalPage] event sudah di-dispatch',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('tambah_jurnal'),
        ),
      ),
      body: BlocConsumer<JournalBloc, JournalState>(
        // Hanya proses submitSuccess ketika terjadi transisi:
        //
        // false -> true
        //
        // Bukan:
        //
        // true -> true
        //
        // Ini mencegah listener terpanggil lagi ketika Bloc
        // melakukan refresh history setelah submit berhasil.
        listenWhen: (prev, curr) =>
            (!prev.submitSuccess &&
                curr.submitSuccess) ||
            curr.errorMessage != prev.errorMessage,

        listener: (context, state) {
          debugPrint(
            '[CreateJournalPage] LISTENER KEPANGGIL, '
            'submitSuccess=${state.submitSuccess}, '
            'error=${state.errorMessage}',
          );

          // Safety guard:
          // hasil submit yang sama tidak boleh diproses dua kali.
          if (_hasHandledSubmitResult) {
            debugPrint(
              '[CreateJournalPage] Result sudah ditangani, '
              'listener diabaikan.',
            );
            return;
          }

          if (state.submitSuccess) {
            // Tandai SEBELUM Navigator.pop().
            //
            // Penting: jangan menaruh ini setelah pop karena
            // perubahan navigation dapat menyebabkan lifecycle
            // berjalan sebelum kode berikutnya selesai.
            _hasHandledSubmitResult = true;

            _safetyTimer?.cancel();

            if (!mounted) return;

            setState(() => _isSubmitting = false);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  context.trRead(
                    'jurnal_berhasil_disimpan',
                  ),
                ),
                backgroundColor: Colors.green,
              ),
            );

            debugPrint(
              '[CreateJournalPage] memanggil Navigator.pop()...',
            );

            // HANYA BOLEH TERJADI SEKALI.
            Navigator.of(context).pop();

            debugPrint(
              '[CreateJournalPage] Navigator.pop() selesai dipanggil',
            );
          } else if (state.errorMessage != null) {
            _hasHandledSubmitResult = true;

            _safetyTimer?.cancel();

            if (!mounted) return;

            setState(() => _isSubmitting = false);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage!,
                ),
              ),
            );
          }
        },

        builder: (context, state) {
          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  100,
                ),
                children: [
                  Text(
                    context.tr('tanggal'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  InkWell(
                    onTap: () => _pickDate(
                      state.datesTaken,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat(
                              'dd MMMM yyyy',
                              'id_ID',
                            ).format(_date),
                          ),
                          const Icon(
                            Icons.calendar_today,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.tr('aktivitas'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      TextButton.icon(
                        onPressed: () {
                          setState(
                            () => _activities.add(
                              ActivityFormRow(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.add,
                          size: 18,
                        ),
                        label: Text(
                          context.tr(
                            'tambah_aktivitas',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  ..._activities
                      .asMap()
                      .entries
                      .map((entry) {
                    final index = entry.key;
                    final row = entry.value;

                    return ActivityFormCard(
                      row: row,
                      index: index,
                      canDelete:
                          _activities.length > 1,
                      onDelete: () {
                        setState(() {
                          row.dispose();
                          _activities.removeAt(index);
                        });
                      },
                      onPickTime: (isStart) =>
                          _pickTime(row, isStart),
                      fmtTime: formatTimeOfDay,
                    );
                  }),

                  const SizedBox(height: 12),

                  Text(
                    context.tr(
                      'foto_bukti_opsional',
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  if (_foto != null)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(10),
                          child: Image.file(
                            _foto!,
                            height: 140,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),

                        Positioned(
                          top: 4,
                          right: 4,
                          child: IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                            style:
                                IconButton.styleFrom(
                              backgroundColor:
                                  Colors.black45,
                            ),
                            onPressed: () {
                              setState(
                                () => _foto = null,
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: _pickPhoto,
                      icon: const Icon(
                        Icons.image_outlined,
                      ),
                      label: Text(
                        context.tr(
                          'pilih_foto',
                        ),
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
                    onPressed:
                        _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            context.tr(
                              'simpan_jurnal',
                            ),
                          ),
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