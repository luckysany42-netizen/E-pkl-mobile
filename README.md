# E-PKL Mobile — Scaffold Awal (Flutter + BLoC)

Struktur ini adalah kerangka folder saja (feature-first + BLoC pattern),
dibuat berdasarkan modul yang ada di backend Laravel `E-pkl-main`:
auth, face recognition, attendance, journal, task, profile.

## Cara pakai

1. Buat project Flutter kosong (lihat langkah di chat).
2. Timpa/gabungkan folder `lib/` di project barumu dengan folder `lib/` di scaffold ini
   (folder `lib/` bawaan `flutter create` boleh dihapus isinya dulu, kecuali kalau
   mau pertahankan beberapa file default).
3. Tambahkan dependency dari `pubspec_dependencies.txt` ke `pubspec.yaml`.
4. Jalankan `flutter pub get`.
5. Sesuaikan `lib/core/constants/api_endpoints.dart` -> isi `baseUrl` sesuai alamat
   server Laravel kamu (localhost, IP LAN, atau domain produksi).
6. Jalankan `flutter run`.

## Struktur folder

```
lib/
  core/                     <- kode yang dipakai bareng semua fitur
    constants/api_endpoints.dart
    network/api_client.dart      (Dio wrapper + interceptor token)
    network/result.dart          (wrapper sukses/gagal, pengganti try-catch berulang)
    di/injector.dart             (get_it, daftar semua Bloc & Repository)
    routes/app_router.dart
    theme/app_theme.dart
    utils/storage_helper.dart    (simpan token login)
    widgets/                     (widget reusable, misal loading, empty state)

  features/
    auth/                   <- login, register, register-with-face, me, logout
    face_recognition/       <- absen/login pakai wajah (kamera + kirim ke /face/login)
    attendance/             <- check-in/out, riwayat absensi (/attendances)
    journal/                <- jurnal harian intern (/journals, approve/reject)
    task/                   <- daftar & status tugas (/intern/tasks, /tasks)
    profile/                <- ubah profil, email, password
    home/                   <- dashboard setelah login

    Tiap fitur (kecuali home) punya pola yang sama:
      data/
        models/          <- class buat parsing response JSON API
        repositories/    <- implementasi, panggil ApiClient langsung ke Laravel
        datasources/     <- (opsional) kalau mau pisah remote/local datasource
      domain/
        repositories/    <- abstract class/interface (dikonsumsi Bloc, gak tau Dio)
      presentation/
        bloc/            <- xxx_bloc.dart, xxx_event.dart, xxx_state.dart
        pages/            <- halaman (Scaffold)
        widgets/          <- widget khusus fitur itu
```

`features/auth/presentation/bloc/` sudah aku isi contoh lengkap
(`auth_event.dart`, `auth_state.dart`, `auth_bloc.dart`) sebagai pola acuan.
Folder fitur lain sengaja masih kosong — begitu kamu kasih tahu detail data
per fitur (misal field apa saja di response `/journals` atau `/attendances`),
tinggal aku buatkan model + bloc-nya mengikuti pola yang sama.

## Kenapa strukturnya begini?

- **Feature-first**: tiap modul (auth, attendance, journal, dst) mandiri,
  gampang dicari, gampang dihapus/diganti tanpa ganggu fitur lain.
- **data / domain / presentation**: memisahkan "cara ambil data" (data),
  "aturan bisnis apa yang dibutuhkan" (domain), dan "tampilan + state" (presentation).
  Bloc di presentation cuma bicara ke `domain/repositories` (interface),
  gak pernah import Dio langsung — jadi gampang di-test / di-mock.
- Ini sengaja dibuat mirror dari struktur controller Laravel kamu
  (AuthController, FaceController, AttendanceController, JournalController,
  TaskController, UserController) supaya kamu gampang menghubungkan
  "fitur mobile ini manggil endpoint Laravel yang mana".
