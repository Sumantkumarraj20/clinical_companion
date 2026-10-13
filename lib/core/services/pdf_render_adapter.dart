import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

/// Cross-platform PDF page viewer built on `printing`'s rasterizer, which
/// ships native implementations for Android, iOS, macOS, Windows and Linux.
class PdfRenderAdapter {
  const PdfRenderAdapter._();

  static Widget buildViewer(String filePath, {Key? key}) =>
      _PdfPagesView(key: key, filePath: filePath);
}

class _PdfPagesView extends StatefulWidget {
  const _PdfPagesView({super.key, required this.filePath});

  final String filePath;

  @override
  State<_PdfPagesView> createState() => _PdfPagesViewState();
}

class _PdfPagesViewState extends State<_PdfPagesView> {
  late Future<List<Uint8List>> _pages = _load();

  @override
  void didUpdateWidget(covariant _PdfPagesView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filePath != widget.filePath) _pages = _load();
  }

  Future<List<Uint8List>> _load() async {
    final bytes = await File(widget.filePath).readAsBytes();
    final pages = <Uint8List>[];
    await for (final raster in Printing.raster(bytes, dpi: 144)) {
      pages.add(await raster.toPng());
    }
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Uint8List>>(
      future: _pages,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final pages = snapshot.data;
        if (snapshot.hasError || pages == null || pages.isEmpty) {
          return const Center(
            child: Text(
              'Could not preview this PDF.',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }
        return InteractiveViewer(
          minScale: 1,
          maxScale: 5,
          child: ListView.separated(
            itemCount: pages.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) => Image.memory(pages[i], fit: BoxFit.contain),
          ),
        );
      },
    );
  }
}
