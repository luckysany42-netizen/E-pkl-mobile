import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_language.dart';
import 'language_cubit.dart';

/// Kamus terjemahan label UI (tombol, judul, dsb).
/// Cara nambah kata baru: tambah 1 key di sini, isi versi id & en-nya.
class AppStrings {
  AppStrings._();

  static const Map<String, Map<AppLanguage, String>> _dict = {
    'beranda': {AppLanguage.id: 'Beranda', AppLanguage.en: 'Home'},
    'tugas': {AppLanguage.id: 'Tugas', AppLanguage.en: 'Tasks'},
    'jurnal': {AppLanguage.id: 'Jurnal', AppLanguage.en: 'Journal'},
    'profil': {AppLanguage.id: 'Profil', AppLanguage.en: 'Profile'},
    'pilih_kehadiran': {
      AppLanguage.id: 'Pilih Kehadiran',
      AppLanguage.en: 'Select Attendance',
    },
    'progress_magang': {
      AppLanguage.id: 'Progress Magang',
      AppLanguage.en: 'Internship Progress',
    },
    'hari_ke': {AppLanguage.id: 'Hari ke', AppLanguage.en: 'Day'},
    'dari': {AppLanguage.id: 'dari', AppLanguage.en: 'of'},
    'selesai_pada': {
      AppLanguage.id: 'Selesai pada',
      AppLanguage.en: 'Ends on',
    },
    'masuk': {AppLanguage.id: 'Masuk', AppLanguage.en: 'Check In'},
    'pulang': {AppLanguage.id: 'Pulang', AppLanguage.en: 'Check Out'},
    'presensi_pagi': {
      AppLanguage.id: 'Presensi Pagi',
      AppLanguage.en: 'Morning Attendance',
    },
    'presensi_sore': {
      AppLanguage.id: 'Presensi Sore',
      AppLanguage.en: 'Evening Attendance',
    },
    'absensi_izin_sakit': {
      AppLanguage.id: 'Absensi / Izin / Sakit',
      AppLanguage.en: 'Absence / Leave / Sick',
    },
    'ketidakhadiran_perizinan': {
      AppLanguage.id: 'Absensi / Ketidakhadiran / Perizinan',
      AppLanguage.en: 'Absence / Time-off / Permission',
    },
    'segera_hadir': {
      AppLanguage.id: 'Segera Hadir',
      AppLanguage.en: 'Coming Soon',
    },
    'kehadiran_minggu_ini': {
      AppLanguage.id: 'Kehadiran Minggu ini',
      AppLanguage.en: 'This Week\'s Attendance',
    },
    'kehadiran_bulan_ini': {
      AppLanguage.id: 'Kehadiran Bulan ini',
      AppLanguage.en: 'This Month\'s Attendance',
    },
    'minggu_ini': {AppLanguage.id: 'Minggu Ini', AppLanguage.en: 'This Week'},
    'bulan_ini': {AppLanguage.id: 'Bulan Ini', AppLanguage.en: 'This Month'},
    // Versi PENDEK khusus dipakai di chip toggle kecil (bukan judul section),
    // supaya tidak overflow di layar sempit saat bahasa Inggris dipilih
    // ("This Week"/"This Month" kepanjangan untuk chip sekecil itu).
    'toggle_minggu': {AppLanguage.id: 'Minggu', AppLanguage.en: 'Week'},
    'toggle_bulan': {AppLanguage.id: 'Bulan', AppLanguage.en: 'Month'},
    'belum_ada_riwayat': {
      AppLanguage.id: 'Belum ada riwayat kehadiran',
      AppLanguage.en: 'No attendance history yet',
    },
    'email': {AppLanguage.id: 'Email', AppLanguage.en: 'Email'},
    'password': {AppLanguage.id: 'Password', AppLanguage.en: 'Password'},
    'konfirmasi_password': {
      AppLanguage.id: 'Konfirmasi Password',
      AppLanguage.en: 'Confirm Password',
    },
    'nama_lengkap': {
      AppLanguage.id: 'Nama Lengkap',
      AppLanguage.en: 'Full Name',
    },
    'no_hp_opsional': {
      AppLanguage.id: 'No. HP (opsional)',
      AppLanguage.en: 'Phone Number (optional)',
    },
    'masuk_ke_akun': {
      AppLanguage.id: 'Masuk ke akun kamu',
      AppLanguage.en: 'Sign in to your account',
    },
    'belum_punya_akun': {
      AppLanguage.id: 'Belum punya akun?',
      AppLanguage.en: 'Don\'t have an account?',
    },
    'daftar_sekarang': {
      AppLanguage.id: 'Daftar sekarang',
      AppLanguage.en: 'Register now',
    },
    'sudah_punya_akun': {
      AppLanguage.id: 'Sudah punya akun?',
      AppLanguage.en: 'Already have an account?',
    },
    'masuk_sekarang': {
      AppLanguage.id: 'Masuk sekarang',
      AppLanguage.en: 'Sign in now',
    },
    'buat_akun_baru': {
      AppLanguage.id: 'Buat Akun Baru',
      AppLanguage.en: 'Create New Account',
    },
    'status': {AppLanguage.id: 'Status', AppLanguage.en: 'Status'},
    'posisi': {AppLanguage.id: 'Posisi', AppLanguage.en: 'Position'},
    'periode': {AppLanguage.id: 'Periode', AppLanguage.en: 'Period'},
    'keluar': {AppLanguage.id: 'Keluar', AppLanguage.en: 'Log Out'},
    'ambil_foto': {
      AppLanguage.id: 'Ambil Foto Selfie',
      AppLanguage.en: 'Take Selfie',
    },
    'sudah_absen_masuk': {
      AppLanguage.id: 'Sudah absen masuk hari ini',
      AppLanguage.en: 'Already checked in today',
    },
    'sudah_absen_pulang': {
      AppLanguage.id: 'Sudah absen pulang hari ini',
      AppLanguage.en: 'Already checked out today',
    },
    'belum_absen_masuk': {
      AppLanguage.id: 'Absen masuk dulu sebelum absen pulang',
      AppLanguage.en: 'Check in first before checking out',
    },
    'tambah_jurnal': {
      AppLanguage.id: 'Tambah Jurnal',
      AppLanguage.en: 'Add Journal',
    },
    'belum_ada_jurnal': {
      AppLanguage.id: 'Belum ada jurnal',
      AppLanguage.en: 'No journal entries yet',
    },
    'tanggal': {AppLanguage.id: 'Tanggal', AppLanguage.en: 'Date'},
    'aktivitas': {AppLanguage.id: 'Aktivitas', AppLanguage.en: 'Activities'},
    'tambah_aktivitas': {
      AppLanguage.id: 'Tambah Aktivitas',
      AppLanguage.en: 'Add Activity',
    },
    'jam_mulai': {AppLanguage.id: 'Jam Mulai', AppLanguage.en: 'Start Time'},
    'jam_selesai': {AppLanguage.id: 'Jam Selesai', AppLanguage.en: 'End Time'},
    'kegiatan': {
      AppLanguage.id: 'Kegiatan',
      AppLanguage.en: 'Activity Description',
    },
    'foto_bukti_opsional': {
      AppLanguage.id: 'Foto Bukti (opsional)',
      AppLanguage.en: 'Proof Photo (optional)',
    },
    'simpan_jurnal': {
      AppLanguage.id: 'Simpan Jurnal',
      AppLanguage.en: 'Save Journal',
    },
    'jurnal_berhasil_disimpan': {
      AppLanguage.id: 'Jurnal berhasil disimpan',
      AppLanguage.en: 'Journal saved successfully',
    },
    'catatan_penolakan': {
      AppLanguage.id: 'Catatan Penolakan',
      AppLanguage.en: 'Rejection Note',
    },
    'tutup': {AppLanguage.id: 'Tutup', AppLanguage.en: 'Close'},
    'lengkapi_minimal_1_aktivitas': {
      AppLanguage.id: 'Lengkapi minimal 1 aktivitas dengan benar',
      AppLanguage.en: 'Complete at least 1 activity correctly',
    },
    'pilih_foto': {AppLanguage.id: 'Pilih Foto', AppLanguage.en: 'Pick Photo'},
    'kumpulkan_tugas': {
      AppLanguage.id: 'Kumpulkan Tugas',
      AppLanguage.en: 'Submit Task',
    },
    'lihat_file_terkumpul': {
      AppLanguage.id: 'Lihat File Terkumpul',
      AppLanguage.en: 'View Submitted File',
    },
    'catatan_kamu': {AppLanguage.id: 'Catatan kamu', AppLanguage.en: 'Your note'},
    'catatan_admin': {
      AppLanguage.id: 'Catatan Admin',
      AppLanguage.en: 'Admin Note',
    },
    'file_gambar_tugas': {
      AppLanguage.id: 'File / Gambar Tugas',
      AppLanguage.en: 'File / Task Image',
    },
    'pilih_file': {AppLanguage.id: 'Pilih File', AppLanguage.en: 'Choose File'},
    'tidak_ada_file_dipilih': {
      AppLanguage.id: 'Tidak ada file yang dipilih',
      AppLanguage.en: 'No file selected',
    },
    'catatan_opsional': {
      AppLanguage.id: 'Catatan (opsional)',
      AppLanguage.en: 'Note (optional)',
    },
    'catatan_placeholder': {
      AppLanguage.id: 'Ada yang mau disampaikan ke admin?',
      AppLanguage.en: 'Anything to tell the admin?',
    },
    'batal': {AppLanguage.id: 'Batal', AppLanguage.en: 'Cancel'},
    'kirim': {AppLanguage.id: 'Kirim', AppLanguage.en: 'Send'},
    'tugas_berhasil_dikumpulkan': {
      AppLanguage.id: 'Tugas berhasil dikumpulkan',
      AppLanguage.en: 'Task submitted successfully',
    },
    'edit_jurnal': {AppLanguage.id: 'Edit Jurnal', AppLanguage.en: 'Edit Journal'},
    'jurnal_diperbarui_pending': {
      AppLanguage.id: 'Jurnal diperbarui. Menunggu approval lagi.',
      AppLanguage.en: 'Journal updated. Pending approval again.',
    },
    'peringatan_edit_reset_status': {
      AppLanguage.id:
          'Jurnal ini sudah diputuskan sebelumnya. Kalau diedit, statusnya akan kembali Menunggu Approval.',
      AppLanguage.en:
          'This journal was already decided. Editing it will reset the status back to Pending.',
    },
    'foto_lama': {AppLanguage.id: 'Foto lama', AppLanguage.en: 'Current photo'},
    'ganti_foto': {AppLanguage.id: 'Ganti Foto', AppLanguage.en: 'Change Photo'},
    'simpan_perubahan': {
      AppLanguage.id: 'Simpan Perubahan',
      AppLanguage.en: 'Save Changes',
    },
    'diedit_pada': {AppLanguage.id: 'Diedit pada', AppLanguage.en: 'Edited on'},
    'edit': {AppLanguage.id: 'Edit', AppLanguage.en: 'Edit'},
    'pilih_file_dulu': {
      AppLanguage.id: 'Pilih file dulu sebelum mengirim',
      AppLanguage.en: 'Please choose a file before sending',
    },
    'tidak_bisa_buka_file': {
      AppLanguage.id: 'Tidak bisa membuka file',
      AppLanguage.en: 'Could not open file',
    },
    'belum_ada_tugas': {
      AppLanguage.id: 'Belum ada tugas',
      AppLanguage.en: 'No tasks yet',
    },
    'batas_waktu': {AppLanguage.id: 'Batas waktu', AppLanguage.en: 'Due date'},
    'tidak_ada_batas_waktu': {
      AppLanguage.id: 'Tidak ada batas waktu',
      AppLanguage.en: 'No due date',
    },
    'ubah_status': {
      AppLanguage.id: 'Ubah Status',
      AppLanguage.en: 'Change Status',
    },
    'terlambat': {AppLanguage.id: 'Terlambat', AppLanguage.en: 'Overdue'},
  };

  static String t(String key, AppLanguage lang) {
    return _dict[key]?[lang] ?? key;
  }
}

/// Shortcut biar dipakainya gampang: context.tr('beranda')
/// alih-alih AppStrings.t('beranda', context.watch<LanguageCubit>().state)
extension AppStringsContext on BuildContext {
  /// HANYA boleh dipanggil di dalam method build() (atau builder callback
  /// widget lain yang dieksekusi SAAT proses build, seperti
  /// showDialog/showModalBottomSheet's `builder:`). Pakai watch() supaya
  /// teksnya otomatis update kalau bahasa diganti.
  ///
  /// JANGAN dipakai di dalam:
  /// - listener: milik BlocListener/BlocConsumer
  /// - callback imperatif seperti onPressed/onTap, _submit(), dst
  /// karena provider's watch() akan CRASH ("Tried to listen to a value
  /// exposed with provider, from outside of the widget tree") kalau
  /// dipanggil di luar proses build -- pakai trRead() untuk kasus itu.
  String tr(String key) {
    final lang = watch<LanguageCubit>().state;
    return AppStrings.t(key, lang);
  }

  /// Versi AMAN dipakai di dalam listener/callback/event handler (di luar
  /// build()) -- misal isi SnackBar di dalam BlocListener.listener, atau
  /// pesan validasi di dalam fungsi _submit(). Pakai read() (bukan watch())
  /// jadi tidak subscribe ke perubahan -- itu memang benar untuk kasus ini
  /// karena teksnya cuma dibaca SEKALI saat event terjadi, tidak perlu
  /// auto-update.
  String trRead(String key) {
    final lang = read<LanguageCubit>().state;
    return AppStrings.t(key, lang);
  }
}
