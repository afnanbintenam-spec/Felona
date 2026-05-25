import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/spacing.dart';
import 'package:felo_na/core/widgets/inputs/custom_text_field.dart';
import 'package:felo_na/core/network/api_client.dart';

/// Change Password Screen — for authenticated users
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _dio = Dio(BaseOptions(baseUrl: ApiClient.baseUrl));
  final _storage = const FlutterSecureStorage();
  bool _loading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final token = await _storage.read(key: 'auth_token');
      if (token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }

      final response = await _dio.post('/auth/change-password', data: {
        'current_password': _currentPasswordController.text,
        'new_password': _newPasswordController.text,
      });

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } on DioException catch (e) {
      if (!mounted) return;
      final message = e.response?.data?['message'] ?? 'Failed to change password';
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
                    child: const Icon(Icons.security_rounded, color: AppColors.primaryGreen, size: 36),
                  ),
                ),
                Spacing.gap24,
                const Text('Change Password', textAlign: TextAlign.center, style: TextStyle(
                  fontFamily: 'Inter', fontSize: 24, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                )),
                Spacing.gap8,
                const Text(
                  'Update your password to keep your account secure.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter', fontSize: 14, color: AppColors.textTertiary,
                  ),
                ),
                Spacing.gap32,
                CustomTextField(
                  label: 'Current Password',
                  hintText: 'Enter current password',
                  controller: _currentPasswordController,
                  enabled: !_loading,
                  obscureText: true,
                  showPasswordToggle: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Current password is required';
                    return null;
                  },
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textTertiary, size: 20),
                ),
                Spacing.gap16,
                CustomTextField(
                  label: 'New Password',
                  hintText: 'Enter new password',
                  controller: _newPasswordController,
                  enabled: !_loading,
                  obscureText: true,
                  showPasswordToggle: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'New password is required';
                    if (v.length < 8) return 'Min 8 characters';
                    return null;
                  },
                  prefixIcon: const Icon(Icons.lock_rounded, color: AppColors.textTertiary, size: 20),
                ),
                Spacing.gap16,
                CustomTextField(
                  label: 'Confirm New Password',
                  hintText: 'Re-enter new password',
                  controller: _confirmPasswordController,
                  enabled: !_loading,
                  obscureText: true,
                  showPasswordToggle: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please confirm password';
                    if (v != _newPasswordController.text) return 'Passwords do not match';
                    return null;
                  },
                  prefixIcon: const Icon(Icons.lock_rounded, color: AppColors.textTertiary, size: 20),
                ),
                Spacing.gap32,
                GestureDetector(
                  onTap: _loading ? null : _changePassword,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: _loading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Change Password', style: TextStyle(
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
