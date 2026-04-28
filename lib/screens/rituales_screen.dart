import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/content_file_model.dart';
import 'pdf_viewer_screen.dart';

class RitualesScreen extends StatelessWidget {
  const RitualesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService();
    final user = Provider.of<AuthService>(context).userModel;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        title: const Text(
          'RITUALES',
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
          stream: db.streamContentByCategory('ritual'),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            
            final rituales = snapshot.data!;

            if (rituales.isEmpty) {
              return const Center(
                child: Text(
                  'No hay rituales disponibles en este momento.',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(24.0),
              itemCount: rituales.length,
              itemBuilder: (context, index) {
                final ritual = rituales[index];
                
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
                        Icons.auto_fix_high_outlined,
                        color: Color(0xFFB71C1C),
                        size: 24,
                      ),
                    ),
                    title: Text(
                      ritual.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      ritual.description,
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
                                title: ritual.title,
                                url: ritual.url,
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
                      child: const Text('VER RITUAL'),
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
        content: const Text('Este ritual es exclusivo para clientes con suscripción activa. Contacta al maestro para activarla.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CERRAR', style: TextStyle(color: Color(0xFFB71C1C))),
          ),
        ],
      ),
    );
  }
}
