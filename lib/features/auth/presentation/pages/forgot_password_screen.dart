import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/spacing.dart';
import 'package:felo_na/core/widgets/inputs/custom_text_field.dart';

/// Forgot Password Screen — sends reset code to email
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final response = await _dio.post('/auth/forgot-password', data: {
        'email': _emailController.text.trim(),
      });

      if (!mounted) return;

      if (response.statusCode == 200) {
        Navigator.pushNamed(context, '/otp', arguments: {
          'email': _emailController.text.trim(),
          'purpose': 'password_reset',
        });
      }
    } on DioException catch (e) {
      if (!mounted) return;
      final message = e.response?.data?['message'] ?? 'Failed to send reset code';
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
                    child: const Icon(Icons.lock_reset_rounded, color: AppColors.primaryGreen, size: 36),
                  ),
                ),
                Spacing.gap24,
                const Text('Forgot Password?', textAlign: TextAlign.center, style: TextStyle(
                  fontFamily: 'Inter', fontSize: 24, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                )),
                Spacing.gap8,
                const Text(
                  'Enter your email address and we\'ll send you a code to reset your password.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter', fontSize: 14, color: AppColors.textTertiary,
                  ),
                ),
                Spacing.gap32,
                CustomTextField(
                  label: 'Email',
                  hintText: 'your@gmail.com',
                  controller: _emailController,
                  enabled: !_loading,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                  prefixIcon: const Icon(Icons.mail_outline_rounded, color: AppColors.textTertiary, size: 20),
                ),
                Spacing.gap32,
                GestureDetector(
                  onTap: _loading ? null : _sendResetCode,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: _loading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Send Reset Code', style: TextStyle(
                              fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white,
                            )),
                    ),
                  ),
                ),
                Spacing.gap24,
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text('Back to Login', style: TextStyle(
                      fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500,
                      color: AppColors.primaryGreen,
                    )),
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
