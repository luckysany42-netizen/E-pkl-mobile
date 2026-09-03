import 'package:flutter/material.dart';

import '../../../../core/language/app_strings.dart';
import '../../data/models/task_attachment_model.dart';

/// Galeri thumbnail lampiran task. Tampil sebagai grid; thumbnail otomatis
/// mengecil kalau jumlahnya lebih dari 5 (biar tetap muat rapi di kartu),
/// dan tap SATU FOTO buka preview IN-APP (dialog full-screen, bisa geser
/// antar foto) -- BUKAN buka tab browser luar seperti sebelumnya.
///
/// File non-gambar (pdf/doc/xls/zip) ditampilkan sebagai kartu ikon+nama,
/// karena tidak bisa di-preview visual seperti foto.
class TaskAttachmentGallery extends StatelessWidget {
  final List<TaskAttachmentModel> attachments;

  const TaskAttachmentGallery({super.key, required this.attachments});

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();

    // >5 lampiran -> thumbnail mengecil (56 -> 40) supaya tetap muat rapi
    // dalam beberapa baris tanpa kartu jadi kepanjangan.
    final thumbSize = attachments.length > 5 ? 40.0 : 56.0;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: attachments.asMap().entries.map((entry) {
        final index = entry.key;
        final att = entry.value;
        return GestureDetector(
          onTap: () => _openPreview(context, index),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: att.isImage
                ? Image.network(
                    att.url,
                    width: thumbSize,
                    height: thumbSize,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _FileIconTile(size: thumbSize),
                  )
                : _FileIconTile(size: thumbSize),
          ),
        );
      }).toList(),
    );
  }

  void _openPreview(BuildContext context, int initialIndex) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => _AttachmentPreviewDialog(
        attachments: attachments,
        initialIndex: initialIndex,
      ),
    );
  }
}

class _FileIconTile extends StatelessWidget {
  final double size;
  const _FileIconTile({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: Colors.grey.shade200,
      child: Icon(Icons.insert_drive_file_outlined, size: size * 0.5, color: Colors.grey.shade600),
    );
  }
}

class _AttachmentPreviewDialog extends StatefulWidget {
  final List<TaskAttachmentModel> attachments;
  final int initialIndex;

  const _AttachmentPreviewDialog({
    required this.attachments,
    required this.initialIndex,
  });

  @override
  State<_AttachmentPreviewDialog> createState() => _AttachmentPreviewDialogState();
}

class _AttachmentPreviewDialogState extends State<_AttachmentPreviewDialog> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _controller = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.attachments[_index];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: SizedBox.expand(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: widget.attachments.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) {
                final att = widget.attachments[i];
                if (att.isImage) {
                  return InteractiveViewer(
                    child: Center(
                      child: Image.network(att.url, fit: BoxFit.contain),
                    ),
                  );
                }
                // File non-gambar tidak bisa di-preview visual di sini
                // (butuh viewer PDF/doc terpisah yang belum dipasang) --
                // cukup tampilkan info filenya di dalam modal ini saja,
                // tetap TIDAK buka browser luar.
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.insert_drive_file, size: 64, color: Colors.white70),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          att.originalName ?? att.url.split('/').last,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            if (widget.attachments.length > 1)
              Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_index + 1} / ${widget.attachments.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
