import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/plan_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/mysterious_page_route.dart';
import 'login_screen.dart';
import 'pending_approval_screen.dart';
import 'home_screen.dart';
import '../widgets/mystic_loader.dart';

class SelectPlanScreen extends StatefulWidget {
  const SelectPlanScreen({super.key});

  @override
  State<SelectPlanScreen> createState() => _SelectPlanScreenState();
}

class _SelectPlanScreenState extends State<SelectPlanScreen> {
  PlanModel? _planSeleccionado;
  bool _guardando = false;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).userModel;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        automaticallyImplyLeading: false,
        title: const Text(
          'ELIGE TU PLAN',
          style: TextStyle(
            color: Color(0xFFB71C1C),
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Provider.of<AuthService>(context, listen: false).signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Salir', style: TextStyle(color: Colors.white38)),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [Color(0xFF1A0000), Color(0xFF0D0D0D)],
          ),
        ),
        child: StreamBuilder<List<PlanModel>>(
          stream: DatabaseService().streamPlanes(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFB71C1C)),
              );
            }

            final planes = snapshot.data!.where((p) => p.activo).toList();

            if (planes.isEmpty) {
              return _buildSinPlanes(context);
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Saludo
                  if (user != null) ...[
                    Text(
                      'Hola, ${user.name} 👋',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  const Text(
                    'Selecciona el plan que mejor se adapte a ti para comenzar tu camino espiritual.',
                    style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  // Planes
                  ...planes.map((plan) => _PlanCard(
                    plan: plan,
                    isSelected: _planSeleccionado?.id == plan.id,
                    onTap: () => setState(() => _planSeleccionado = plan),
                  )),

                  const SizedBox(height: 24),

                  // Botón continuar
                  if (_planSeleccionado != null) ...[
                    _buildResumenPlan(),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _guardando ? null : _confirmarPlan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB71C1C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _guardando
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'CONTINUAR CON ESTE PLAN',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildResumenPlan() {
    final plan = _planSeleccionado!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB71C1C).withOpacity(0.5)),
        color: const Color(0xFFB71C1C).withOpacity(0.08),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFFB71C1C), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plan seleccionado: ${plan.nombre}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${plan.precioFormateado} · ${plan.dias} días',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSinPlanes(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, color: Color(0xFFB71C1C), size: 60),
            const SizedBox(height: 20),
            const Text(
              'No hay planes disponibles',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Contacta al maestro directamente para conocer los planes disponibles.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 32),
            _buildBotonWhatsApp(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonWhatsApp(BuildContext context) {
    return FutureBuilder<String>(
      future: DatabaseService().getWhatsAppLink(),
      builder: (context, snapshot) {
        final link = snapshot.data ?? '';
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: link.isNotEmpty
                ? () async {
                    final url = Uri.parse(link);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  }
                : null,
            icon: const Icon(Icons.chat_outlined, color: Colors.white),
            label: const Text(
              'CONTACTAR AL MAESTRO',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmarPlan() async {
    if (_planSeleccionado == null) return;
    final user = Provider.of<AuthService>(context, listen: false).userModel;
    if (user == null) return;

    setState(() => _guardando = true);

    await DatabaseService().setUserPendingPlan(
      user.uid,
      _planSeleccionado!.id,
      _planSeleccionado!.nombre,
      _planSeleccionado!.precio,
      planDias: _planSeleccionado!.dias,
    );

    if (!mounted) return;
    setState(() => _guardando = false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(plan: _planSeleccionado!),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PANTALLA DE PAGO AUTOMÁTICO SIMULADO (CHECKOUT)
// ─────────────────────────────────────────────
class CheckoutScreen extends StatefulWidget {
  final PlanModel plan;

  const CheckoutScreen({super.key, required this.plan});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numeroController = TextEditingController();
  final _nombreController = TextEditingController();
  final _expiracionController = TextEditingController();
  final _cvvController = TextEditingController();

  String _cardNumber = '•••• •••• •••• ••••';
  String _cardHolder = 'NOMBRE DEL TITULAR';
  String _expiry = 'MM/AA';
  bool _procesando = false;

  @override
  void initState() {
    super.initState();
    _numeroController.addListener(() {
      setState(() {
        _cardNumber = _numeroController.text.isEmpty
            ? '•••• •••• •••• ••••'
            : _numeroController.text;
      });
    });
    _nombreController.addListener(() {
      setState(() {
        _cardHolder = _nombreController.text.isEmpty
            ? 'NOMBRE DEL TITULAR'
            : _nombreController.text.toUpperCase();
      });
    });
    _expiracionController.addListener(() {
      setState(() {
        _expiry = _expiracionController.text.isEmpty
            ? 'MM/AA'
            : _expiracionController.text;
      });
    });
  }

  @override
  void dispose() {
    _numeroController.dispose();
    _nombreController.dispose();
    _expiracionController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _onCardNumberChanged(String value) {
    String text = value.replaceAll(' ', '');
    if (text.length > 16) text = text.substring(0, 16);
    
    String formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) formatted += ' ';
      formatted += text[i];
    }

    _numeroController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  void _onExpiryChanged(String value) {
    String text = value.replaceAll('/', '');
    if (text.length > 4) text = text.substring(0, 4);

    String formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i == 2) formatted += '/';
      formatted += text[i];
    }

    _expiracionController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  Future<void> _ejecutarPago() async {
    if (!_formKey.currentState!.validate()) return;
    final user = Provider.of<AuthService>(context, listen: false).userModel;
    if (user == null) return;

    setState(() => _procesando = true);

    await Future.delayed(const Duration(seconds: 3));

    try {
      await DatabaseService().activateSubscription(user.uid, widget.plan.dias);
      if (mounted) {
        await Provider.of<AuthService>(context, listen: false).reloadCurrentUser();
      }
      
      if (mounted) {
        setState(() => _procesando = false);
        _mostrarExitoModal();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _procesando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al procesar el pago: $e')),
        );
      }
    }
  }

  void _mostrarExitoModal() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Pago Exitoso',
      barrierColor: Colors.black.withOpacity(0.9),
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, anim1, anim2) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E0000), Color(0xFF0F0F0F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: AppColors.gold, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.35),
                    blurRadius: 30,
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.withOpacity(0.1),
                      border: Border.all(color: Colors.green, width: 2),
                    ),
                    child: const Icon(Icons.check_circle_rounded,
                        color: Colors.green, size: 44),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '¡PAGO PROCESADO!',
                    style: GoogleFonts.cinzel(
                      color: AppColors.gold,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tu suscripción al plan "${widget.plan.nombre.toUpperCase()}" ha sido aprobada y activada de forma automática por el sistema.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: const Text('INGRESAR AL APLICATIVO', style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_procesando) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D0D0D),
        body: Center(
          child: MysticLoader(
            text: 'Conectando con la pasarela bancaria...\nProcesando pago de ${widget.plan.precioFormateado}...',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.gold, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'PAGO SEGURO',
          style: GoogleFonts.cinzel(
            color: AppColors.gold,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [Color(0xFF1A0000), Color(0xFF0D0D0D)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildVirtualCard(),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PLAN: ${widget.plan.nombre.toUpperCase()}',
                            style: GoogleFonts.cinzel(
                              color: AppColors.gold,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Membresía por ${widget.plan.dias} días',
                            style: GoogleFonts.inter(color: Colors.white54, fontSize: 11),
                          ),
                        ],
                      ),
                      Text(
                        widget.plan.precioFormateado,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Datos de Facturación',
                  style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                _buildTextField(
                  controller: _nombreController,
                  label: 'Nombre del Titular',
                  hint: 'Como aparece en la tarjeta',
                  validator: (val) => val == null || val.trim().isEmpty ? 'Obligatorio' : null,
                ),
                const SizedBox(height: 14),

                _buildTextField(
                  controller: _numeroController,
                  label: 'Número de Tarjeta',
                  hint: '4000 1234 5678 9010',
                  keyboardType: TextInputType.number,
                  onChanged: _onCardNumberChanged,
                  validator: (val) {
                    if (val == null || val.replaceAll(' ', '').length < 16) {
                      return 'Número inválido (16 dígitos)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildTextField(
                        controller: _expiracionController,
                        label: 'Fecha Vence',
                        hint: 'MM/AA',
                        keyboardType: TextInputType.number,
                        onChanged: _onExpiryChanged,
                        validator: (val) {
                          if (val == null || val.length < 5) return 'Inválido';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 1,
                      child: _buildTextField(
                        controller: _cvvController,
                        label: 'CVV',
                        hint: '123',
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          if (val == null || val.length < 3) return 'Inválido';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_rounded, color: Colors.green, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Encriptación SSL segura provista por Stripe',
                      style: GoogleFonts.inter(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _ejecutarPago,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'PAGAR AHORA Y ACTIVAR',
                      style: GoogleFonts.cinzel(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVirtualCard() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF4A0000), Color(0xFF1E0000), Color(0xFF140000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.gold.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 18,
          )
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MEMBRESÍA PREMIUM',
                style: GoogleFonts.cinzel(
                  color: AppColors.gold,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              const Icon(Icons.credit_card_rounded, color: AppColors.gold, size: 24),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 32,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.gold.withOpacity(0.4)),
              ),
            ),
          ),
          Text(
            _cardNumber,
            style: GoogleFonts.spaceMono(
              color: Colors.white,
              fontSize: 17,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _cardHolder,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.spaceMono(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'VENCE',
                    style: GoogleFonts.spaceMono(color: Colors.white30, fontSize: 6),
                  ),
                  Text(
                    _expiry,
                    style: GoogleFonts.spaceMono(color: Colors.white70, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged,
      validator: validator,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: AppColors.gold.withOpacity(0.85), fontSize: 13),
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: Colors.white30, fontSize: 13),
        filled: true,
        fillColor: Colors.white.withOpacity(0.03),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.gold.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gold),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final PlanModel plan;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFB71C1C) : Colors.white12,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? const Color(0xFFB71C1C).withOpacity(0.1)
              : const Color(0xFF1A1A1A),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFB71C1C).withOpacity(0.2),
                    blurRadius: 16,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Radio
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFB71C1C)
                          : Colors.white24,
                      width: 2,
                    ),
                    color: isSelected
                        ? const Color(0xFFB71C1C)
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    plan.nombre,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Precio
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      plan.precioFormateado,
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFFB71C1C)
                            : Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${plan.dias} días',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            if (plan.descripcion.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                plan.descripcion,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],

            if (plan.beneficios.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(color: Colors.white12),
              const SizedBox(height: 8),
              ...plan.beneficios.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: isSelected
                          ? const Color(0xFFB71C1C)
                          : Colors.white38,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        b,
                        style: TextStyle(
                          color: isSelected ? Colors.white70 : Colors.white38,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }
}
