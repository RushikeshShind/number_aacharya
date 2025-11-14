import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';

class PdfViewerScreen extends StatefulWidget {
  final String url;

  const PdfViewerScreen({super.key, required this.url});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  bool _isDownloading = false;
  double _progress = 0;

  Future<void> _downloadPdf() async {
    // Ask for storage permission (Android)
    if (Platform.isAndroid) {
      if (!await Permission.storage.request().isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Storage permission denied")),
        );
        return;
      }
    }

    setState(() {
      _isDownloading = true;
      _progress = 0;
    });

    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = "${dir.path}/report.pdf";

      Dio dio = Dio();
      await dio.download(
        widget.url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _progress = received / total;
            });
          }
        },
      );

      setState(() {
        _isDownloading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Downloaded to $filePath")),
      );
    } catch (e) {
      setState(() {
        _isDownloading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error downloading file: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report"),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _isDownloading ? null : _downloadPdf,
          ),
        ],
      ),
      body: Stack(
        children: [
          SfPdfViewer.network(widget.url),
          if (_isDownloading)
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                color: Colors.black54,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 10),
                    Text(
                      "Downloading: ${(_progress * 100).toStringAsFixed(0)}%",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
