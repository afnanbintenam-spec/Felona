import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/spacing.dart';
import 'package:felo_na/core/widgets/inputs/custom_text_field.dart';
import 'package:felo_na/core/network/api_client.dart';

/// Reset Password Screen — set new password after OTP verification
class ResetPasswordScreen extends StatefulWidget {
  final String resetToken;

  const ResetPasswordScreen({
    super.key,
    required this.resetToken,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _dio = Dio(BaseOptions(baseUrl: ApiClient.baseUrl));
  bool _loading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final response = await _dio.post('/auth/reset-password', data: {
        'reset_token': widget.resetToken,
        'new_password': _passwordController.text,
      });

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } on DioException catch (e) {
      if (!mounted) return;
      final message = e.response?.data?['message'] ?? 'Failed to reset password';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: Spacing.pagePadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Spacing.gap16,
                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textSecondary, size: 18),
                    ),
                  ),
                ),
                Spacing.gap32,
                // Icon
                Center(
                  child: Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.password_rounded, color: AppColors.primaryGreen, size: 36),
                  ),
                ),
                Spacing.gap24,
                const Text('Reset Password', textAlign: TextAlign.center, style: TextStyle(
                  fontFamily: 'Inter', fontSize: 24, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                )),
                Spacing.gap8,
                const Text(
                  'Create a new password for your account.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter', fontSize: 14, color: AppColors.textTertiary,
                  ),
                ),
                Spacing.gap32,
                CustomTextField(
                  label: 'New Password',
                  hintText: 'Enter new password',
                  controller: _passwordController,
                  enabled: !_loading,
                  obscureText: true,
                  showPasswordToggle: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 8) return 'Min 8 characters';
                    return null;
                  },
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textTertiary, size: 20),
                ),
                Spacing.gap16,
                CustomTextField(
                  label: 'Confirm Password',
                  hintText: 'Re-enter new password',
                  controller: _confirmController,
                  enabled: !_loading,
                  obscureText: true,
                  showPasswordToggle: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please confirm password';
                    if (v != _passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textTertiary, size: 20),
                ),
                Spacing.gap32,
                GestureDetector(
                  onTap: _loading ? null : _resetPassword,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: _loading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Reset Password', style: TextStyle(
                              fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white,
                            )),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
