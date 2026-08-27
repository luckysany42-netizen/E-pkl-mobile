import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/storage_helper.dart';
import 'app_language.dart';

/// Cubit (bagian dari keluarga BLoC, versi simpel tanpa Event) buat nyimpen
/// bahasa yang lagi aktif. Dipilih Cubit bukan Bloc penuh karena cuma ada
/// satu aksi sederhana: ganti bahasa — tidak butuh Event terpisah.
class LanguageCubit extends Cubit<AppLanguage> {
  LanguageCubit() : super(AppLanguage.id) {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final saved = await StorageHelper.getLanguage();
    if (saved == 'en') emit(AppLanguage.en);
  }

  Future<void> toggle() async {
    final next = state == AppLanguage.id ? AppLanguage.en : AppLanguage.id;
    emit(next);
    await StorageHelper.saveLanguage(next.name);
  }
}
