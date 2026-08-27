import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/language/app_language.dart';
import '../../../../core/language/app_strings.dart';
import '../../../../core/language/language_cubit.dart';

/// Card "Progress Magang": ring persentase + "Hari ke-X dari Y" + tanggal
/// selesai. Dihitung murni di sisi app dari tanggalMulai/tanggalSelesai
/// milik user (tidak ada endpoint khusus buat ini di backend).
class InternshipProgressCard extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;

  const InternshipProgressCard({
    super.key,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final totalDays = endDate.difference(startDate).inDays;
    final elapsedDaysRaw = today.difference(startDate).inDays;
    // Clamp biar tidak nunjukin angka aneh (negatif sebelum mulai magang,
    // atau lebih dari total kalau sudah lewat tanggal selesai).
    final elapsedDays = elapsedDaysRaw.clamp(0, totalDays == 0 ? 0 : totalDays);
    final percent = totalDays <= 0 ? 0.0 : elapsedDays / totalDays;

    final lang = context.watch<LanguageCubit>().state;
    final dateFormat = DateFormat(
      'd MMMM yyyy',
      lang == AppLanguage.id ? 'id_ID' : 'en_US',
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: CircularProgressIndicator(
                    value: percent.clamp(0.0, 1.0),
                    strokeWidth: 7,
                    backgroundColor: const Color(0xFFE5E9F0),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF3B82F6)),
                  ),
                ),
                Text(
                  '${(percent * 100).round()}%',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('progress_magang'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  lang == AppLanguage.id
                      ? 'Hari ke-$elapsedDays dari $totalDays'
                      : 'Day $elapsedDays of $totalDays',
                  style: const TextStyle(color: Color(0xFF475569), fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  '${context.tr('selesai_pada')} ${dateFormat.format(endDate)}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
