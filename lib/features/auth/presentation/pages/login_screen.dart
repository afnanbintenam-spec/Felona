import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/spacing.dart';
import 'package:felo_na/core/widgets/inputs/custom_text_field.dart';
import 'package:felo_na/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:felo_na/features/auth/presentation/bloc/auth_event.dart';
import 'package:felo_na/features/auth/presentation/bloc/auth_state.dart';

/// Login — Klima-inspired with nature background and glass-morphism card.
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
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(LoginRequested(
            email: _email.text.trim(),
            password: _password.text,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (ctx, state) {
          if (state is Authenticated) {
            Navigator.pushReplacementNamed(ctx, '/main');
          }
          if (state is EmailVerificationRequired) {
            Navigator.pushNamed(ctx, '/otp', arguments: {
              'email': state.email,
              'purpose': 'email_verification',
            });
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error),
            );
          }
        },
        builder: (ctx, state) {
          final loading = state is AuthLoading;
          return Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              Image.asset(
                'Assets/backgrounds/bg_ocean.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: AppColors.background),
              ),
              // Dark overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.4),
                      Colors.black.withValues(alpha: 0.75),
                    ],
                  ),
                ),
              ),
              // Content
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 60),
                        // Logo
                        Center(
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryGreen
                                      .withValues(alpha: 0.4),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.eco_rounded,
                                color: Colors.white, size: 36),
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Welcome back',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Finlandica',
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to your eco journey',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Glass card for inputs
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12),
                                width: 1),
                          ),
                          child: Column(
                            children: [
                              CustomTextField(
                                label: 'Email',
                                hintText: 'your@email.com',
                                controller: _email,
                                enabled: !loading,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Required'
                                    : null,
                                prefixIcon: const Icon(
                                    Icons.mail_outline_rounded,
                                    color: AppColors.textTertiary,
                                    size: 20),
                              ),
                              Spacing.gap16,
                              CustomTextField(
                                label: 'Password',
                                hintText: 'Enter password',
                                controller: _password,
                                enabled: !loading,
                                obscureText: true,
                                showPasswordToggle: true,
                                validator: (v) => v == null || v.length < 8
                                    ? 'Min 8 chars'
                                    : null,
                                prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                    color: AppColors.textTertiary,
                                    size: 20),
                              ),
                              Spacing.gap12,
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () => Navigator.pushNamed(
                                      context, '/forgot-password'),
                                  child: const Text(
                                    'Forgot password?',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primaryGreen,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Sign in button
                        GestureDetector(
                          onTap: loading ? null : _login,
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryGreen
                                      .withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white))
                                  : const Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Divider
                        Row(children: [
                          Expanded(
                              child: Divider(
                                  color:
                                      Colors.white.withValues(alpha: 0.2))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('or',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white
                                        .withValues(alpha: 0.5))),
                          ),
                          Expanded(
                              child: Divider(
                                  color:
                                      Colors.white.withValues(alpha: 0.2))),
                        ]),
                        const SizedBox(height: 24),
                        // Create account button
                        GestureDetector(
                          onTap: loading
                              ? null
                              : () =>
                                  Navigator.pushNamed(context, '/register'),
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1.5),
                              color: Colors.white.withValues(alpha: 0.06),
                            ),
                            child: const Center(
                              child: Text(
                                'Create Account',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
