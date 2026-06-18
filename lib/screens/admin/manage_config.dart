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
  final _announcementController = TextEditingController();
  final _emailController = TextEditingController();

  bool _maintenanceMode = false;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  void dispose() {
    _whatsappController.dispose();
    _announcementController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    setState(() => _loading = true);
    try {
      final whatsapp = await _db.getWhatsAppLink();
      final appConfig = await _db.getAppConfig();

      _whatsappController.text = whatsapp;
      _announcementController.text = appConfig['announcement'] ?? '';
      _emailController.text = appConfig['contactEmail'] ?? '';
      _maintenanceMode = appConfig['maintenanceMode'] ?? false;
    } catch (e) {
      // ignore load errors, fields stay empty
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveAll() async {
    setState(() => _saving = true);
    try {
      await _db.updateWhatsAppLink(_whatsappController.text.trim());
      await _db.updateAppConfig({
        'announcement': _announcementController.text.trim(),
        'maintenanceMode': _maintenanceMode,
        'contactEmail': _emailController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuración guardada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'CONFIGURACIÓN GENERAL',
          style: TextStyle(
            color: Color(0xFFB71C1C),
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        backgroundColor: const Color(0xFF0D0D0D),
        iconTheme: const IconThemeData(color: Color(0xFFB71C1C)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [Color(0xFF1A0000), Colors.black],
          ),
        ),
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFB71C1C)),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── WhatsApp ──────────────────────────────────────────
                    _sectionTitle('CONTACTO', Icons.chat_outlined),
                    const SizedBox(height: 12),
                    _buildCard(
                      child: Column(
                        children: [
                          _buildField(
                            controller: _whatsappController,
                            label: 'Enlace de WhatsApp',
                            hint: 'https://wa.me/573000000000',
                            icon: Icons.chat_bubble_outline,
                            iconColor: Colors.green,
                          ),
                          const SizedBox(height: 16),
                          _buildField(
                            controller: _emailController,
                            label: 'Correo de contacto',
                            hint: 'contacto@ejemplo.com',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Anuncio ───────────────────────────────────────────
                    _sectionTitle('ANUNCIO / BANNER', Icons.campaign_outlined),
                    const SizedBox(height: 12),
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildField(
                            controller: _announcementController,
                            label: 'Texto del anuncio',
                            hint:
                                'Ej: ¡Nuevas limpiezas disponibles esta semana!',
                            icon: Icons.announcement_outlined,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Este texto se mostrará como banner en la app para los usuarios.',
                            style:
                                TextStyle(color: Colors.white38, fontSize: 12),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Mantenimiento ─────────────────────────────────────
                    _sectionTitle(
                        'MODO MANTENIMIENTO', Icons.build_circle_outlined),
                    const SizedBox(height: 12),
                    _buildCard(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _maintenanceMode
                                  ? Colors.orange.withOpacity(0.15)
                                  : Colors.white.withOpacity(0.05),
                            ),
                            child: Icon(
                              Icons.build_outlined,
                              color: _maintenanceMode
                                  ? Colors.orange
                                  : Colors.white38,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _maintenanceMode
                                      ? 'Mantenimiento ACTIVO'
                                      : 'Mantenimiento inactivo',
                                  style: TextStyle(
                                    color: _maintenanceMode
                                        ? Colors.orange
                                        : Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Cuando está activo, los usuarios ven una pantalla de mantenimiento.',
                                  style: TextStyle(
                                      color: Colors.white38, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _maintenanceMode,
                            activeColor: Colors.orange,
                            onChanged: (val) =>
                                setState(() => _maintenanceMode = val),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Save button ───────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _saving ? null : _saveAll,
                        icon: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(
                            _saving ? 'GUARDANDO...' : 'GUARDAR CONFIGURACIÓN'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB71C1C),
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFB71C1C), size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFB71C1C),
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF1A1A1A),
        border: Border.all(color: const Color(0xFFB71C1C).withOpacity(0.3)),
      ),
      child: child,
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    Color? iconColor,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
        prefixIcon: icon != null
            ? Icon(icon, color: iconColor ?? const Color(0xFFB71C1C), size: 20)
            : null,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white12),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFB71C1C)),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.04),
      ),
    );
  }
}
