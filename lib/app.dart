import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injector.dart';
import 'core/language/language_cubit.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/attendance/presentation/bloc/attendance_bloc.dart';
import 'features/home/presentation/pages/main_navigation_page.dart';

class EpklApp extends StatelessWidget {
  const EpklApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LanguageCubit>(create: (_) => sl<LanguageCubit>()),
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider<AttendanceBloc>(create: (_) => sl<AttendanceBloc>()),
        // TODO: tambahkan BlocProvider untuk JournalBloc, TaskBloc,
        // FaceRecognitionBloc di sini
      ],
      child: MaterialApp(
        title: 'E-PKL Mobile',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        onGenerateRoute: AppRouter.onGenerateRoute,
        // Widget awal ditentukan oleh AuthBloc, bukan initialRoute statis,
        // supaya user yang tokennya masih valid langsung masuk ke navbar
        // utama tanpa kelihatan halaman login dulu (auto-login).
        home: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is AuthAuthenticated) return const MainNavigationPage();
            if (state is AuthUnauthenticated || state is AuthFailure) {
              return const LoginPage();
            }
            // AuthInitial / AuthLoading -> splash sederhana sambil cek token
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }
}
