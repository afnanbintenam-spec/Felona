import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Top-level background message handler (must be top-level function).
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('[FCM] Background message: ${message.messageId}');
}

/// Service for managing Firebase Cloud Messaging push notifications.
///
/// Handles:
/// - FCM token retrieval and refresh
/// - Foreground notification handling
/// - Background notification handling
/// - Notification tap handling (navigation)
class PushNotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Callback when a new notification is received in foreground.
  void Function(Map<String, dynamic> data)? onNotificationReceived;

  /// Callback when user taps a notification.
  void Function(Map<String, dynamic> data)? onNotificationTapped;

  /// Callback when FCM token is refreshed.
  void Function(String token)? onTokenRefresh;

  /// Initialize the push notification service.
  ///
  /// Must be called after Firebase.initializeApp().
  Future<void> initialize() async {
    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permission (iOS/Web)
    await _requestPermission();

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check if app was opened from a terminated state via notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((token) {
      debugPrint('[FCM] Token refreshed: $token');
      onTokenRefresh?.call(token);
    });
  }

  /// Request notification permissions.
  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('[FCM] Permission status: ${settings.authorizationStatus}');
  }

  /// Get the current FCM token.
  Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      debugPrint('[FCM] Token: $token');
      return token;
    } catch (e) {
      debugPrint('[FCM] Error getting token: $e');
      return null;
    }
  }

  /// Subscribe to a topic for targeted notifications.
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    debugPrint('[FCM] Subscribed to topic: $topic');
  }

  /// Unsubscribe from a topic.
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    debugPrint('[FCM] Unsubscribed from topic: $topic');
  }

  /// Handle foreground messages.
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('[FCM] Foreground message: ${message.messageId}');
    debugPrint('[FCM] Title: ${message.notification?.title}');
    debugPrint('[FCM] Body: ${message.notification?.body}');
    debugPrint('[FCM] Data: ${message.data}');

    final data = <String, dynamic>{
      'title': message.notification?.title ?? '',
      'message': message.notification?.body ?? '',
      ...message.data,
    };

    onNotificationReceived?.call(data);
  }

  /// Handle notification tap (app opened from notification).
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('[FCM] Notification tapped: ${message.messageId}');

    final data = <String, dynamic>{
      'title': message.notification?.title ?? '',
      'message': message.notification?.body ?? '',
      ...message.data,
    };

    onNotificationTapped?.call(data);
  }

  /// Delete the FCM token (e.g., on logout).
  Future<void> deleteToken() async {
    await _messaging.deleteToken();
    debugPrint('[FCM] Token deleted');
  }
}
