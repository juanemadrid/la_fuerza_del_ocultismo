import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/plan_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'login_screen.dart';
import 'pending_approval_screen.dart';

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
        builder: (_) => PendingPaymentScreen(plan: _planSeleccionado!),
      ),
    );
  }
}

// ─── Tarjeta de plan ──────────────────────────────────────────────────────────

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

// ─── Pantalla de pago pendiente ───────────────────────────────────────────────

class PendingPaymentScreen extends StatelessWidget {
  final PlanModel plan;

  const PendingPaymentScreen({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [Color(0xFF1A0000), Color(0xFF0D0D0D)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Ícono
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFB71C1C), width: 2),
                    color: const Color(0xFFB71C1C).withOpacity(0.1),
                  ),
                  child: const Icon(
                    Icons.payment_outlined,
                    color: Color(0xFFB71C1C),
                    size: 44,
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'PLAN SELECCIONADO',
                  style: TextStyle(
                    color: Color(0xFFB71C1C),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 20),

                // Resumen del plan
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFB71C1C).withOpacity(0.4)),
                    color: const Color(0xFFB71C1C).withOpacity(0.06),
                  ),
                  child: Column(
                    children: [
                      Text(
                        plan.nombre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        plan.precioFormateado,
                        style: const TextStyle(
                          color: Color(0xFFB71C1C),
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${plan.dias} días de acceso',
                        style: const TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Instrucciones
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                    color: const Color(0xFF1A1A1A),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline, color: Color(0xFFB71C1C), size: 18),
                          SizedBox(width: 8),
                          Text(
                            'PASOS A SEGUIR',
                            style: TextStyle(
                              color: Color(0xFFB71C1C),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _paso('1', 'Contacta al maestro por WhatsApp'),
                      const SizedBox(height: 10),
                      _paso('2', 'Realiza el pago de ${plan.precioFormateado}'),
                      const SizedBox(height: 10),
                      _paso('3', 'El maestro activará tu membresía'),
                      const SizedBox(height: 10),
                      _paso('4', 'Inicia sesión y tendrás acceso completo'),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Botón WhatsApp
                FutureBuilder<String>(
                  future: DatabaseService().getWhatsAppLink(),
                  builder: (context, snapshot) {
                    final link = snapshot.data ?? '';
                    return SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: link.isNotEmpty
                            ? () async {
                                // Mensaje pre-cargado con el plan
                                final msg = Uri.encodeComponent(
                                  'Hola! Me registré en La Fuerza del Ocultismo y seleccioné el *${plan.nombre}* (${plan.precioFormateado} - ${plan.dias} días). ¿Cómo procedo con el pago?',
                                );
                                final url = Uri.parse('$link?text=$msg');
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url,
                                      mode: LaunchMode.externalApplication);
                                }
                              }
                            : null,
                        icon: const Icon(Icons.chat_outlined, size: 22, color: Colors.white),
                        label: const Text(
                          'CONTACTAR AL MAESTRO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),

                // Cerrar sesión
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton(
                    onPressed: () async {
                      await Provider.of<AuthService>(context, listen: false)
                          .signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Cerrar sesión',
                      style: TextStyle(color: Colors.white38),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _paso(String num, String texto) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFB71C1C).withOpacity(0.15),
            border: Border.all(color: const Color(0xFFB71C1C).withOpacity(0.4)),
          ),
          child: Center(
            child: Text(
              num,
              style: const TextStyle(
                color: Color(0xFFB71C1C),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
