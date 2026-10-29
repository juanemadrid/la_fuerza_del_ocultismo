import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class CardDetailDialog extends StatelessWidget {
  final String nombre;
  final String significado;
  final int orden;
  final String? imageUrl;
  final String? subtitle;

  const CardDetailDialog({
    super.key,
    required this.nombre,
    required this.significado,
    required this.orden,
    this.imageUrl,
    this.subtitle,
  });

  static void show(
    BuildContext context, {
    required String nombre,
    required String significado,
    required int orden,
    String? imageUrl,
    String? subtitle,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Cerrar',
      barrierColor: Colors.black.withOpacity(0.75),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return CardDetailDialog(
          nombre: nombre,
          significado: significado,
          orden: orden,
          imageUrl: imageUrl,
          subtitle: subtitle,
        );
      },
      transitionBuilder: (context, anim, secondaryAnim, child) {
        final scaleAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
          CurvedAnimation(
            parent: anim,
            curve: Curves.easeOutBack,
          ),
        );
        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: anim,
            curve: Curves.easeInOut,
          ),
        );
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: FadeTransition(
            opacity: fadeAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: child,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double cardWidth = 180.0;
    final double cardHeight = 330.0;

    return Center(
      child: SingleChildScrollView(
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E0000), Color(0xFF111111), Color(0xFF0C0C0C)],
              ),
              border: Border.all(
                color: AppColors.gold.withOpacity(0.55),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.38),
                  blurRadius: 36,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.gold),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  Text(
                    subtitle!.toUpperCase(),
                    style: GoogleFonts.cinzel(
                      color: AppColors.gold,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Container(
                  width: cardWidth,
                  height: cardHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.borderGold.withOpacity(0.6),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.55),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: imageUrl != null && imageUrl!.isNotEmpty
                        ? Image.network(
                            imageUrl!,
                            width: cardWidth,
                            height: cardHeight,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Image.asset(
                              'assets/images/tarot/carta_$orden.png',
                              width: cardWidth,
                              height: cardHeight,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            'assets/images/tarot/carta_$orden.png',
                            width: cardWidth,
                            height: cardHeight,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  nombre.toUpperCase(),
                  style: GoogleFonts.cinzel(
                    color: AppColors.gold,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                Container(
                  width: 60,
                  height: 1.5,
                  color: AppColors.gold.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    significado,
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w400,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
