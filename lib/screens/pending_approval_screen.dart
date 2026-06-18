import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).userModel;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.backgroundRadial,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated or glowing icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.gold.withOpacity(0.5), width: 2),
                      color: AppColors.primary.withOpacity(0.1),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.hourglass_empty_rounded,
                      color: AppColors.gold,
                      size: 60,
                    ),
                  ),
                  const SizedBox(height: 32),

                  Text(
                    'SOLICITUD ENVIADA',
                    style: AppTextStyles.displayLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      letterSpacing: 3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  if (user != null)
                    Text(
                      'Hola, ${user.name}',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.gold,
                        fontSize: 18,
                      ),
                    ),
                  const SizedBox(height: 16),

                  Text(
                    'Tu cuenta ha sido registrada en nuestro templo virtual.\n\nEl Maestro Leyson revisará tu solicitud y activará tu membresía para darte acceso completo a los oráculos, rituales y limpiezas sagradas.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary.withOpacity(0.7),
                      height: 1.7,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Info box
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderGold),
                      color: AppColors.bgSurface.withOpacity(0.6),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, color: AppColors.gold, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              '¿Qué debes hacer ahora?',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: AppColors.gold,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const _PasoItem(numero: '1', texto: 'Contacta al Maestro Leyson para coordinar la activación de tu plan.'),
                        const SizedBox(height: 12),
                        const _PasoItem(numero: '2', texto: 'Una vez coordinado, el maestro aprobará y activará tu membresía en el sistema.'),
                        const SizedBox(height: 12),
                        const _PasoItem(numero: '3', texto: 'Inicia sesión de nuevo para disfrutar de toda la sabiduría oculta y sus herramientas.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // WhatsApp button (Primary)
                  FutureBuilder<String>(
                    future: DatabaseService().getWhatsAppLink(),
                    builder: (context, snapshot) {
                      final link = snapshot.data ?? '';
                      return SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: link.isNotEmpty
                              ? () async {
                                  final planInfo = user != null && user.pendingPlanNombre != null
                                      ? ' el plan "${user.pendingPlanNombre}"'
                                      : ' la membresía';
                                  final msg = Uri.encodeComponent(
                                    '¡Hola Maestro Leyson! He registrado mi cuenta con el correo "${user?.email ?? ''}" y solicito la aprobación de$planInfo en la app. ¿Cómo procedo con el pago?',
                                  );
                                  final uri = Uri.parse('$link?text=$msg');
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                                  }
                                }
                              : null,
                          icon: const Icon(Icons.chat_rounded, size: 22, color: AppColors.bgBase),
                          label: Text(
                            'CONTACTAR AL MAESTRO',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.bgBase,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Secondary Button (Ir al Login / Cerrar Sesión)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () async {
                        await Provider.of<AuthService>(context, listen: false).signOut();
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.gold.withOpacity(0.5), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout_rounded, color: AppColors.gold, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'CERRAR SESIÓN / LOGIN',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PasoItem extends StatelessWidget {
  final String numero;
  final String texto;

  const _PasoItem({required this.numero, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.2),
            border: Border.all(color: AppColors.gold.withOpacity(0.4)),
          ),
          child: Center(
            child: Text(
              numero,
              style: AppTextStyles.labelGold.copyWith(
                fontSize: 11,
                color: AppColors.gold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            texto,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary.withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
