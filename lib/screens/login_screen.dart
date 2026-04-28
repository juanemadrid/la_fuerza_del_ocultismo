import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/responsive_container.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usuarioController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    String usuario = _usuarioController.text.trim();
    String contrasena = _contrasenaController.text.trim();

    if (usuario.isEmpty || contrasena.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos'),
          backgroundColor: Color(0xFFB71C1C),
        ),
      );
      return;
    }

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      String? loginError;

      // Admin Bypass
      if (usuario == 'leyson' && contrasena == '123') {
        // We use a specific email for the admin in Firebase
        loginError = await authService.signIn('admin@lafuerza.com', 'admin123');
      } else {
        // Normal Login (treating username as email for simplicity or fixing it)
        String email = usuario.contains('@') ? usuario : '$usuario@cliente.com';
        loginError = await authService.signIn(email, contrasena);
      }

      if (loginError != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loginError),
              backgroundColor: const Color(0xFFB71C1C),
            ),
          );
        }
        return;
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _olvidoContrasena() {
    // Implementar lógica de recuperación de contraseña
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Recuperar Contraseña',
          style: TextStyle(color: Color(0xFFB71C1C)),
        ),
        content: const Text(
          'Se enviará un enlace de recuperación a tu correo',
          style: TextStyle(color: Colors.white70),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          true, // Allow resizing to push content up when keyboard appears
      body: Stack(
        children: [
          // Background Image (Fixed)
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.jpeg'),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          // Dark Overlay (Subtle)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),
          // Content
          SafeArea(
            child: ResponsiveContainer(
              maxWidth: 450,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  children: [
                    // Spacer adjusted for responsive height
                    const SizedBox(height: 330),

                    // Campo Usuario
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Usuario',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _usuarioController,
                      hintText: 'Ingresa tu usuario',
                      prefixIcon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),

                    // Campo Contraseña
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Contraseña',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _contrasenaController,
                      hintText: 'Ingresa tu contraseña',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.white54,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Botón Iniciar Sesión
                    CustomButton(
                      text: 'INICIAR SESIÓN',
                      onPressed: _iniciarSesion,
                    ),
                    const SizedBox(height: 16),

                    // ¿Necesitas ayuda? / Olvidé contraseña
                    const Text(
                      '¿Necesitas ayuda?',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: _olvidoContrasena,
                      child: const Text(
                        'Olvidé contraseña',
                        style: TextStyle(
                          color: Color(0xFFB71C1C),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
