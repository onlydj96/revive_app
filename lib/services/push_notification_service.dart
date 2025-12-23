import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../utils/logger.dart';
import 'supabase_service.dart';

final _logger = Logger('PushNotificationService');

/// Background message handler - must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  _logger.debug('Handling background message: ${message.messageId}');
}

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  String? _currentToken;

  /// Android notification channel for high importance notifications
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'ezer_updates_channel',
    'Church Updates',
    description: 'Notifications for church updates and announcements',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  /// Initialize push notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _logger.debug('Initializing push notification service...');

      // Initialize Firebase (if not already done)
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      // Set up background message handler
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // Request permission
      await _requestPermission();

      // Initialize local notifications for foreground messages
      await _initializeLocalNotifications();

      // Set up foreground message handler
      _setupForegroundMessageHandler();

      // Set up message opened handler (when user taps notification)
      _setupMessageOpenedHandler();

      // Get and save FCM token
      await _getAndSaveToken();

      // Listen for token refresh
      _messaging.onTokenRefresh.listen(_onTokenRefresh);

      _isInitialized = true;
      _logger.debug('Push notification service initialized successfully');
    } catch (e, stack) {
      _logger.error('Failed to initialize push notifications: $e');
      _logger.error('Stack trace: $stack');
    }
  }

  /// Request notification permission
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

    _logger.debug(
        'Notification permission status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      _logger.warning('User denied notification permission');
    }
  }

  /// Initialize local notifications for foreground display
  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channel
    if (!kIsWeb && Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
    }
  }

  /// Handle foreground messages
  void _setupForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _logger.debug('Received foreground message: ${message.messageId}');
      _showLocalNotification(message);
    });
  }

  /// Handle notification tap when app is in background/terminated
  void _setupMessageOpenedHandler() {
    // Handle notification tap when app was terminated
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _handleNotificationTap(message.data);
      }
    });

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message.data);
    });
  }

  /// Show local notification for foreground messages
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'ezer_updates_channel',
      'Church Updates',
      channelDescription: 'Notifications for church updates and announcements',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data['route'],
    );
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      _handleNotificationTap({'route': payload});
    }
  }

  /// Navigate based on notification data
  void _handleNotificationTap(Map<String, dynamic> data) {
    final route = data['route'] as String?;
    final type = data['type'] as String?;
    final id = data['id'] as String?;

    _logger.debug('Notification tapped - route: $route, type: $type, id: $id');

    // Navigation will be handled by the app's router
    // This data can be passed to a navigation handler
  }

  /// Get and save FCM token
  Future<void> _getAndSaveToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        _currentToken = token;
        _logger.debug('FCM Token obtained: ${token.substring(0, 20)}...');
        await _saveTokenToDatabase(token);
      }
    } catch (e) {
      _logger.error('Failed to get FCM token: $e');
    }
  }

  /// Handle token refresh
  Future<void> _onTokenRefresh(String newToken) async {
    _logger.debug('FCM Token refreshed');

    // Delete old token if exists
    if (_currentToken != null && _currentToken != newToken) {
      await _deleteTokenFromDatabase(_currentToken!);
    }

    _currentToken = newToken;
    await _saveTokenToDatabase(newToken);
  }

  /// Save FCM token to Supabase
  Future<void> _saveTokenToDatabase(String token) async {
    final user = SupabaseService.currentUser;
    if (user == null) {
      _logger.debug('No user logged in, skipping token save');
      return;
    }

    try {
      final deviceType = _getDeviceType();
      final deviceName = await _getDeviceName();

      // Upsert token (insert or update if exists)
      await SupabaseService.client.from('device_tokens').upsert(
        {
          'user_id': user.id,
          'fcm_token': token,
          'device_type': deviceType,
          'device_name': deviceName,
          'is_active': true,
          'last_used_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'user_id,fcm_token',
      );

      _logger.debug('FCM token saved to database');
    } catch (e) {
      _logger.error('Failed to save FCM token: $e');
    }
  }

  /// Delete FCM token from Supabase
  Future<void> _deleteTokenFromDatabase(String token) async {
    final user = SupabaseService.currentUser;
    if (user == null) return;

    try {
      await SupabaseService.client
          .from('device_tokens')
          .delete()
          .eq('user_id', user.id)
          .eq('fcm_token', token);

      _logger.debug('Old FCM token deleted from database');
    } catch (e) {
      _logger.error('Failed to delete FCM token: $e');
    }
  }

  /// Get device type string
  String _getDeviceType() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'unknown';
  }

  /// Get device name
  Future<String> _getDeviceName() async {
    if (kIsWeb) return 'Web Browser';
    if (Platform.isAndroid) return 'Android Device';
    if (Platform.isIOS) return 'iOS Device';
    return 'Unknown Device';
  }

  /// Register token after user login
  Future<void> registerTokenAfterLogin() async {
    if (_currentToken != null) {
      await _saveTokenToDatabase(_currentToken!);
    } else {
      await _getAndSaveToken();
    }
  }

  /// Unregister token on logout
  Future<void> unregisterTokenOnLogout() async {
    if (_currentToken != null) {
      await _deleteTokenFromDatabase(_currentToken!);
    }
  }

  /// Deactivate all tokens for current user (e.g., when logging out from all devices)
  Future<void> deactivateAllTokens() async {
    final user = SupabaseService.currentUser;
    if (user == null) return;

    try {
      await SupabaseService.client
          .from('device_tokens')
          .update({'is_active': false}).eq('user_id', user.id);

      _logger.debug('All tokens deactivated for user');
    } catch (e) {
      _logger.error('Failed to deactivate tokens: $e');
    }
  }

  /// Get current FCM token
  String? get currentToken => _currentToken;

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Subscribe to a topic (for broadcasting to all users)
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      _logger.debug('Subscribed to topic: $topic');
    } catch (e) {
      _logger.error('Failed to subscribe to topic $topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      _logger.debug('Unsubscribed from topic: $topic');
    } catch (e) {
      _logger.error('Failed to unsubscribe from topic $topic: $e');
    }
  }
}
