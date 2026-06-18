import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fechaNacimientoController = TextEditingController();
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
      _fechaNacimientoController.text = user.birthDate.isNotEmpty ? user.birthDate : '15/03/1990';
      
      // If zodiac sign is empty but birth date exists, compute it
      if (user.zodiacSign.isEmpty && _fechaNacimientoController.text.isNotEmpty) {
        try {
          final parts = _fechaNacimientoController.text.split('/');
          if (parts.length == 3) {
            final dt = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
            _signoController.text = _obtenerSignoZodiacal(dt);
          }
        } catch (_) {}
      }
    }
  }

  String _obtenerSignoZodiacal(DateTime date) {
    int day = date.day;
    int month = date.month;
    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return 'Aries';
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return 'Tauro';
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return 'Géminis';
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return 'Cáncer';
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return 'Leo';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return 'Virgo';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return 'Libra';
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return 'Escorpio';
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return 'Sagitario';
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return 'Capricornio';
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return 'Acuario';
    return 'Piscis';
  }

  String _obtenerSignoEmoji(String signo) {
    switch (signo.trim().toLowerCase()) {
      case 'aries': return '♈';
      case 'tauro': return '♉';
      case 'géminis': case 'geminis': return '♊';
      case 'cáncer': case 'cancer': return '♋';
      case 'leo': return '♌';
      case 'virgo': return '♍';
      case 'libra': return '♎';
      case 'escorpio': return '♏';
      case 'sagitario': return '♐';
      case 'capricornio': return '♑';
      case 'acuario': return '♒';
      case 'piscis': return '♓';
      default: return '🔮';
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime(1990, 3, 15);
    if (_fechaNacimientoController.text.isNotEmpty) {
      try {
        final parts = _fechaNacimientoController.text.split('/');
        if (parts.length == 3) {
          initialDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      } catch (_) {}
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.textPrimary,
              surface: AppColors.bgSurface,
              onSurface: AppColors.textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.gold,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedDate = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      setState(() {
        _fechaNacimientoController.text = formattedDate;
        _signoController.text = _obtenerSignoZodiacal(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).userModel;
    final initials = user != null && user.name.isNotEmpty
        ? user.name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : '?';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.backgroundRadial,
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Custom Header/AppBar
              SliverAppBar(
                pinned: true,
                floating: false,
                expandedHeight: 60.0,
                backgroundColor: AppColors.bgBase.withOpacity(0.9),
                title: Text(
                  'MI PERFIL',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.gold,
                    letterSpacing: 2,
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryLight),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      // Avatar Section with glowing circular border
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const RadialGradient(
                                  colors: [
                                    Color(0x307C3AED),
                                    Color(0x0507060F),
                                  ],
                                ),
                                border: Border.all(
                                  color: AppColors.gold.withOpacity(0.5),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.35),
                                    blurRadius: 25,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 110,
                              height: 110,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.bgSurface,
                              ),
                              child: Center(
                                child: Text(
                                  initials,
                                  style: AppTextStyles.displayLarge.copyWith(
                                    fontSize: 32,
                                    color: AppColors.gold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                      
                      // User dynamic role display
                      if (user != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.bgElevated,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.borderGold),
                          ),
                          child: Text(
                            user.role == 'admin' ? 'ADMINISTRADOR' : 'MIEMBRO MÍSTICO',
                            style: AppTextStyles.labelGold.copyWith(fontSize: 10),
                          ),
                        ),

                      const SizedBox(height: 40),

                      // Form Fields
                      _buildProfileField(
                        label: 'Nombre Completo',
                        controller: _nombreController,
                        icon: Icons.person_rounded,
                      ),
                      const SizedBox(height: 20),

                      _buildProfileField(
                        label: 'Correo Electrónico',
                        controller: _emailController,
                        icon: Icons.email_rounded,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),

                      _buildProfileField(
                        label: 'Fecha de Nacimiento',
                        controller: _fechaNacimientoController,
                        icon: Icons.calendar_month_rounded,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                      ),
                      const SizedBox(height: 20),

                      _buildProfileField(
                        label: 'Signo Zodiacal (Calculado)',
                        controller: _signoController,
                        icon: Icons.auto_awesome_rounded,
                        readOnly: true,
                        suffixText: _obtenerSignoEmoji(_signoController.text),
                      ),
                      const SizedBox(height: 40),

                      // Save Button
                      GlowButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        gradient: AppGradients.goldButton,
                        glowColor: AppColors.gold,
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.bgBase),
                                ),
                              )
                            : Text(
                                'GUARDAR CAMBIOS',
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: AppColors.bgBase,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType keyboardType = TextInputType.text,
    String? suffixText,
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
              color: readOnly ? AppColors.borderSubtle : AppColors.borderPrimary,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            keyboardType: keyboardType,
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.primaryLight, size: 22),
              suffixIcon: suffixText != null
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.centerRight,
                      width: 50,
                      child: Text(
                        suffixText,
                        style: const TextStyle(fontSize: 24),
                      ),
                    )
                  : null,
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

  Future<void> _saveProfile() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUser;

    if (currentUser == null) return;
    if (_nombreController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El nombre y el correo electrónico son obligatorios.'),
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
        birthDate: _fechaNacimientoController.text.trim(),
      );
      await authService.reloadCurrentUser();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Tu perfil ha sido actualizado con éxito!'),
          backgroundColor: AppColors.bgElevated,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al guardar los cambios del perfil.'),
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
