import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/app_text_styles.dart';
import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/core/widgets/buttons/primary_button.dart';
import 'package:felo_na/core/widgets/inputs/custom_text_field.dart';
import 'package:felo_na/core/widgets/cards/role_selection_card.dart';
import 'package:felo_na/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:felo_na/features/auth/presentation/bloc/auth_event.dart';
import 'package:felo_na/features/auth/presentation/bloc/auth_state.dart';

/// Registration — Klima-inspired with nature background.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  UserRole? _selectedRole;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your full name';
    if (value.length < 3) return 'Name must be at least 3 characters';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Please enter a valid email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      if (_selectedRole == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a role'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      context.read<AuthBloc>().add(
            RegisterRequested(
              fullName: _fullNameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text,
              role: _selectedRole!,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.pushReplacementNamed(context, '/main');
          } else if (state is EmailVerificationRequired) {
            Navigator.pushReplacementNamed(context, '/otp', arguments: {
              'email': state.email,
              'purpose': 'email_verification',
            });
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

          return Stack(
            fit: StackFit.expand,
            children: [
              // Background
              Image.asset(
                'Assets/backgrounds/bg_bins.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: AppColors.background),
              ),
              // Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.5),
                      Colors.black.withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),
              // Content
              SafeArea(
                child: Column(
                  children: [
                    // App bar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_rounded,
                                color: Colors.white, size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Expanded(
                            child: Text(
                              'Create Account',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Finlandica',
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                    // Scrollable form
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Glass card for inputs
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                      color: Colors.white
                                          .withValues(alpha: 0.12),
                                      width: 1),
                                ),
                                child: Column(
                                  children: [
                                    CustomTextField(
                                      label: 'Full Name',
                                      hintText: 'Enter your full name',
                                      controller: _fullNameController,
                                      validator: _validateFullName,
                                      enabled: !isLoading,
                                      prefixIcon: const Icon(
                                          Icons.person_outline,
                                          color: AppColors.textTertiary,
                                          size: 20),
                                    ),
                                    const SizedBox(height: 16),
                                    CustomTextField(
                                      label: 'Email',
                                      hintText: 'Enter your email',
                                      controller: _emailController,
                                      validator: _validateEmail,
                                      keyboardType:
                                          TextInputType.emailAddress,
                                      enabled: !isLoading,
                                      prefixIcon: const Icon(
                                          Icons.email_outlined,
                                          color: AppColors.textTertiary,
                                          size: 20),
                                    ),
                                    const SizedBox(height: 16),
                                    CustomTextField(
                                      label: 'Password',
                                      hintText: 'Enter your password',
                                      controller: _passwordController,
                                      validator: _validatePassword,
                                      obscureText: true,
                                      showPasswordToggle: true,
                                      enabled: !isLoading,
                                      prefixIcon: const Icon(
                                          Icons.lock_outline,
                                          color: AppColors.textTertiary,
                                          size: 20),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 28),
                              // Role selection
                              const Text(
                                'Select Your Role',
                                style: TextStyle(
                                  fontFamily: 'Finlandica',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 14),
                              RoleSelectionCard(
                                role: UserRole.normalUser,
                                isSelected:
                                    _selectedRole == UserRole.normalUser,
                                onTap: isLoading
                                    ? () {}
                                    : () => setState(() =>
                                        _selectedRole = UserRole.normalUser),
                              ),
                              const SizedBox(height: 12),
                              RoleSelectionCard(
                                role: UserRole.buyer,
                                isSelected: _selectedRole == UserRole.buyer,
                                onTap: isLoading
                                    ? () {}
                                    : () => setState(
                                        () => _selectedRole = UserRole.buyer),
                              ),
                              const SizedBox(height: 12),
                              RoleSelectionCard(
                                role: UserRole.collector,
                                isSelected:
                                    _selectedRole == UserRole.collector,
                                onTap: isLoading
                                    ? () {}
                                    : () => setState(() =>
                                        _selectedRole = UserRole.collector),
                              ),
                              const SizedBox(height: 32),
                              // Register button
                              GestureDetector(
                                onTap: isLoading ? null : _handleRegister,
                                child: Container(
                                  width: double.infinity,
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
                                    child: isLoading
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child:
                                                CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: Colors.white))
                                        : const Text(
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
                              const SizedBox(height: 20),
                              // Login link
                              Center(
                                child: GestureDetector(
                                  onTap: isLoading
                                      ? null
                                      : () =>
                                          Navigator.pushReplacementNamed(
                                              context, '/login'),
                                  child: RichText(
                                    text: TextSpan(
                                      text: 'Already have an account? ',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                        color: Colors.white
                                            .withValues(alpha: 0.6),
                                      ),
                                      children: const [
                                        TextSpan(
                                          text: 'Log in',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primaryGreen,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
