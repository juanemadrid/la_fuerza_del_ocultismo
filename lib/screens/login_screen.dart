import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../utils/google_popup_helper.dart';
import '../widgets/occult_logo.dart';
import '../widgets/mysterious_page_route.dart';
import 'home_screen.dart';
import 'register_screen.dart';
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
  bool _googleLoading = false;
  bool _hasNavigated = false;
  StreamSubscription<User?>? _authSubscription;

  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _biometricsAvailable = false;
  String? _savedEmail;
  String? _savedPassword;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
    // Protegido: si Firebase no arrancó (pasó en iPhone), igual se muestra el login
    // en vez de dejar la pantalla en negro.
    try {
      _authSubscription =
          FirebaseAuth.instance.authStateChanges().listen((user) {
        if (user != null && mounted && !_hasNavigated) {
          _irAlHome();
        }
      }, onError: (e) => debugPrint('DIAG_ERROR authStateChanges: $e'));
    } catch (e) {
      debugPrint('DIAG_ERROR login authStateChanges: $e');
    }
  }

  Future<void> _checkBiometrics() async {
    try {
      final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();

      if (!canAuthenticate) return;

      final List<BiometricType> availableBiometrics =
          await _localAuth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) return;

      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('saved_email');
      final savedPassword = prefs.getString('saved_password');
      final biometricsEnabled = prefs.getBool('biometrics_enabled') ?? false;

      if (mounted) {
        setState(() {
          _biometricsAvailable =
              biometricsEnabled && savedEmail != null && savedPassword != null;
          _savedEmail = savedEmail;
          _savedPassword = savedPassword;
        });

        if (_biometricsAvailable) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _iniciarSesionConHuella();
          });
        }
      }
    } catch (e) {
      debugPrint("Error checking biometrics: $e");
    }
  }

  Future<void> _iniciarSesionConHuella() async {
    if (_savedEmail == null || _savedPassword == null) return;
    try {
      final bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Escanea tu huella para acceder al portal sagrado',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated) {
        setState(() => _loading = true);
        final authService = Provider.of<AuthService>(context, listen: false);
        String? loginError =
            await authService.signIn(_savedEmail!, _savedPassword!);

        if (loginError != null) {
          if (mounted) {
            _showSnackBar(loginError, isError: true);
          }
          setState(() => _loading = false);
          return;
        }

        if (mounted) {
          int intentos = 0;
          while (authService.userModel == null && intentos < 10) {
            await Future.delayed(const Duration(milliseconds: 300));
            intentos++;
          }
          _irAlHome();
        }
      }
    } catch (e) {
      debugPrint("Error during biometrics login: $e");
      if (mounted) {
        _showSnackBar('Error de huella: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _preguntarActivarBiometria(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final yaPreguntado = prefs.getBool('biometrics_asked') ?? false;
    if (yaPreguntado) {
      _irAlHome();
      return;
    }

    final bool canAuthenticateWithBiometrics =
        await _localAuth.canCheckBiometrics;
    final bool canAuthenticate =
        canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
    if (!canAuthenticate) {
      _irAlHome();
      return;
    }

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.bgSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.borderGold),
          ),
          title: Text(
            '¿Activar Huella Digital?',
            style: AppTextStyles.titleLarge.copyWith(color: AppColors.gold),
          ),
          content: Text(
            '¿Deseas activar el inicio de sesión con tu huella digital para entrar más rápido la próxima vez?',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textPrimary),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await prefs.setBool('biometrics_asked', true);
                await prefs.setBool('biometrics_enabled', false);
                if (mounted) Navigator.pop(context);
                _irAlHome();
              },
              child: Text(
                'No, gracias',
                style: AppTextStyles.titleMedium
                    .copyWith(color: AppColors.textMuted),
              ),
            ),
            TextButton(
              onPressed: () async {
                await prefs.setBool('biometrics_asked', true);
                await prefs.setBool('biometrics_enabled', true);
                await prefs.setString('saved_email', email);
                await prefs.setString('saved_password', password);
                if (mounted) Navigator.pop(context);
                _irAlHome();
              },
              child: Text(
                'Sí, activar',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _irAlHome() {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;
    final user = Provider.of<AuthService>(context, listen: false).userModel;
    if (user?.role == 'admin') {
      Navigator.of(context).pushReplacement(
        MysteriousPageRoute(child: const AdminDashboard(isRoot: true)),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MysteriousPageRoute(child: const HomeScreen()),
      );
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
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
      _showSnackBar(
        'La contraseña debe tener al menos 6 caracteres',
        isError: true,
      );
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

        final prefs = await SharedPreferences.getInstance();
        final biometricsEnabled = prefs.getBool('biometrics_enabled') ?? false;

        if (biometricsEnabled) {
          await prefs.setString('saved_email', usuario);
          await prefs.setString('saved_password', contrasena);
          _irAlHome();
        } else {
          final yaPreguntado = prefs.getBool('biometrics_asked') ?? false;
          final bool canAuth = await _localAuth.canCheckBiometrics ||
              await _localAuth.isDeviceSupported();
          if (canAuth && !yaPreguntado) {
            await _preguntarActivarBiometria(usuario, contrasena);
          } else {
            _irAlHome();
          }
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
    final emailController =
        TextEditingController(text: _usuarioController.text.trim());
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ingresa tu correo y te enviaremos un enlace para restablecer tu contraseña:',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'correo@ejemplo.com',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                filled: true,
                fillColor: AppColors.bgElevated,
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: AppColors.gold,
                  size: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderGold),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: AppTextStyles.titleMedium
                  .copyWith(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty || !EmailValidator.validate(email)) {
                _showSnackBar(
                  'Por favor ingresa un correo válido',
                  isError: true,
                );
                return;
              }
              Navigator.pop(context);
              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                _showSnackBar(
                  '¡Enlace enviado! Revisa tu bandeja de entrada o spam.',
                );
              } catch (e) {
                _showSnackBar(
                  'No se pudo enviar el correo. Verifica que esté registrado.',
                  isError: true,
                );
              }
            },
            child: const Text(
              'Enviar Enlace',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _iniciarSesionConGoogle() async {
    if (_loading || _googleLoading) return;
    final authService = Provider.of<AuthService>(context, listen: false);
    setState(() {
      _loading = true;
      _googleLoading = true;
    });

    try {
      final String? error = await authService.signInWithGoogle();

      if (error != null) {
        if (mounted) _showSnackBar(error, isError: true);
        return;
      }

      if (mounted && FirebaseAuth.instance.currentUser != null) {
        int intentos = 0;
        while (authService.userModel == null && intentos < 4) {
          await Future.delayed(const Duration(milliseconds: 150));
          intentos++;
        }
        _irAlHome();
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _googleLoading = false;
        });
      }
    }
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
                opacity: 0.20,
                child: Image.asset(
                  'assets/images/background.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: isSmallScreen ? 10 : 16,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OccultLogo(size: isSmallScreen ? 70 : 85),
                        const SizedBox(height: 12),
                        Text(
                          'LA FUERZA',
                          style: AppTextStyles.displayLarge.copyWith(
                            fontSize: isSmallScreen ? 20 : 23,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'DEL OCULTISMO',
                          style: AppTextStyles.labelGold.copyWith(
                            fontSize: isSmallScreen ? 10 : 11,
                            letterSpacing: 3,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 14 : 18),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: isSmallScreen ? 16 : 20,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            color: const Color(0xFF141416).withOpacity(0.92),
                            border: Border.all(
                              color: AppColors.borderGold.withOpacity(0.35),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Acceso Privado',
                                style: AppTextStyles.titleLarge.copyWith(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ingresa al portal privado de tarot, horóscopo y rituales.',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.white.withOpacity(0.6),
                                  height: 1.3,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildField(
                                controller: _usuarioController,
                                label: 'Correo Electrónico',
                                hint: 'tu@correo.com',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                isSmall: isSmallScreen,
                              ),
                              const SizedBox(height: 12),
                              _buildField(
                                controller: _contrasenaController,
                                label: 'Contraseña',
                                hint: 'Mínimo 6 caracteres',
                                icon: Icons.lock_outline,
                                obscureText: _obscurePassword,
                                isSmall: isSmallScreen,
                                suffixIcon: IconButton(
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: Colors.white.withOpacity(0.5),
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _olvidoContrasena,
                                  style: TextButton.styleFrom(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    '¿Olvidaste tu contraseña?',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.gold,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: GlowButton(
                                      onPressed:
                                          _loading ? null : _iniciarSesion,
                                      gradient: AppGradients.goldButton,
                                      glowColor: AppColors.gold,
                                      height: 48,
                                      child: _loading
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(AppColors.bgBase),
                                              ),
                                            )
                                          : Text(
                                              'INICIAR SESIÓN',
                                              style: AppTextStyles.titleMedium
                                                  .copyWith(
                                                    color: AppColors.bgBase,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                    letterSpacing: 0.5,
                                                  ),
                                            ),
                                    ),
                                  ),
                                  if (_biometricsAvailable) ...[
                                    const SizedBox(width: 10),
                                    Container(
                                      height: 48,
                                      width: 48,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: AppColors.borderGold
                                              .withOpacity(0.6),
                                          width: 1.2,
                                        ),
                                        color: const Color(0xFF1C1C1F),
                                      ),
                                      child: IconButton(
                                        onPressed: _loading
                                            ? null
                                            : _iniciarSesionConHuella,
                                        icon: const Icon(
                                          Icons.fingerprint_rounded,
                                          color: AppColors.gold,
                                          size: 26,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      color: Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                    ),
                                    child: Text(
                                      'o',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: Colors.white.withOpacity(0.4),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      color: Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              OutlineButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MysteriousPageRoute(
                                    child: const RegisterScreen(),
                                  ),
                                ),
                                height: 48,
                                child: Text(
                                  'CREAR CUENTA',
                                  style: AppTextStyles.titleMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Botón Google Sign-In
                              SizedBox(
                                height: 48,
                                child: Material(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: (_loading || _googleLoading)
                                        ? null
                                        : _iniciarSesionConGoogle,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if (_googleLoading) ...[
                                            const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Color(0xFF4285F4)),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              'Conectando con Google...',
                                              style: AppTextStyles.titleMedium
                                                  .copyWith(
                                                    color: const Color(
                                                      0xFF3C4043,
                                                    ),
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                  ),
                                            ),
                                          ] else ...[
                                            Image.network(
                                              'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.png',
                                              width: 20,
                                              height: 20,
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(
                                                    Icons.g_mobiledata_rounded,
                                                    color: Color(0xFF4285F4),
                                                    size: 24,
                                                  ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Continuar con Google',
                                              style: AppTextStyles.titleMedium
                                                  .copyWith(
                                                    color: const Color(
                                                      0xFF3C4043,
                                                    ),
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                  ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
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
    bool isSmall = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w600,
              fontSize: 13,
              letterSpacing: 0.2,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: const Color(0xFF1A1A1E).withOpacity(0.85),
            border: Border.all(
              color: AppColors.borderGold.withOpacity(0.45),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white,
              fontSize: 15,
            ),
            cursorColor: AppColors.gold,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.35),
                fontSize: 13,
              ),
              prefixIcon: Icon(icon, color: AppColors.gold, size: 20),
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: Colors.transparent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
