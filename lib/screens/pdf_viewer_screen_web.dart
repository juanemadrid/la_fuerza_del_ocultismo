// Este archivo se usa en WEB
// Es un stub vacío porque en web el PDF se abre en el navegador
// El archivo pdf_viewer_screen.dart maneja la lógica web directamente
import 'package:flutter/material.dart';

class NativePdfViewer extends StatelessWidget {
  final String title;
  final String url;

  const NativePdfViewer({super.key, required this.title, required this.url});

  @override
  Widget build(BuildContext context) {
    // Este widget nunca se muestra en web (kIsWeb evita que se use)
    return const SizedBox.shrink();
  }
}
