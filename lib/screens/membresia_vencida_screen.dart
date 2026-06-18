import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'select_plan_screen.dart';

class MembresiaVencidaScreen extends StatelessWidget {
  const MembresiaVencidaScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  // Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.gold.withOpacity(0.5), width: 2),
                      color: AppColors.primary.withOpacity(0.1),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.25),
                          blurRadius: 25,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lock_clock_rounded,
                      color: AppColors.gold,
                      size: 60,
                    ),
                  ),
                  const SizedBox(height: 32),

                  Text(
                    'MEMBRESÍA VENCIDA',
                    style: AppTextStyles.displayLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      letterSpacing: 3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Tu membresía ha expirado.\nPara continuar accediendo a los oráculos, rituales y limpiezas del maestro, renueva tu suscripción.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary.withOpacity(0.7),
                      height: 1.7,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Info box/templo
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderGold),
                      color: AppColors.bgSurface.withOpacity(0.6),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: AppColors.gold, size: 24),
                        const SizedBox(height: 12),
                        Text(
                          'El camino espiritual no se detiene. Adquiere un nuevo plan para reactivar tu cuenta y continuar recibiendo la guía y sabiduría del Maestro Leyson.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary.withOpacity(0.8),
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Renovate button (Primary)
                  GlowButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const SelectPlanScreen()),
                      );
                    },
                    gradient: AppGradients.goldButton,
                    glowColor: AppColors.gold,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.workspace_premium_rounded, color: AppColors.bgBase, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'RENOVAR MEMBRESÍA',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.bgBase,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Log out button (Secondary)
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
                        side: BorderSide(color: AppColors.textSecondary.withOpacity(0.5), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout_rounded, color: AppColors.textSecondary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'CERRAR SESIÓN',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.textSecondary,
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
