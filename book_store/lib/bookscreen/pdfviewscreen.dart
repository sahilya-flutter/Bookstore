
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

class PDFViewerScreen extends StatefulWidget {
  final String pdfPath;
  final String bookTitle;

  const PDFViewerScreen({
    super.key,
    required this.pdfPath,
    required this.bookTitle,
  });

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  String? _currentPdfPath;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _preparePDF(widget.pdfPath);
  }

  Future<void> _preparePDF(String assetPath) async {
    try {
      setState(() {
        _isReady = false;
      });

      final bytes = await DefaultAssetBundle.of(context).load(assetPath);
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${assetPath.split('/').last}');
      await tempFile.writeAsBytes(bytes.buffer.asUint8List());

      if (mounted) {
        setState(() {
          _currentPdfPath = tempFile.path;
          _isReady = true;
        });
      }
    } catch (e) {
      log("Error loading PDF: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading PDF: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bookTitle),
      ),
      body: _isReady
          ? PDFView(
              filePath: _currentPdfPath,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
              pageFling: true,
              onError: (error) {
                log("PDF Error: $error");
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error displaying PDF: $error')),
                  );
                }
              },
              onPageChanged: (page, total) {
                log('Page changed: $page/$total');
              },
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
