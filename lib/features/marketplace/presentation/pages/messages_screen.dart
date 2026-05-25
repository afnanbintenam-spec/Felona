import 'package:flutter/material.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/spacing.dart';

/// Messages/Chat Screen — Buyer's conversations with sellers
class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: Spacing.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Spacing.gap16,
                  const Text('Messages', style: TextStyle(
                    fontFamily: 'Inter', fontSize: 24, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  )),
                  Spacing.gap8,
                  const Text(
                    'Chat with sellers about items',
                    style: TextStyle(
                      fontFamily: 'Inter', fontSize: 14, color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Spacing.gap24,

            // Empty state (chat will be implemented with WebSocket later)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: AppColors.primaryGreen,
                        size: 36,
                      ),
                    ),
                    Spacing.gap16,
                    const Text('No conversations yet', style: TextStyle(
                      fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    )),
                    Spacing.gap8,
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 48),
                      child: Text(
                        'When you message a seller about an item, your conversations will appear here',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter', fontSize: 13, color: AppColors.textTertiary,
                          height: 1.5,
                        ),
                      ),
                    ),
                    Spacing.gap24,
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/marketplace'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('Browse Marketplace', style: TextStyle(
                          fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600,
                          color: Colors.white,
                        )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
