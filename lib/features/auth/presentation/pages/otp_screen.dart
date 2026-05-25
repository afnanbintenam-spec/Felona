import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/spacing.dart';
import 'package:felo_na/features/auth/presentation/bloc/auth_bloc.dart';

/// OTP Verification Screen — 6-digit code input
/// Purposes: 'email_verification' (after register/login) or 'password_reset'
class OtpScreen extends StatefulWidget {
  final String email;
  final String purpose;

  const OtpScreen({
    super.key,
    required this.email,
    required this.purpose,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:3000',
    validateStatus: (s) => s != null && s < 500,
  ));
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _loading = false;
  bool _canResend = false;
  int _secondsRemaining = 30;
  Timer? _timer;

  bool get _isVerification => widget.purpose == 'email_verification';

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _canResend = false;
      _secondsRemaining = 30;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  String get _otp => _controllers.map((c) => c.text).join();

  Future<void> _verifyOtp() async {
    final otp = _otp;
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all 6 digits'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final endpoint =
          _isVerification ? '/auth/verify-email' : '/auth/verify-reset-otp';

      final response = await _dio.post(endpoint, data: {
        'email': widget.email,
        'code': otp,
      });

      if (!mounted) return;

      if (response.statusCode == 200) {
        if (_isVerification) {
          // Email verified — got user + token
          final token = response.data['token'] as String;
          final userJson = response.data['user'] as Map<String, dynamic>;

          // Update bloc state to Authenticated
          await context
              .read<AuthBloc>()
              .setAuthenticatedFromVerification(token: token, userJson: userJson);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email verified! Welcome to FeloNa 🌱'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pushNamedAndRemoveUntil(context, '/main', (_) => false);
        } else {
          // Password reset OTP verified
          final resetToken = response.data['reset_token'] as String;
          Navigator.pushReplacementNamed(
            context,
            '/reset-password',
            arguments: {'reset_token': resetToken},
          );
        }
      } else {
        final msg = response.data['error']?.toString() ?? 'Verification failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.error),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connection error. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resendOtp() async {
    if (!_canResend) return;

    try {
      final endpoint = _isVerification
          ? '/auth/resend-verification'
          : '/auth/resend-reset-otp';

      final response = await _dio.post(endpoint, data: {
        'email': widget.email,
      });

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New code sent to your email'),
            backgroundColor: AppColors.success,
          ),
        );
        _startTimer();
        // Clear inputs
        for (final c in _controllers) c.clear();
        _focusNodes[0].requestFocus();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data['error']?.toString() ?? 'Failed to resend'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connection error'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _onDigitChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});

    // Auto-verify when all 6 digits entered
    if (_otp.length == 6 && !_loading) {
      _verifyOtp();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: Spacing.pagePadding,
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
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: const Icon(Icons.arrow_back_ios_rounded,
                        color: AppColors.textSecondary, size: 18),
                  ),
                ),
              ),
              Spacing.gap32,
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isVerification
                        ? Icons.mark_email_read_rounded
                        : Icons.lock_reset_rounded,
                    color: AppColors.primaryGreen,
                    size: 36,
                  ),
                ),
              ),
              Spacing.gap24,
              Text(
                _isVerification ? 'Verify your email' : 'Verify your code',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Spacing.gap8,
              Text(
                _isVerification
                    ? 'We sent a 6-digit code to\n${widget.email}'
                    : 'Enter the 6-digit code sent to\n${widget.email}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppColors.textTertiary,
                  height: 1.5,
                ),
              ),
              Spacing.gap32,
              // OTP boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, _otpBox),
              ),
              Spacing.gap24,
              Center(
                child: _canResend
                    ? GestureDetector(
                        onTap: _resendOtp,
                        child: const Text(
                          'Resend Code',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      )
                    : Text(
                        'Resend in 0:${_secondsRemaining.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: AppColors.textTertiary,
                        ),
                      ),
              ),
              Spacing.gap32,
              // Verify button
              GestureDetector(
                onTap: _loading ? null : _verifyOtp,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: _otp.length == 6
                        ? AppColors.primaryGreen
                        : AppColors.primaryGreen.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Verify',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
              Spacing.gap16,
              // Note for dev mode
              const Text(
                'In dev mode, check the backend terminal for your OTP code.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _otpBox(int index) {
    final hasValue = _controllers[index].text.isNotEmpty;
    return SizedBox(
      width: 48,
      height: 56,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        enabled: !_loading,
        autofocus: index == 0,
        onChanged: (value) => _onDigitChanged(index, value),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: AppColors.card,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: hasValue ? AppColors.primaryGreen : AppColors.border,
              width: hasValue ? 1.5 : 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: hasValue ? AppColors.primaryGreen : AppColors.border,
              width: hasValue ? 1.5 : 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.primaryGreen, width: 2),
          ),
        ),
      ),
    );
  }
}
