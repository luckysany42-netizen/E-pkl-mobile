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
  };

  static String t(String key, AppLanguage lang) {
    return _dict[key]?[lang] ?? key;
  }
}

/// Shortcut biar dipakainya gampang: context.tr('beranda')
/// alih-alih AppStrings.t('beranda', context.watch<LanguageCubit>().state)
extension AppStringsContext on BuildContext {
  String tr(String key) {
    final lang = watch<LanguageCubit>().state;
    return AppStrings.t(key, lang);
  }
}
