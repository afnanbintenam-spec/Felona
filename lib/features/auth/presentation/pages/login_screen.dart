import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/app_text_styles.dart';
import 'package:felo_na/core/widgets/buttons/primary_button.dart';
import 'package:felo_na/core/widgets/buttons/secondary_button.dart';
import 'package:felo_na/core/widgets/inputs/custom_text_field.dart';
import 'package:felo_na/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:felo_na/features/auth/presentation/bloc/auth_event.dart';
import 'package:felo_na/features/auth/presentation/bloc/auth_state.dart';

/// Login screen — Premium Dark Theme
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            LoginRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.pushReplacementNamed(context, '/main');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),

                    // Big Logo
                    Center(
                      child: Image.asset(
                        'Assets/mainLogo.png',
                        width: 160,
                        height: 160,
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Welcome Text
                    Text(
                      'Welcome Back',
                      style: AppTextStyles.displaySmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // Email Field
                    CustomTextField(
                      label: 'Email',
                      hintText: 'Enter your email',
                      controller: _emailController,
                      validator: _validateEmail,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !isLoading,
                      prefixIcon: const Icon(Icons.email_outlined,
                          color: AppColors.textTertiary),
                    ),

                    const SizedBox(height: 16),

                    // Password Field
                    CustomTextField(
                      label: 'Password',
                      hintText: 'Enter your password',
                      controller: _passwordController,
                      validator: _validatePassword,
                      obscureText: true,
                      showPasswordToggle: true,
                      enabled: !isLoading,
                      prefixIcon: const Icon(Icons.lock_outline,
                          color: AppColors.textTertiary),
                    ),

                    const SizedBox(height: 8),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Forgot password feature coming soon!'),
                                  ),
                                );
                              },
                        child: Text(
                          'Forgot Password?',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.accentGreen,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Login Button
                    PrimaryButton(
                      text: 'Log In',
                      onPressed: isLoading ? null : _handleLogin,
                      isLoading: isLoading,
                    ),

                    const SizedBox(height: 24),

                    // Divider
                    Row(
                      children: [
                        Expanded(
                            child: Divider(
                                color: AppColors.border, thickness: 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'or',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                        Expanded(
                            child: Divider(
                                color: AppColors.border, thickness: 1)),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Create Account Button
                    SecondaryButton(
                      text: 'Create Account',
                      onPressed: isLoading
                          ? null
                          : () => Navigator.pushNamed(context, '/register'),
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
