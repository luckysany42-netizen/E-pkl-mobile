part of 'journal_bloc.dart';

abstract class JournalEvent extends Equatable {
  const JournalEvent();

  @override
  List<Object?> get props => [];
}

class JournalLoadRequested extends JournalEvent {
  const JournalLoadRequested();
}

/// Dipanggil saat halaman Tambah/Edit Jurnal dibuka, buat tahu tanggal mana
/// saja yang sudah punya jurnal (backend cuma izinkan 1 jurnal/tanggal/user).
class JournalDatesTakenLoadRequested extends JournalEvent {
  const JournalDatesTakenLoadRequested();
}

class JournalCreateRequested extends JournalEvent {
  final DateTime date;
  final List<JournalActivityModel> activities;
  final File? foto;

  const JournalCreateRequested({
    required this.date,
    required this.activities,
    this.foto,
  });

  @override
  List<Object?> get props => [date, activities, foto];
}

/// Edit jurnal yang SUDAH ADA. Tanggal tidak bisa diubah (makanya tidak ada
/// parameter date di sini) -- kalau user mau catat tanggal lain, itu jurnal
/// baru, bukan edit.
class JournalUpdateRequested extends JournalEvent {
  final int journalId;
  final List<JournalActivityModel> activities;
  final File? foto;

  const JournalUpdateRequested({
    required this.journalId,
    required this.activities,
    this.foto,
  });

  @override
  List<Object?> get props => [journalId, activities, foto];
}
