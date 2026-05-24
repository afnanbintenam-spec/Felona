import 'package:flutter/material.dart';
import 'package:felo_na/core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.pushReplacementNamed(context, '/onboarding');
    });
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fade,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('Assets/mainLogo.png', width: 120, height: 120, fit: BoxFit.contain),
              const SizedBox(height: 32),
              Image.asset('Assets/splash_illustration.png', width: 240, height: 180, fit: BoxFit.contain),
              const SizedBox(height: 32),
              const Text('FeloNa', style: TextStyle(
                fontFamily: 'Inter', fontSize: 26, fontWeight: FontWeight.w700,
                color: AppColors.primaryGreen,
              )),
              const SizedBox(height: 8),
              const Text('Save the World. Recycle. Reuse. Reward.', style: TextStyle(
                fontFamily: 'Inter', fontSize: 13, color: AppColors.textTertiary,
              )),
            ],
          ),
        ),
      ),
    );
  }
}
