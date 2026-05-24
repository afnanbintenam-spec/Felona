import 'package:flutter/material.dart';
import 'package:felo_na/core/constants/app_colors.dart';

/// Custom text field — Dark Teal theme
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
    super.key, required this.label, this.hintText, this.controller,
    this.validator, this.keyboardType, this.obscureText = false,
    this.enabled = true, this.maxLines = 1, this.maxLength,
    this.prefixIcon, this.suffixIcon, this.onTap, this.onChanged,
    this.showPasswordToggle = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscure = true;

  @override
  void initState() { super.initState(); _obscure = widget.obscureText; }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      obscureText: widget.showPasswordToggle ? _obscure : widget.obscureText,
      enabled: widget.enabled,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      onTap: widget.onTap,
      onChanged: widget.onChanged,
      style: const TextStyle(fontFamily: 'Inter', fontSize: 15, color: AppColors.textPrimary),
      cursorColor: AppColors.primaryGreen,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,
        labelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.textTertiary),
        hintStyle: const TextStyle(fontFamily: 'Inter', fontSize: 15, color: AppColors.textMuted),
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.showPasswordToggle
            ? IconButton(
                icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppColors.textTertiary, size: 20),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : widget.suffixIcon,
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.error, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.error, width: 1.5)),
        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.border)),
        errorStyle: const TextStyle(fontSize: 12, color: AppColors.error),
      ),
    );
  }
}
