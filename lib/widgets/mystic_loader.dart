import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../theme/app_theme.dart';

class MysticLoader extends StatefulWidget {
  final String text;
  const MysticLoader({super.key, required this.text});

  @override
  State<MysticLoader> createState() => _MysticLoaderState();
}

class _MysticLoaderState extends State<MysticLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulse = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Aro giratorio exterior
                Transform.rotate(
                  angle: _controller.value * 2 * pi,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.gold.withOpacity(0.15 + 0.15 * _pulse.value),
                        width: 1.5,
                      ),
                    ),
                    child: Stack(
                      children: List.generate(4, (i) {
                        final angle = (i * pi / 2);
                        return Positioned(
                          left: 45 + 40 * cos(angle) - 3,
                          top: 45 + 40 * sin(angle) - 3,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.gold,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                // Aura roja/dorada pulsante
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3 * _pulse.value),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: AppColors.gold.withOpacity(0.15 * _pulse.value),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                // Icono central
                Opacity(
                  opacity: 0.5 + 0.5 * _pulse.value,
                  child: const Icon(
                    Icons.auto_awesome,
                    color: AppColors.gold,
                    size: 36,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              widget.text,
              style: GoogleFonts.cinzel(
                color: AppColors.textMuted,
                fontSize: 13,
                letterSpacing: 3,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }
}
