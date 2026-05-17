import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/core/widgets/navigation/bottom_nav_bar.dart';
import 'package:felo_na/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:felo_na/features/auth/presentation/bloc/auth_state.dart';
import 'package:felo_na/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:felo_na/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:felo_na/features/marketplace/presentation/pages/dashboard_screen.dart';
import 'package:felo_na/features/marketplace/presentation/pages/marketplace_screen.dart';
import 'package:felo_na/features/pickup/presentation/pages/next_collection_screen.dart';
import 'package:felo_na/features/eco_score/presentation/pages/eco_score_screen.dart';
import 'package:felo_na/features/auth/presentation/pages/profile_screen.dart';

/// Main screen with bottom navigation.
///
/// This is the primary container for the app after authentication.
/// It manages navigation between different sections based on user role.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! Authenticated) {
          // If not authenticated, redirect to login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/login');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = authState.user;
        final screens = _getScreensForRole(user.role);

        return BlocBuilder<NotificationsBloc, NotificationsState>(
          builder: (context, notifState) {
            final notificationCount = notifState is NotificationsLoaded
                ? notifState.unreadCount
                : 0;

            return Scaffold(
              body: IndexedStack(
                index: _currentIndex,
                children: screens,
              ),
              bottomNavigationBar: AppBottomNavBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                userRole: user.role,
                notificationCount: notificationCount,
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _getScreensForRole(UserRole role) {
    switch (role) {
      case UserRole.normalUser:
        return [
          const DashboardScreen(), // Home
          const MarketplaceScreen(), // Marketplace
          const NextCollectionScreen(), // Pickups
          const EcoScoreScreen(), // Eco Score
          const ProfileScreen(), // Profile
        ];

      case UserRole.buyer:
        return [
          const DashboardScreen(), // Home
          const MarketplaceScreen(), // Search
          const PlaceholderScreen(title: 'My Offers'), // My Offers
          const PlaceholderScreen(title: 'Messages'), // Messages
          const ProfileScreen(), // Profile
        ];

      case UserRole.collector:
        return [
          const DashboardScreen(), // Home
          const PlaceholderScreen(title: 'Jobs'), // Jobs
          const PlaceholderScreen(title: 'History'), // History
          const PlaceholderScreen(title: 'Earnings'), // Earnings
          const ProfileScreen(), // Profile
        ];
    }
  }
}

/// Placeholder screen for features not yet implemented.
class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray900,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: AppColors.gray300,
            ),
            const SizedBox(height: 16),
            Text(
              '$title Coming Soon',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.gray700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This feature is under development',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.gray500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
