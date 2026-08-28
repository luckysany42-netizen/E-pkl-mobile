import 'package:get_it/get_it.dart';

import '../network/api_client.dart';
import '../language/language_cubit.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/attendance/data/repositories/attendance_repository_impl.dart';
import '../../features/attendance/domain/repositories/attendance_repository.dart';
import '../../features/attendance/presentation/bloc/attendance_bloc.dart';
import '../../features/journal/data/repositories/journal_repository_impl.dart';
import '../../features/journal/domain/repositories/journal_repository.dart';
import '../../features/journal/presentation/bloc/journal_bloc.dart';
import '../../features/task/data/repositories/task_repository_impl.dart';
import '../../features/task/domain/repositories/task_repository.dart';
import '../../features/task/presentation/bloc/task_bloc.dart';

final GetIt sl = GetIt.instance; // "sl" = service locator

/// Panggil sekali di main() sebelum runApp().
/// Semua Bloc/Repository/DataSource didaftarkan di sini supaya
/// gampang di-inject ke widget lewat sl<TipeNya>().
Future<void> initDependencies() async {
  // Core
  sl.registerLazySingleton<ApiClient>(() => ApiClient.instance);
  sl.registerLazySingleton<LanguageCubit>(() => LanguageCubit());

  // Auth
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<ApiClient>()),
  );
  sl.registerFactory<AuthBloc>(() => AuthBloc(sl<AuthRepository>()));

  // Attendance
  sl.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepositoryImpl(sl<ApiClient>()),
  );
  sl.registerFactory<AttendanceBloc>(
    () => AttendanceBloc(sl<AttendanceRepository>()),
  );

  // Journal
  sl.registerLazySingleton<JournalRepository>(
    () => JournalRepositoryImpl(sl<ApiClient>()),
  );
  sl.registerFactory<JournalBloc>(() => JournalBloc(sl<JournalRepository>()));

  // Task
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(sl<ApiClient>()),
  );
  sl.registerFactory<TaskBloc>(() => TaskBloc(sl<TaskRepository>()));

  // TODO: daftarkan repository & bloc fitur lain di sini kalau sudah dibuat
  // (profile, face_recognition)
}
