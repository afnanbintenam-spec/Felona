import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:felo_na/core/constants/app_theme.dart';
import 'package:felo_na/core/di/injection_container.dart' as di;
import 'package:felo_na/core/services/push_notification_service.dart';

// BLoCs
import 'package:felo_na/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:felo_na/features/marketplace/presentation/bloc/marketplace_bloc.dart';
import 'package:felo_na/features/pickup/presentation/bloc/pickup_bloc.dart';
import 'package:felo_na/features/eco_score/presentation/bloc/eco_bloc.dart';
import 'package:felo_na/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:felo_na/features/notifications/presentation/bloc/notifications_event.dart';

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
import 'package:felo_na/features/pickup/presentation/pages/schedule_pickup_screen.dart';
import 'package:felo_na/features/pickup/presentation/pages/pickup_tracking_screen.dart';
import 'package:felo_na/features/pickup/presentation/pages/pickup_history_screen.dart';
import 'package:felo_na/features/pickup/presentation/pages/rate_pickup_screen.dart';
import 'package:felo_na/features/pickup/presentation/pages/qr_scanner_screen.dart';

// Eco Score screens
import 'package:felo_na/features/eco_score/presentation/pages/eco_score_screen.dart';
import 'package:felo_na/features/eco_score/presentation/pages/leaderboard_screen.dart';

// Notification screens
import 'package:felo_na/features/notifications/presentation/pages/notifications_screen.dart';

/// Application entry point.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize dependency injection container
  await di.initializeDependencies();

  // Initialize push notifications
  final pushService = di.sl<PushNotificationService>();
  await pushService.initialize();

  runApp(const FeloNaApp());
}

class FeloNaApp extends StatefulWidget {
  const FeloNaApp({super.key});

  @override
  State<FeloNaApp> createState() => _FeloNaAppState();
}

class _FeloNaAppState extends State<FeloNaApp> {
  late final NotificationsBloc _notificationsBloc;

  @override
  void initState() {
    super.initState();
    _notificationsBloc = di.sl<NotificationsBloc>();

    // Wire push notifications to NotificationsBloc
    final pushService = di.sl<PushNotificationService>();
    pushService.onNotificationReceived = (data) {
      _notificationsBloc.add(NewNotificationReceived(data: data));
    };
    pushService.onTokenRefresh = (token) {
      // Register new token with backend
      di.sl<NotificationsBloc>(); // Token registration handled via repository
    };
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()),
        BlocProvider(create: (context) => di.sl<MarketplaceBloc>()),
        BlocProvider(create: (context) => di.sl<PickupBloc>()),
        BlocProvider(create: (context) => di.sl<EcoBloc>()),
        BlocProvider.value(value: _notificationsBloc),
      ],
      child: MaterialApp(
        title: 'FeloNa - Smart Waste Management',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: '/',
        onGenerateRoute: (settings) {
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
            case '/pickup-tracking':
              final args = settings.arguments as Map<String, dynamic>? ?? {};
              return MaterialPageRoute(
                builder: (_) => PickupTrackingScreen(
                  pickupId: args['pickupId'] ?? '',
                ),
              );
            case '/rate-pickup':
              final args = settings.arguments as Map<String, dynamic>? ?? {};
              return MaterialPageRoute(
                builder: (_) => RatePickupScreen(
                  pickupId: args['pickupId'] ?? '',
                ),
              );
            case '/qr-scanner':
              final args = settings.arguments as Map<String, dynamic>? ?? {};
              return MaterialPageRoute(
                builder: (_) => QrScannerScreen(
                  pickupId: args['pickupId'] ?? '',
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
          '/schedule-pickup': (context) => const SchedulePickupScreen(),
          '/pickup-history': (context) => const PickupHistoryScreen(),
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
