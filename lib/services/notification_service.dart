import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final uuid = const Uuid();

  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Initialize notification services
  Future<void> initialize() async {
    try {
      // Initialize timezone
      tz.initializeTimeZones();

      // Request notification permissions
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      // Initialize local notifications
      const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      // Configure Firebase Messaging handlers
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Get FCM token
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _updateFCMToken(token);
      }

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen(_updateFCMToken);
    } catch (e) {
      throw NotificationException('Error initializing notification service: $e');
    }
  }

  // Handle notification tap
  void _onNotificationTap(NotificationResponse response) async {
    if (response.payload != null) {
      // Handle notification tap based on payload
      final Map<String, dynamic> payload = _parsePayload(response.payload!);
      await _handleNotificationTap(payload);
    }
  }

  // Schedule a local notification
  Future<String> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    String? userId,
    String? petId,
    String? type,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final String notificationId = uuid.v4();
      
      await _localNotifications.zonedSchedule(
        notificationId.hashCode,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'pet_reminders',
            'Pet Reminders',
            channelDescription: 'Notifications for pet care reminders',
            importance: Importance.high,
            priority: Priority.high,
            sound: RawResourceAndroidNotificationSound('notification_sound'),
            enableVibration: true,
          ),
          iOS: const DarwinNotificationDetails(
            sound: 'notification_sound.aiff',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: _createPayload(
          notificationId: notificationId,
          type: type,
          userId: userId,
          petId: petId,
          additionalData: additionalData,
        ),
      );

      // Store notification in Firestore
      await _storeNotification(
        notificationId: notificationId,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        userId: userId,
        petId: petId,
        type: type,
        additionalData: additionalData,
      );

      return notificationId;
    } catch (e) {
      throw NotificationException('Error scheduling notification: $e');
    }
  }

  // Send push notification to specific users
  Future<void> sendPushNotification({
    required List<String> userIds,
    required String title,
    required String body,
    String? type,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Get FCM tokens for users
      final tokensSnapshot = await _firestore
          .collection('users')
          .where('id', whereIn: userIds)
          .get();

      final List<String> tokens = tokensSnapshot.docs
          .map((doc) => doc.data()['fcmToken'] as String)
          .where((token) => token.isNotEmpty)
          .toList();

      if (tokens.isEmpty) return;

      // Prepare notification message
      final message = {
        'notification': {
          'title': title,
          'body': body,
        },
        'data': {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'type': type ?? 'general',
          ...?data,
        },
        'registration_ids': tokens,
      };

      // Send to Firebase Cloud Messaging
      await _sendFCMMessage(message);
    } catch (e) {
      throw NotificationException('Error sending push notification: $e');
    }
  }

  // Cancel scheduled notification
  Future<void> cancelNotification(String notificationId) async {
    try {
      await _localNotifications.cancel(notificationId.hashCode);
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'cancelled': true});
    } catch (e) {
      throw NotificationException('Error cancelling notification: $e');
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _localNotifications.cancelAll();
    } catch (e) {
      throw NotificationException('Error cancelling all notifications: $e');
    }
  }

  // Get all scheduled notifications for a user
  Future<List<Map<String, dynamic>>> getScheduledNotifications({
    required String userId,
    String? petId,
    String? type,
  }) async {
    try {
      Query query = _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('cancelled', isEqualTo: false)
          .where('scheduledDate', isGreaterThan: Timestamp.now());

      if (petId != null) {
        query = query.where('petId', isEqualTo: petId);
      }
      if (type != null) {
        query = query.where('type', isEqualTo: type);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw NotificationException('Error getting scheduled notifications: $e');
    }
  }

  // Store FCM token in Firestore
  Future<void> _updateFCMToken(String token) async {
    try {
      // Get current user ID from your auth service
      final String? userId = await _getCurrentUserId();
      if (userId == null) return;

      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw NotificationException('Error updating FCM token: $e');
    }
  }

  // Store notification in Firestore
  Future<void> _storeNotification({
    required String notificationId,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? userId,
    String? petId,
    String? type,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).set({
        'id': notificationId,
        'title': title,
        'body': body,
        'scheduledDate': Timestamp.fromDate(scheduledDate),
        'userId': userId,
        'petId': petId,
        'type': type,
        'additionalData': additionalData,
        'cancelled': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw NotificationException('Error storing notification: $e');
    }
  }

  // Create notification payload
  String _createPayload({
    required String notificationId,
    String? type,
    String? userId,
    String? petId,
    Map<String, dynamic>? additionalData,
  }) {
    final payload = {
      'notificationId': notificationId,
      'type': type,
      'userId': userId,
      'petId': petId,
      ...?additionalData,
    };
    return Uri(queryParameters: payload.map(
      (key, value) => MapEntry(key, value?.toString()),
    )).query;
  }

  // Parse notification payload
  Map<String, dynamic> _parsePayload(String payload) {
    final uri = Uri(query: payload);
    return uri.queryParameters;
  }

  // Handle notification tap
  Future<void> _handleNotificationTap(Map<String, dynamic> payload) async {
    // Implement navigation logic based on payload
    // Example:
    // if (payload['type'] == 'medication') {
    //   navigateToMedicationDetails(payload['medicationId']);
    // }
  }

  // Handle foreground message
  void _handleForegroundMessage(RemoteMessage message) {
    // Show local notification for foreground message
    _showLocalNotification(
      title: message.notification?.title ?? 'New Notification',
      body: message.notification?.body ?? '',
      payload: _createPayload(
        notificationId: uuid.v4(),
        type: message.data['type'],
        additionalData: message.data,
      ),
    );
  }

  // Handle background message tap
  void _handleBackgroundMessage(RemoteMessage message) {
    // Handle background message tap
    if (message.data.isNotEmpty) {
      _handleNotificationTap(message.data);
    }
  }

  // Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'pet_reminders',
      'Pet Reminders',
      channelDescription: 'Notifications for pet care reminders',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
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
      0,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // Send FCM message
  Future<void> _sendFCMMessage(Map<String, dynamic> message) async {
    const String fcmUrl = 'https://fcm.googleapis.com/fcm/send';
    final String? serverKey = await _getFCMServerKey();
    
    if (serverKey == null) {
      throw NotificationException('FCM server key not found');
    }

    try {
      // Implement HTTP POST request to FCM
      // Note: You should use your server to send FCM messages
      // This is just a placeholder for the implementation
    } catch (e) {
      throw NotificationException('Error sending FCM message: $e');
    }
  }

  // Get current user ID (implement based on your auth service)
  Future<String?> _getCurrentUserId() async {
    // Implement getting current user ID
    return null;
  }

  // Get FCM server key (implement based on your configuration)
  Future<String?> _getFCMServerKey() async {
    // Implement getting FCM server key
    return null;
  }
}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background message
  // Note: This needs to be a top-level function
}

class NotificationException implements Exception {
  final String message;
  NotificationException(this.message);

  @override
  String toString() => message;
}