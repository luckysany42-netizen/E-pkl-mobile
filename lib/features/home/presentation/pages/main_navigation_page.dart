import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/language/app_strings.dart';
import '../../../journal/presentation/pages/journal_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../task/presentation/pages/task_page.dart';
import 'beranda_page.dart';

/// Shell utama setelah login: bottom navbar 4 tab sesuai keputusan produk
/// (Beranda, Tugas, Jurnal, Profil — TIDAK 5 tab seperti referensi awal).
class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _index = 0;

  // IndexedStack biar state tiap tab (misal posisi scroll) tidak reset
  // waktu pindah-pindah tab.
  static final _pages = [
    const BerandaPage(),
    const TaskPage(),
    const JournalPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF3B82F6),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: context.tr('beranda'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.assignment_outlined),
            activeIcon: const Icon(Icons.assignment),
            label: context.tr('tugas'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.book_outlined),
            activeIcon: const Icon(Icons.book),
            label: context.tr('jurnal'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: context.tr('profil'),
          ),
        ],
      ),
    );
  }
}
