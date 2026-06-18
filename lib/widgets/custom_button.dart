import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GlowButton(
      onPressed: onPressed,
      gradient: AppGradients.goldButton,
      glowColor: AppColors.gold,
      child: Text(
        text,
        style: AppTextStyles.titleMedium.copyWith(
          color: AppColors.bgBase,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
