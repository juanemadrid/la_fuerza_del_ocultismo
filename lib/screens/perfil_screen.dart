import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fechaNacimientoController =
      TextEditingController(text: '15/03/1990');
  final TextEditingController _signoController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthService>(context, listen: false).userModel;
    if (user != null) {
      _nombreController.text = user.name;
      _emailController.text = user.email;
      _signoController.text = user.zodiacSign;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        title: const Text(
          'MI PERFIL',
          style: TextStyle(
            color: Color(0xFFB71C1C),
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFB71C1C)),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [
              const Color(0xFF1A0000),
              Colors.black,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Avatar
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFB71C1C),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFB71C1C).withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person,
                  size: 60,
                  color: Color(0xFFB71C1C),
                ),
              ),

              const SizedBox(height: 40),

              // Campos de perfil
              _buildProfileField(
                  'Nombre', _nombreController, Icons.person_outline),
              const SizedBox(height: 20),

              _buildProfileField(
                  'Email', _emailController, Icons.email_outlined),
              const SizedBox(height: 20),

              _buildProfileField('Fecha de Nacimiento',
                  _fechaNacimientoController, Icons.calendar_today_outlined),
              const SizedBox(height: 20),

              _buildProfileField(
                  'Signo Zodiacal', _signoController, Icons.star_outline),
              const SizedBox(height: 40),

              // Botón guardar
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB71C1C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'GUARDAR CAMBIOS',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField(
      String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFFB71C1C),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFFB71C1C)),
              filled: true,
              fillColor: Colors.black.withOpacity(0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveProfile() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUser;

    if (currentUser == null) return;
    if (_nombreController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nombre y correo son obligatorios'),
          backgroundColor: Color(0xFFB71C1C),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await DatabaseService().updateUserProfile(
        uid: currentUser.uid,
        name: _nombreController.text.trim(),
        email: _emailController.text.trim(),
        zodiacSign: _signoController.text.trim(),
      );
      await authService.reloadCurrentUser();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente'),
          backgroundColor: Color(0xFFB71C1C),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo guardar el perfil'),
          backgroundColor: Color(0xFFB71C1C),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _fechaNacimientoController.dispose();
    _signoController.dispose();
    super.dispose();
  }
}
