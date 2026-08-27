part of 'attendance_bloc.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

/// Dipanggil saat halaman Beranda dibuka: ambil status hari ini + riwayat.
class AttendanceLoadRequested extends AttendanceEvent {
  const AttendanceLoadRequested();
}

class AttendanceCheckInRequested extends AttendanceEvent {
  final File photo;

  const AttendanceCheckInRequested(this.photo);

  @override
  List<Object?> get props => [photo];
}

class AttendanceCheckOutRequested extends AttendanceEvent {
  final String base64Photo;

  const AttendanceCheckOutRequested(this.base64Photo);

  @override
  List<Object?> get props => [base64Photo];
}
