import 'package:flutter/material.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/app_text_styles.dart';

class TextButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? textColor;
  final IconData? icon;

  const TextButtonWidget({
    super.key,
    required this.text,
    this.onPressed,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = textColor ?? AppColors.primary500;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: effectiveColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: effectiveColor),
                const SizedBox(width: 6),
                Text(
                  text,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: effectiveColor,
                  ),
                ),
              ],
            )
          : Text(
              text,
              style: AppTextStyles.labelLarge.copyWith(
                color: effectiveColor,
              ),
            ),
    );
  }
}
