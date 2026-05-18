import 'package:flutter/material.dart';
import 'package:felo_na/core/constants/app_colors.dart';

/// Custom text field — Premium Dark Theme
/// Dark filled background, subtle border, green focus state
class CustomTextField extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final bool showPasswordToggle;

  const CustomTextField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.onChanged,
    this.showPasswordToggle = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      obscureText: widget.showPasswordToggle ? _obscureText : widget.obscureText,
      enabled: widget.enabled,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      onTap: widget.onTap,
      onChanged: widget.onChanged,
      style: const TextStyle(
        fontSize: 16,
        color: AppColors.textPrimary,
        fontFamily: 'Inter',
      ),
      cursorColor: AppColors.accentGreen,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,
        labelStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.textTertiary,
          fontFamily: 'Inter',
        ),
        hintStyle: const TextStyle(
          fontSize: 16,
          color: AppColors.textMuted,
          fontFamily: 'Inter',
        ),
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.showPasswordToggle
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textTertiary,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : widget.suffixIcon,
        filled: true,
        fillColor: widget.enabled ? AppColors.cardDark : AppColors.secondary300,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.accentGreen,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
        errorStyle: const TextStyle(
          fontSize: 12,
          color: AppColors.error,
        ),
        counterStyle: const TextStyle(
          fontSize: 12,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}
