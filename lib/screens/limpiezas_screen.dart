import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/content_file_model.dart';
import 'pdf_viewer_screen.dart';

class LimpiezasScreen extends StatelessWidget {
  const LimpiezasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService();
    final user = Provider.of<AuthService>(context).userModel;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        title: const Text(
          'LIMPIEZAS',
          style: TextStyle(
            color: Color(0xFFB71C1C),
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFB71C1C)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [
              Color(0xFF1A0000),
              Colors.black,
            ],
          ),
        ),
        child: StreamBuilder<List<ContentFileModel>>(
          stream: db.streamContentByCategory('limpieza'),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            
            final limpiezas = snapshot.data!;

            if (limpiezas.isEmpty) {
              return const Center(
                child: Text(
                  'No hay guías disponibles en este momento.',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(24.0),
              itemCount: limpiezas.length,
              itemBuilder: (context, index) {
                final limpieza = limpiezas[index];
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFB71C1C),
                      width: 1,
                    ),
                    color: Colors.black.withOpacity(0.5),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFB71C1C),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.picture_as_pdf_outlined,
                        color: Color(0xFFB71C1C),
                        size: 24,
                      ),
                    ),
                    title: Text(
                      limpieza.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      limpieza.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        if (user?.isSubscribed ?? false) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PdfViewerScreen(
                                title: limpieza.title,
                                url: limpieza.url,
                              ),
                            ),
                          );
                        } else {
                          _mostrarAvisoSub(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB71C1C),
                      ),
                      child: const Text('VER GUÍA'),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _mostrarAvisoSub(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('SUSCRIPCIÓN REQUERIDA', style: TextStyle(color: Color(0xFFB71C1C))),
        content: const Text('Esta guía es exclusiva para clientes con suscripción activa. Contacta al maestro para activarla.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CERRAR', style: TextStyle(color: Color(0xFFB71C1C))),
          ),
        ],
      ),
    );
  }

  void _mostrarDetalles(BuildContext context, Map<String, dynamic> limpieza) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFB71C1C), width: 2),
        ),
        title: Text(
          limpieza['nombre'],
          style: const TextStyle(
            color: Color(0xFFB71C1C),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              limpieza['descripcion'],
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Text(
              'Duración: ${limpieza['duracion']}',
              style: const TextStyle(color: Color(0xFFB71C1C)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tu solicitud ha sido enviada. Nos pondremos en contacto contigo pronto.',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cerrar',
              style: TextStyle(color: Color(0xFFB71C1C)),
            ),
          ),
        ],
      ),
    );
  }
}
