import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/responsive_container.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import 'select_plan_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _signoSeleccionado;

  static const List<Map<String, String>> _signos = [
    {'nombre': 'Aries',       'icono': '♈', 'fechas': 'Mar 21 – Abr 19'},
    {'nombre': 'Tauro',       'icono': '♉', 'fechas': 'Abr 20 – May 20'},
    {'nombre': 'Géminis',     'icono': '♊', 'fechas': 'May 21 – Jun 20'},
    {'nombre': 'Cáncer',      'icono': '♋', 'fechas': 'Jun 21 – Jul 22'},
    {'nombre': 'Leo',         'icono': '♌', 'fechas': 'Jul 23 – Ago 22'},
    {'nombre': 'Virgo',       'icono': '♍', 'fechas': 'Ago 23 – Sep 22'},
    {'nombre': 'Libra',       'icono': '♎', 'fechas': 'Sep 23 – Oct 22'},
    {'nombre': 'Escorpio',    'icono': '♏', 'fechas': 'Oct 23 – Nov 21'},
    {'nombre': 'Sagitario',   'icono': '♐', 'fechas': 'Nov 22 – Dic 21'},
    {'nombre': 'Capricornio', 'icono': '♑', 'fechas': 'Dic 22 – Ene 19'},
    {'nombre': 'Acuario',     'icono': '♒', 'fechas': 'Ene 20 – Feb 18'},
    {'nombre': 'Piscis',      'icono': '♓', 'fechas': 'Feb 19 – Mar 20'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final pass = _passController.text.trim();
    final confirm = _confirmPassController.text.trim();

    if (name.isEmpty || email.isEmpty || pass.isEmpty || confirm.isEmpty) {
      _showError('Por favor completa todos los campos');
      return;
    }
    if (name.length < 3) {
      _showError('El nombre debe tener al menos 3 caracteres');
      return;
    }
    if (!EmailValidator.validate(email)) {
      _showError('Por favor ingresa un email válido');
      return;
    }
    if (pass.length < 6) {
      _showError('La contraseña debe tener al menos 6 caracteres');
      return;
    }
    if (pass != confirm) {
      _showError('Las contraseñas no coinciden');
      return;
    }
    if (_signoSeleccionado == null) {
      _showError('Por favor selecciona tu signo zodiacal');
      return;
    }

    setState(() => _loading = true);

    final authService = AuthService();
    final error = await authService.signUp(
      email,
      pass,
      name,
      zodiacSign: _signoSeleccionado!,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      _showError(error);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SelectPlanScreen()),
      );
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.crimson,
      ),
    );
  }

  void _mostrarSelectorSigno() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: AppColors.borderGold),
      ),
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.92,
        minChildSize: 0.5,
        expand: false,
        builder: (_, controller) => Column(
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'SELECCIONA TU SIGNO',
              style: GoogleFonts.cinzel(
                color: AppColors.gold,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                controller: controller,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.85,
                ),
                itemCount: _signos.length,
                itemBuilder: (_, i) {
                  final signo = _signos[i];
                  final isSelected = _signoSeleccionado == signo['nombre'];
                  return GestureDetector(
                    onTap: () {
                      setState(() => _signoSeleccionado = signo['nombre']);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.gold
                              : AppColors.borderSubtle,
                          width: isSelected ? 1.5 : 1,
                        ),
                        color: isSelected
                            ? AppColors.gold.withOpacity(0.12)
                            : AppColors.bgElevated.withOpacity(0.4),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            signo['icono']!,
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            signo['nombre']!,
                            style: GoogleFonts.cinzel(
                              color: isSelected ? AppColors.gold : AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            signo['fechas']!,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 9,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenHeight < 760;

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
                  color: AppColors.primary,
                  colorBlendMode: BlendMode.color,
                ),
              ),
            ),
            SafeArea(
              child: ResponsiveContainer(
                maxWidth: 450,
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: isSmallScreen ? 12 : 24,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: isSmallScreen ? 4 : 10),

                        Text(
                          'CREAR CUENTA',
                          style: AppTextStyles.displayLarge.copyWith(
                            fontSize: isSmallScreen ? 20 : 24,
                            letterSpacing: 4,
                          ),
                        ),
                        if (!isSmallScreen) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Regístrate, elige tu plan y solicita acceso',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                        SizedBox(height: isSmallScreen ? 16 : 32),

                        // Nombre
                        _label('Nombre completo', isSmallScreen),
                        CustomTextField(
                          controller: _nameController,
                          hintText: 'Tu nombre completo',
                          prefixIcon: Icons.person_outline,
                        ),
                        SizedBox(height: isSmallScreen ? 10 : 16),

                        // Email
                        _label('Correo electrónico', isSmallScreen),
                        CustomTextField(
                          controller: _emailController,
                          hintText: 'tu@correo.com',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: isSmallScreen ? 10 : 16),

                        // Contraseña
                        _label('Contraseña', isSmallScreen),
                        CustomTextField(
                          controller: _passController,
                          hintText: 'Mínimo 6 caracteres',
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscurePass,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePass
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textMuted,
                            ),
                            onPressed: () =>
                                setState(() => _obscurePass = !_obscurePass),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 10 : 16),

                        // Confirmar contraseña
                        _label('Confirmar contraseña', isSmallScreen),
                        CustomTextField(
                          controller: _confirmPassController,
                          hintText: 'Repite tu contraseña',
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscureConfirm,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textMuted,
                            ),
                            onPressed: () =>
                                setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 10 : 16),

                        // Signo zodiacal
                        _label('Signo zodiacal', isSmallScreen),
                        GestureDetector(
                          onTap: _mostrarSelectorSigno,
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: isSmallScreen ? 11 : 15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _signoSeleccionado != null
                                    ? AppColors.gold
                                    : AppColors.borderPrimary,
                                width: 1.5,
                              ),
                              color: AppColors.bgSurface.withOpacity(0.6),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome_outlined,
                                  color: _signoSeleccionado != null
                                      ? AppColors.gold
                                      : AppColors.primaryLight,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _signoSeleccionado != null
                                      ? Row(
                                          children: [
                                            Text(
                                              _signos.firstWhere((s) =>
                                                  s['nombre'] ==
                                                  _signoSeleccionado)['icono']!,
                                              style: const TextStyle(fontSize: 20),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              _signoSeleccionado!,
                                              style: AppTextStyles.bodyLarge.copyWith(
                                                color: AppColors.textPrimary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Text(
                                          'Selecciona tu signo',
                                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
                                        ),
                                ),
                                const Icon(Icons.keyboard_arrow_down,
                                    color: AppColors.textMuted),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 16 : 32),

                        // Botón registrar
                        _loading
                            ? const CircularProgressIndicator(
                                color: AppColors.gold)
                            : CustomButton(
                                text: 'CREAR CUENTA',
                                onPressed: _registrar,
                              ),

                        SizedBox(height: isSmallScreen ? 16 : 24),

                        // Volver al login
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('¿Ya tienes cuenta? ',
                                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Iniciar sesión',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.gold,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
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

  Widget _label(String text, bool isSmall) => Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(left: 4.0, bottom: isSmall ? 4.0 : 8.0),
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: isSmall ? 13 : 14,
            ),
          ),
        ),
      );
}
