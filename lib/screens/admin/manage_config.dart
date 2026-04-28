import 'package:flutter/material.dart';
import '../../services/database_service.dart';

class ManageConfig extends StatefulWidget {
  const ManageConfig({super.key});

  @override
  State<ManageConfig> createState() => _ManageConfigState();
}

class _ManageConfigState extends State<ManageConfig> {
  final DatabaseService _db = DatabaseService();
  final _whatsappController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  void _loadConfig() async {
    final link = await _db.getWhatsAppLink();
    _whatsappController.text = link;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CONFIGURACIÓN GENERAL')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _whatsappController,
              decoration: const InputDecoration(
                labelText: 'Enlace de WhatsApp (wa.me/...)',
                helperText: 'Ej: https://wa.me/573000000000',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await _db.updateWhatsAppLink(_whatsappController.text);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Configuración guardada')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB71C1C)),
              child: const Text('GUARDAR CAMBIOS'),
            ),
          ],
        ),
      ),
    );
  }
}
