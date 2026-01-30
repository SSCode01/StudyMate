import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PDFViewerScreen extends StatefulWidget {
  final String url;

  const PDFViewerScreen({super.key, required this.url});

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  String? localPath;
  bool error = false;

  @override
  void initState() {
    super.initState();
    downloadPdf();
  }

  Future<void> downloadPdf() async {
    try {
      final response = await http.get(Uri.parse(widget.url));

      if (response.statusCode != 200) {
        throw Exception("Failed to load PDF");
      }

      final dir = await getTemporaryDirectory();
      final file = File("${dir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.pdf");
      await file.writeAsBytes(response.bodyBytes);

      if (!mounted) return;
      setState(() => localPath = file.path);
    } catch (e) {
      debugPrint("PDF load error: $e");
      if (!mounted) return;
      setState(() => error = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PDF Viewer")),
      body: error
          ? const Center(child: Text("Failed to load PDF"))
          : localPath == null
          ? const Center(child: CircularProgressIndicator())
          : PDFView(
        filePath: localPath!,
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: true,
        pageSnap: true,
      ),
    );
  }
}
