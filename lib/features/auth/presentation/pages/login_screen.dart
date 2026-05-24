import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/spacing.dart';
import 'package:felo_na/core/widgets/inputs/custom_text_field.dart';
import 'package:felo_na/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:felo_na/features/auth/presentation/bloc/auth_event.dart';
import 'package:felo_na/features/auth/presentation/bloc/auth_state.dart';

/// Login — Dark Teal Premium
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() { _email.dispose(); _password.dispose(); super.dispose(); }

  void _login() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(LoginRequested(
        email: _email.text.trim(), password: _password.text,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (ctx, state) {
          if (state is Authenticated) Navigator.pushReplacementNamed(ctx, '/main');
          if (state is AuthError) ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        },
        builder: (ctx, state) {
          final loading = state is AuthLoading;
          return SafeArea(
            child: SingleChildScrollView(
              padding: Spacing.pagePadding,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Spacing.gap40,
                    Center(child: Image.asset('Assets/mainLogo.png', width: 100, height: 100)),
                    Spacing.gap32,
                    const Text('Welcome back', textAlign: TextAlign.center, style: TextStyle(
                      fontFamily: 'Inter', fontSize: 24, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    )),
                    Spacing.gap8,
                    const Text('Sign in to your eco journey', textAlign: TextAlign.center, style: TextStyle(
                      fontFamily: 'Inter', fontSize: 14, color: AppColors.textTertiary,
                    )),
                    Spacing.gap32,
                    CustomTextField(
                      label: 'Email', hintText: 'your@email.com',
                      controller: _email, enabled: !loading,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      prefixIcon: const Icon(Icons.mail_outline_rounded, color: AppColors.textTertiary, size: 20),
                    ),
                    Spacing.gap16,
                    CustomTextField(
                      label: 'Password', hintText: 'Enter password',
                      controller: _password, enabled: !loading,
                      obscureText: true, showPasswordToggle: true,
                      validator: (v) => v == null || v.length < 8 ? 'Min 8 chars' : null,
                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textTertiary, size: 20),
                    ),
                    Spacing.gap24,
                    // Sign in button
                    GestureDetector(
                      onTap: loading ? null : _login,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(child: loading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Sign In', style: TextStyle(
                              fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white,
                            )),
                        ),
                      ),
                    ),
                    Spacing.gap24,
                    Row(children: [
                      const Expanded(child: Divider(color: AppColors.border)),
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('or', style: TextStyle(fontSize: 13, color: AppColors.textTertiary))),
                      const Expanded(child: Divider(color: AppColors.border)),
                    ]),
                    Spacing.gap24,
                    GestureDetector(
                      onTap: loading ? null : () => Navigator.pushNamed(context, '/register'),
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.primaryGreen, width: 1.5),
                        ),
                        child: const Center(child: Text('Create Account', style: TextStyle(
                          fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ))),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
