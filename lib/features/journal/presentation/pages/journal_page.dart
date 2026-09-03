import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/language/app_language.dart';
import '../../../../core/language/app_strings.dart';
import '../../../../core/language/language_cubit.dart';
import '../../../../core/language/server_value_translator.dart';
import '../../data/models/journal_model.dart';
import '../bloc/journal_bloc.dart';
import 'create_journal_page.dart';
import 'edit_journal_page.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  @override
  void initState() {
    super.initState();
    context.read<JournalBloc>().add(const JournalLoadRequested());
  }

  void _openEdit(JournalModel journal) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<JournalBloc>(),
          child: EditJournalPage(journal: journal),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(title: Text(context.tr('jurnal'))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<JournalBloc>(),
                child: const CreateJournalPage(),
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(context.tr('tambah_jurnal')),
      ),
      body: BlocConsumer<JournalBloc, JournalState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.history.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.history.isEmpty) {
            return Center(
              child: Text(
                context.tr('belum_ada_jurnal'),
                style: const TextStyle(color: Colors.grey),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<JournalBloc>().add(const JournalLoadRequested());
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              itemCount: state.history.length,
              itemBuilder: (context, index) {
                return _JournalCard(
                  journal: state.history[index],
                  onEdit: () => _openEdit(state.history[index]),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _JournalCard extends StatelessWidget {
  final JournalModel journal;
  final VoidCallback onEdit;

  const _JournalCard({required this.journal, required this.onEdit});

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return const Color(0xFF22C55E);
      case 'rejected':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageCubit>().state;
    final dateFormat = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showDetail(context, journal, lang, onEdit),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        dateFormat.format(journal.date),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor(journal.status).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        ServerValueTranslator.t(journal.status, lang),
                        style: TextStyle(
                          color: _statusColor(journal.status),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    // Tombol Edit selalu tampil (mengganti pola "Detail" di
                    // web) -- edit diizinkan di status APAPUN, termasuk
                    // approved/rejected (backend otomatis balikin ke
                    // pending kalau itu terjadi).
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      tooltip: context.tr('edit'),
                      onPressed: onEdit,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                Text(
                  '${journal.activities.length} ${context.tr('aktivitas')}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                if (journal.wasEdited) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${context.tr('diedit_pada')} '
                    '${DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(journal.lastEditedAt!)}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetail(
    BuildContext context,
    JournalModel journal,
    AppLanguage lang,
    VoidCallback onEdit,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: scrollController,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(journal.date),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop(); // tutup bottom sheet dulu
                          onEdit();
                        },
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: Text(context.tr('edit')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ServerValueTranslator.t(journal.status, lang),
                    style: TextStyle(
                      color: _statusColor(journal.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (journal.wasEdited) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${context.tr('diedit_pada')} '
                      '${DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(journal.lastEditedAt!)}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  if (journal.status == 'rejected' &&
                      journal.catatanApproval != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('catatan_penolakan'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(journal.catatanApproval!),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (journal.fotoUrl != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(journal.fotoUrl!, height: 160, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 16),
                  ],
                  ...journal.activities.map(
                    (a) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 90,
                            child: Text(
                              '${a.jamMulai}-${a.jamSelesai}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Expanded(child: Text(a.kegiatan)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
