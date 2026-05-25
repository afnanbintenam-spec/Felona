import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:felo_na/features/auth/presentation/bloc/auth_event.dart';
import 'package:felo_na/features/auth/presentation/bloc/auth_state.dart';

/// Splash Screen with proper auth check.
///
/// Flow:
/// 1. Show branding animation
/// 2. Check if user has a valid token
/// 3. Navigate to /main (authenticated) or /onboarding (new user)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();

    // Trigger auth check
    context.read<AuthBloc>().add(const AuthCheckRequested());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigate(String route) {
    if (_navigated || !mounted) return;
    _navigated = true;
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Wait a minimum of 2 seconds for branding, then navigate
        Future.delayed(const Duration(seconds: 2), () {
          if (state is Authenticated) {
            _navigate('/main');
          } else if (state is Unauthenticated) {
            _navigate('/onboarding');
          } else if (state is AuthError) {
            _navigate('/onboarding');
          }
        });
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: FadeTransition(
          opacity: _fade,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('Assets/mainLogo.png',
                    width: 120, height: 120, fit: BoxFit.contain),
                const SizedBox(height: 32),
                Image.asset('Assets/splash_illustration.png',
                    width: 240, height: 180, fit: BoxFit.contain),
                const SizedBox(height: 32),
                const Text('FeloNa',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGreen,
                    )),
                const SizedBox(height: 8),
                const Text('Save the World. Recycle. Reuse. Reward.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: AppColors.textTertiary,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
