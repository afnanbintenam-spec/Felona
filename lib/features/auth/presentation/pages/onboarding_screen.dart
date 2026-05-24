import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:felo_na/core/constants/app_colors.dart';

/// Onboarding — Dark teal with SVG illustrations
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pc = PageController();
  int _page = 0;

  final _pages = [
    _PD('Assets/illustrations/onboarding_reuse.svg', 'Reuse',
        'Give your items a second life.\nList what you no longer need.'),
    _PD('Assets/illustrations/onboarding_reduce.svg', 'Reduce',
        'Schedule waste pickups effortlessly.\nReduce your footprint every day.'),
    _PD('Assets/illustrations/onboarding_recycle.svg', 'Recycle',
        'Earn eco points for every action.\nMake sustainability rewarding.'),
  ];

  @override
  void dispose() { _pc.dispose(); super.dispose(); }

  void _next() {
    if (_page < 2) {
      _pc.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 24, top: 12),
              child: Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text('Skip', style: TextStyle(
                    fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  )),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pc,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: 3,
                itemBuilder: (_, i) => _buildPage(_pages[i]),
              ),
            ),
            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _page == i ? 24 : 8, height: 8,
                decoration: BoxDecoration(
                  color: _page == i ? AppColors.primaryGreen : AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),
            const SizedBox(height: 32),
            // Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GestureDetector(
                onTap: _next,
                child: Container(
                  width: double.infinity, height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(child: Text(
                    _page < 2 ? 'Continue' : 'Get Started',
                    style: const TextStyle(
                      fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  )),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_PD p) {
    return Column(
      children: [
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SvgPicture.asset(p.svg, fit: BoxFit.contain),
          ),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(p.title, style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 26, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text(p.desc, style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 14, height: 1.6,
                  color: AppColors.textSecondary,
                ), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PD {
  final String svg, title, desc;
  _PD(this.svg, this.title, this.desc);
}
