import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/di/injector.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  // Wajib sebelum pakai DateFormat(pattern, 'id_ID') di beranda_page.dart,
  // kalau tidak akan crash "Locale data has not been initialized".
  await initializeDateFormatting('id_ID', null);
  runApp(const EpklApp());
}
