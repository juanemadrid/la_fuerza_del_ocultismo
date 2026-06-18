import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// Importaciones sólo para plataformas móviles/escritorio
import 'pdf_viewer_screen_native.dart'
    if (dart.library.html) 'pdf_viewer_screen_web.dart';

class PdfViewerScreen extends StatefulWidget {
  final String title;
  final String url;

  const PdfViewerScreen({super.key, required this.title, required this.url});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      // En web, abrir el PDF en una nueva pestaña directamente
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openPdfInBrowser();
      });
    }
  }

  Future<void> _openPdfInBrowser() async {
    final uri = Uri.parse(widget.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    // Volver atrás después de abrir
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // Pantalla de carga mientras se abre el PDF en el navegador
      return Scaffold(
        backgroundColor: const Color(0xFF0D0D0D),
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: const Color(0xFF0D0D0D),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFFB71C1C)),
              const SizedBox(height: 20),
              const Text(
                'Abriendo PDF en el navegador...',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _openPdfInBrowser,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Abrir PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB71C1C),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // En móvil/escritorio: usar el visor nativo
    return NativePdfViewer(title: widget.title, url: widget.url);
  }
}
