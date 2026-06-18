import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────
class AppColors {
  // Backgrounds
  static const bgBase     = Color(0xFF07060F);
  static const bgSurface  = Color(0xFF0F0D1A);
  static const bgElevated = Color(0xFF1A1630);

  // Primary — Mystical Violet
  static const primary      = Color(0xFF7C3AED);
  static const primaryLight = Color(0xFFA78BFA);
  static const primaryDark  = Color(0xFF5B21B6);

  // Gold accent
  static const gold      = Color(0xFFD4AF37);
  static const goldLight = Color(0xFFF5D060);

  // Crimson (power / energy elements only)
  static const crimson      = Color(0xFF991B1B);
  static const crimsonLight = Color(0xFFEF4444);

  // Teal (limpiezas)
  static const teal = Color(0xFF34D399);

  // Text
  static const textPrimary   = Color(0xFFF0EDFF);
  static const textSecondary = Color(0xFFA78BFA);
  static const textMuted     = Color(0xFF6B5FA0);

  // Borders
  static const borderSubtle  = Color(0x1FA78BFA);
  static const borderGold    = Color(0x40D4AF37);
  static const borderPrimary = Color(0x60A78BFA);
}

// ─────────────────────────────────────────────
// GRADIENTS
// ─────────────────────────────────────────────
class AppGradients {
  static const backgroundRadial = RadialGradient(
    center: Alignment.topRight,
    radius: 1.6,
    colors: [Color(0xFF150F2E), AppColors.bgBase],
  );

  static const heroCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E1040), Color(0xFF0F0D1A), Color(0xFF0A0820)],
  );

  static const primaryButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B5CF6), Color(0xFF5B21B6)],
  );

  static const goldButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
  );

  // Service card gradients — unified dark palette, subtle hue variation
  static const tarotCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2E1065), Color(0xFF1A0F3E)],
  );
  static const horoscopoCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E1B4B), Color(0xFF0F0E28)],
  );
  static const limpiezasCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F3E3A), Color(0xFF071E1C)],
  );
  static const ritualesCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4A0E0E), Color(0xFF1F0606)],
  );

  // Progress bar gradients
  static const loveBar = LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFF9B1C1C)],
  );
  static const friendshipBar = LinearGradient(
    colors: [Color(0xFF34D399), Color(0xFF065F46)],
  );
  static const workBar = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFF92400E)],
  );
}

// ─────────────────────────────────────────────
// TEXT STYLES
// ─────────────────────────────────────────────
class AppTextStyles {
  static TextStyle displayLarge = GoogleFonts.cinzel(
    color: AppColors.textPrimary,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: 2,
  );

  static TextStyle titleLarge = GoogleFonts.cinzel(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 1,
  );

  static TextStyle titleMedium = GoogleFonts.cinzel(
    color: AppColors.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static TextStyle bodyLarge = GoogleFonts.inter(
    color: AppColors.textPrimary,
    fontSize: 16,
    height: 1.6,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    color: AppColors.textSecondary,
    fontSize: 14,
    height: 1.5,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    color: AppColors.textMuted,
    fontSize: 12,
    height: 1.4,
  );

  static TextStyle labelGold = GoogleFonts.cinzel(
    color: AppColors.gold,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.5,
  );
}

// ─────────────────────────────────────────────
// GLOBAL THEME
// ─────────────────────────────────────────────
class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgBase,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.gold,
        surface: AppColors.bgSurface,
        background: AppColors.bgBase,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgBase,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primaryLight),
        titleTextStyle: GoogleFonts.cinzel(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 2.5,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.bgElevated,
        contentTextStyle: GoogleFonts.inter(color: AppColors.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE WIDGETS
// ─────────────────────────────────────────────

/// Texto con relleno de gradiente
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Gradient gradient;

  const GradientText(this.text, {super.key, this.style, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(bounds),
      child: Text(text, style: style),
    );
  }
}

/// Botón con gradiente y glow
class GlowButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Gradient gradient;
  final Color glowColor;
  final double height;
  final double borderRadius;

  const GlowButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.gradient = AppGradients.primaryButton,
    this.glowColor = AppColors.primary,
    this.height = 54,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return SizedBox(
      height: height,
      child: Container(
        decoration: BoxDecoration(
          gradient: enabled ? gradient : null,
          color: enabled ? null : AppColors.bgElevated,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: glowColor.withOpacity(0.38),
                    blurRadius: 18,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

/// Botón secundario (outline con tinte)
class OutlineButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color color;
  final double height;

  const OutlineButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.color = AppColors.primary,
    this.height = 54,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5)),
          color: color.withOpacity(0.08),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

/// Línea decorativa de sección
class SectionDivider extends StatelessWidget {
  final Gradient gradient;
  const SectionDivider({
    super.key,
    this.gradient = const LinearGradient(
      colors: [Colors.transparent, AppColors.borderGold, Colors.transparent],
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: BoxDecoration(gradient: gradient),
    );
  }
}
