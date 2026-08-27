import 'package:flutter/material.dart';

/// Halaman placeholder generik buat tab yang belum dikerjakan (Tugas,
/// Jurnal, dst). Dipakai sementara supaya navbar 4 tab tetap bisa dites
/// utuh walau isinya belum ada.
class ComingSoonPage extends StatelessWidget {
  final String title;
  final IconData icon;

  const ComingSoonPage({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              '$title — Segera Hadir',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
