import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:pdf_render_maintained/pdf_render_widgets.dart';

/// Full-screen, pinch-to-zoom viewer for a scanned clinical document.
///
/// Clinicians zoom into pathology and imaging reports to read fine print —
/// grades, margins, measurements — that a thumbnail can never show. Pinch,
/// double-tap and pan are therefore all supported, and the image is rendered
/// from a cached decode so a large multi-megapixel photo does not stutter.
class FullScreenImageViewer extends StatefulWidget {
  const FullScreenImageViewer({required this.imagePath, this.title, super.key});

  final String imagePath;

  /// Optional caption, e.g. the document category.
  final String? title;

  /// Opens the viewer as a full-screen route.
  static Future<void> open(
    BuildContext context, {
    required String imagePath,
    String? title,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            FullScreenImageViewer(imagePath: imagePath, title: title),
      ),
    );
  }

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer>
    with SingleTickerProviderStateMixin {
  final TransformationController _transform = TransformationController();
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );
  Animation<Matrix4>? _zoomAnimation;

  @override
  void dispose() {
    _transform.dispose();
    _anim.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    // Toggle between fit-to-screen and a 2.5x reading zoom.
    final zoomedIn = _transform.value.getMaxScaleOnAxis() > 1.01;
    final target = zoomedIn
        ? Matrix4.identity()
        : (Matrix4.identity()
            ..translateByDouble(
              -MediaQuery.sizeOf(context).width / 4,
              -MediaQuery.sizeOf(context).height / 4,
              0,
              1,
            )
            ..scaleByDouble(2.5, 2.5, 2.5, 1));

    _zoomAnimation = Matrix4Tween(begin: _transform.value, end: target).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic),
    )..addListener(() => _transform.value = _zoomAnimation!.value);
    _anim.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final file = File(widget.imagePath);
    // `existsSync` avoids handing an unreadable path to Image.file, which would
    // otherwise surface a raw framework error rather than a usable message.
    final exists = file.existsSync();
    final isPdf = path.extension(widget.imagePath).toLowerCase() == '.pdf';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.title ?? 'Document'),
      ),
      body: !exists
          ? const Center(
              child: Text(
                'The scanned image is no longer available on this device.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
            )
          : GestureDetector(
              // Double-tap zoom. Single taps are left to the pan gesture so a
              // double tap never accidentally dismisses.
              onDoubleTap: _handleDoubleTap,
              child: isPdf
                  ? PdfViewer.openFile(widget.imagePath)
                  : InteractiveViewer(
                      transformationController: _transform,
                      minScale: 1,
                      maxScale: 6,
                      child: Center(
                        child: Image.file(
                          file,
                          // `filterQuality: none` keeps fine print legible when
                          // zoomed instead of blurring it away.
                          filterQuality: FilterQuality.none,
                          errorBuilder: (context, error, _) => const Center(
                            child: Text(
                              'Could not display this image.',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
      // A reset control, because a clinician can pan off-image and get lost.
      floatingActionButton: ValueListenableBuilder<Matrix4>(
        valueListenable: _transform,
        builder: (context, value, _) {
          if (value.getMaxScaleOnAxis() <= 1.01) return const SizedBox.shrink();
          return FloatingActionButton.small(
            backgroundColor: Colors.white24,
            foregroundColor: Colors.white,
            tooltip: 'Reset zoom',
            onPressed: () => _transform.value = Matrix4.identity(),
            child: const Icon(Icons.center_focus_strong),
          );
        },
      ),
    );
  }
}
