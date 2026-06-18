import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'membresia_vencida_screen.dart';
import 'pending_approval_screen.dart';
import 'register_screen.dart';
import 'select_plan_screen.dart';
import 'admin/admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;

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
      _showSnackBar('Por favor completa todos los campos', isError: true);
      return;
    }

    if (!EmailValidator.validate(usuario)) {
      _showSnackBar('Por favor ingresa un correo válido', isError: true);
      return;
    }

    if (contrasena.length < 6) {
      _showSnackBar('La contraseña debe tener al menos 6 caracteres', isError: true);
      return;
    }

    setState(() => _loading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      String? loginError = await authService.signIn(usuario, contrasena);

      if (loginError != null) {
        if (mounted) {
          _showSnackBar(loginError, isError: true);
        }
        return;
      }

      if (mounted) {
        final authService2 = Provider.of<AuthService>(context, listen: false);

        int intentos = 0;
        while (authService2.userModel == null && intentos < 10) {
          await Future.delayed(const Duration(milliseconds: 300));
          intentos++;
        }

        final user = authService2.userModel;

        if (user?.role == 'admin') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AdminDashboard()),
          );
          return;
        }

        if (user == null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
          return;
        }

        if (user.pendingApproval &&
            user.subscriptionExpiry == null &&
            user.pendingPlanId == null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const SelectPlanScreen()),
          );
          return;
        }

        if (user.pendingApproval && user.subscriptionExpiry == null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const PendingApprovalScreen()),
          );
          return;
        }

        if (user.isMembershipActive) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MembresiaVencidaScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.crimson : AppColors.bgElevated,
      ),
    );
  }

  void _olvidoContrasena() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderGold),
        ),
        title: Text(
          'Recuperar Contraseña',
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.gold),
        ),
        content: Text(
          'Se enviará un enlace de recuperación a tu correo electrónico registrado.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cerrar',
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.gold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.backgroundRadial,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.12,
                child: Image.asset(
                  'assets/images/background.jpeg',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withOpacity(0.12),
                            border: Border.all(
                              color: AppColors.gold.withOpacity(0.5),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: AppColors.gold,
                            size: 56,
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        Text(
                          'LAS FUERZAS',
                          style: AppTextStyles.displayLarge.copyWith(
                            fontSize: 26,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'DEL OCULTISMO',
                          style: AppTextStyles.labelGold.copyWith(
                            fontSize: 12,
                            letterSpacing: 3,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: AppColors.bgSurface.withOpacity(0.85),
                            border: Border.all(
                              color: AppColors.borderGold.withOpacity(0.3),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Acceso Privado',
                                style: AppTextStyles.titleLarge.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Ingresa al portal privado de tarot, horóscopo, rituales y limpiezas espirituales.',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              _buildField(
                                controller: _usuarioController,
                                label: 'Correo Electrónico',
                                hint: 'tu@correo.com',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 16),
                              
                              _buildField(
                                controller: _contrasenaController,
                                label: 'Contraseña',
                                hint: 'Mínimo 6 caracteres',
                                icon: Icons.lock_outline,
                                obscureText: _obscurePassword,
                                suffixIcon: IconButton(
                                  onPressed: () => setState(
                                      () => _obscurePassword = !_obscurePassword),
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 6),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _olvidoContrasena,
                                  child: Text(
                                    '¿Olvidaste tu contraseña?',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.gold,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 12),
                              
                              GlowButton(
                                onPressed: _loading ? null : _iniciarSesion,
                                gradient: AppGradients.goldButton,
                                glowColor: AppColors.gold,
                                child: _loading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.bgBase),
                                        ),
                                      )
                                    : Text(
                                        'INICIAR SESIÓN',
                                        style: AppTextStyles.titleMedium.copyWith(
                                          color: AppColors.bgBase,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              Row(
                                children: [
                                  Expanded(child: Container(height: 1, color: AppColors.borderSubtle)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      'o',
                                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                                    ),
                                  ),
                                  Expanded(child: Container(height: 1, color: AppColors.borderSubtle)),
                                ],
                              ),
                              
                              const SizedBox(height: 20),
                              
                              OutlineButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const RegisterScreen()),
                                ),
                                child: Text(
                                  'CREAR CUENTA',
                                  style: AppTextStyles.titleMedium.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _TrustBadge(icon: Icons.verified_user_outlined, text: 'Acceso privado'),
                            SizedBox(width: 14),
                            _TrustBadge(icon: Icons.workspace_premium_outlined, text: 'Templo Premium'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderPrimary,
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
              prefixIcon: Icon(icon, color: AppColors.primaryLight, size: 22),
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: AppColors.bgSurface.withOpacity(0.6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TrustBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgSurface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.borderGold),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.gold, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
