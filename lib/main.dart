import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:felo_na/core/constants/app_theme.dart';
import 'package:felo_na/core/di/injection_container.dart' as di;

// BLoCs
import 'package:felo_na/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:felo_na/features/marketplace/presentation/bloc/marketplace_bloc.dart';
import 'package:felo_na/features/pickup/presentation/bloc/pickup_bloc.dart';
import 'package:felo_na/features/eco_score/presentation/bloc/eco_bloc.dart';
import 'package:felo_na/features/notifications/presentation/bloc/notifications_bloc.dart';

// Auth screens
import 'package:felo_na/features/auth/presentation/pages/splash_screen.dart';
import 'package:felo_na/features/auth/presentation/pages/onboarding_screen.dart';
import 'package:felo_na/features/auth/presentation/pages/login_screen.dart';
import 'package:felo_na/features/auth/presentation/pages/register_screen.dart';
import 'package:felo_na/features/auth/presentation/pages/profile_screen.dart';
import 'package:felo_na/features/auth/presentation/pages/forgot_password_screen.dart';
import 'package:felo_na/features/auth/presentation/pages/otp_screen.dart';
import 'package:felo_na/features/auth/presentation/pages/reset_password_screen.dart';
import 'package:felo_na/features/auth/presentation/pages/change_password_screen.dart';

// AI screens
import 'package:felo_na/features/ai/presentation/pages/waste_scanner_screen.dart';
import 'package:felo_na/features/ai/presentation/pages/recycling_chat_screen.dart';

// Marketplace screens
import 'package:felo_na/features/marketplace/presentation/pages/main_screen.dart';
import 'package:felo_na/features/marketplace/presentation/pages/dashboard_screen.dart';
import 'package:felo_na/features/marketplace/presentation/pages/marketplace_screen.dart';
import 'package:felo_na/features/marketplace/presentation/pages/create_listing_screen.dart';
import 'package:felo_na/features/marketplace/presentation/pages/item_detail_screen.dart';

// Pickup screens
import 'package:felo_na/features/pickup/presentation/pages/next_collection_screen.dart';
import 'package:felo_na/features/pickup/presentation/pages/sorting_guide_screen.dart';
import 'package:felo_na/features/pickup/presentation/pages/create_pickup_screen.dart';

// Eco Score screens
import 'package:felo_na/features/eco_score/presentation/pages/eco_score_screen.dart';
import 'package:felo_na/features/eco_score/presentation/pages/leaderboard_screen.dart';

// Notification screens
import 'package:felo_na/features/notifications/presentation/pages/notifications_screen.dart';

/// Application entry point.
///
/// Initializes the dependency injection container before running the app.
/// This ensures all services are registered and available throughout the app.
void main() async {
  // Ensure Flutter bindings are initialized before any async operations
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection container
  await di.initializeDependencies();

  runApp(const FeloNaApp());
}

class FeloNaApp extends StatelessWidget {
  const FeloNaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()),
        BlocProvider(create: (context) => MarketplaceBloc()),
        BlocProvider(create: (context) => PickupBloc()),
        BlocProvider(create: (context) => EcoBloc()),
        BlocProvider(create: (context) => NotificationsBloc()),
      ],
      child: MaterialApp(
        title: 'FeloNa - Smart Waste Management',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          // Routes that need arguments
          switch (settings.name) {
            case '/otp':
              final args = settings.arguments as Map<String, dynamic>? ?? {};
              return MaterialPageRoute(
                builder: (_) => OtpScreen(
                  email: args['email'] ?? '',
                  purpose: args['purpose'] ?? 'email_verification',
                ),
              );
            case '/reset-password':
              final args = settings.arguments as Map<String, dynamic>? ?? {};
              return MaterialPageRoute(
                builder: (_) => ResetPasswordScreen(
                  resetToken: args['reset_token'] ?? '',
                ),
              );
            default:
              return null;
          }
        },
        routes: {
          '/': (context) => const SplashScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/main': (context) => const MainScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/marketplace': (context) => const MarketplaceScreen(),
          '/create-listing': (context) => const CreateListingScreen(),
          '/item-detail': (context) => const ItemDetailScreen(),
          '/next-collection': (context) => const NextCollectionScreen(),
          '/sorting-guide': (context) => const SortingGuideScreen(),
          '/create-pickup': (context) => const CreatePickupScreen(),
          '/eco-score': (context) => const EcoScoreScreen(),
          '/notifications': (context) => const NotificationsScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/waste-scanner': (context) => const WasteScannerScreen(),
          '/recycling-chat': (context) => const RecyclingChatScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/change-password': (context) => const ChangePasswordScreen(),
          '/leaderboard': (context) => const LeaderboardScreen(),
        },
      ),
    );
  }
}
