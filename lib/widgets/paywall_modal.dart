import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../services/database_service.dart';
import '../screens/select_plan_screen.dart';

class PaywallModal extends StatelessWidget {
  final String title;
  final String description;

  const PaywallModal({
    super.key,
    required this.title,
    required this.description,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String description,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => PaywallModal(
        title: title,
        description: description,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF13082A),
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(color: AppColors.gold, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withOpacity(0.15),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.0),
          child: Stack(
            children: [
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gold.withOpacity(0.05),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(
                          Icons.close,
                          color: AppColors.textPrimary.withOpacity(0.6),
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gold.withOpacity(0.1),
                        border: Border.all(
                          color: AppColors.gold.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withOpacity(0.2),
                            blurRadius: 15,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.lock_outline_rounded,
                          color: AppColors.gold,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cinzel(
                        color: AppColors.gold,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimary.withOpacity(0.85),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    GlowButton(
                      gradient: AppGradients.goldButton,
                      glowColor: AppColors.gold,
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SelectPlanScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'VER PLANES',
                        style: GoogleFonts.cinzel(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlineButton(
                      color: AppColors.gold,
                      onPressed: () async {
                        final db = DatabaseService();
                        final link = await db.getWhatsAppLink();
                        if (link.isNotEmpty) {
                          final uri = Uri.parse(link);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        }
                      },
                      child: Text(
                        'CONTACTAR MAESTRO',
                        style: GoogleFonts.cinzel(
                          color: AppColors.gold,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
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
    );
  }
}
