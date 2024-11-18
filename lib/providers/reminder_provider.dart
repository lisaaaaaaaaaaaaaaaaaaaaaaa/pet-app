import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../utils/logger.dart';
import 'dart:async';

class ReminderProvider with ChangeNotifier {
//   final FirebaseFirestore _firestore;
  final FirebaseAnalytics _analytics;
  final FlutterLocalNotificationsPlugin _notifications;
  final Logger _logger;

  Map<String, List<PetReminder>> _reminders = {};
  Map<String, DateTime> _lastUpdated = {};
  bool _isLoading = false;
  String? _error;
  Timer? _refreshTimer;
  Timer? _checkTimer;
  final Duration _refreshInterval = const Duration(minutes: 15);
  final Duration _checkInterval = const Duration(minutes: 1);

  ReminderProvider({
//     FirebaseFirestore? firestore,
    FirebaseAnalytics? analytics,
    FlutterLocalNotificationsPlugin? notifications,
    Logger? logger,
  }) : 
//     _firestore = firestore ?? FirebaseFirestore.instance,
    _analytics = analytics ?? FirebaseAnalytics.instance,
    _notifications = notifications ?? FlutterLocalNotificationsPlugin(),
    _logger = logger ?? Logger() {
    _initialize();
  }

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, List<PetReminder>> get reminders => _reminders;

  Future<void> _initialize() async {
    try {
      await _initializeNotifications();
      _initializeListeners();
      _setupTimers();
    } catch (e, stackTrace) {
      _error = _handleError('Failed to initialize reminders', e, stackTrace);
    }
  }

  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    await _notifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );
  }

  void _initializeListeners() {
    _firestore.collection('reminders')
        .snapshots()
        .listen(_handleReminderUpdates);
  }

  void _setupTimers() {
    _refreshTimer?.cancel();
    _checkTimer?.cancel();

    _refreshTimer = Timer.periodic(_refreshInterval, (_) => _refreshAllReminders());
    _checkTimer = Timer.periodic(_checkInterval, (_) => _checkUpcomingReminders());
  }

  Future<void> _handleReminderUpdates(QuerySnapshot snapshot) async {
    for (var change in snapshot.docChanges) {
      final data = change.doc.data() as Map<String, dynamic>;
      final petId = data['petId'] as String;

      switch (change.type) {
        case DocumentChangeType.added:
        case DocumentChangeType.modified:
          await loadReminders(petId, silent: true);
          break;
        case DocumentChangeType.removed:
          _removeReminder(petId, change.doc.id);
          break;
      }
    }
    notifyListeners();
  }

  void _handleNotificationTap(NotificationResponse response) {
    // Handle notification tap
    _logger.info('Notification tapped: ${response.payload}');
  }

  Future<List<PetReminder>> getReminders(
    String petId, {
    bool forceRefresh = false,
    String? type,
    bool? isCompleted,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (forceRefresh || _needsRefresh(petId)) {
      await loadReminders(petId);
    }

    var reminders = _reminders[petId] ?? [];

    // Apply filters
    if (type != null) {
      reminders = reminders.where((r) => r.type == type).toList();
    }
    if (isCompleted != null) {
      reminders = reminders.where((r) => r.isCompleted == isCompleted).toList();
    }
    if (startDate != null) {
      reminders = reminders.where((r) => r.dueDate.isAfter(startDate)).toList();
    }
    if (endDate != null) {
      reminders = reminders.where((r) => r.dueDate.isBefore(endDate)).toList();
    }

    return reminders;
  }

  Future<void> addReminder({
    required String petId,
    required String title,
    required String type,
    required DateTime dueDate,
    String? description,
    Duration? notifyBefore,
    bool repeat = false,
    Duration? repeatInterval,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final reminder = PetReminder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        petId: petId,
        title: title,
        type: type,
        description: description,
        dueDate: dueDate,
        notifyBefore: notifyBefore ?? const Duration(minutes: 30),
        repeat: repeat,
        repeatInterval: repeatInterval,
        metadata: metadata ?? {},
        isCompleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('reminders').add(reminder.toJson());

      final reminders = _reminders[petId] ?? [];
      reminders.add(reminder);
      _reminders[petId] = reminders;

      await _scheduleNotification(reminder);
      _error = null;

      await _analytics.logEvent(
        name: 'reminder_added',
        parameters: {
          'pet_id': petId,
          'type': type,
        },
      );

    } catch (e, stackTrace) {
      _error = _handleError('Failed to add reminder', e, stackTrace);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateReminder({
    required String reminderId,
    required String petId,
    String? title,
    String? description,
    DateTime? dueDate,
    Duration? notifyBefore,
    bool? repeat,
    Duration? repeatInterval,
    bool? isCompleted,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final updates = <String, dynamic>{
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
        if (notifyBefore != null) 'notifyBefore': notifyBefore.inMinutes,
        if (repeat != null) 'repeat': repeat,
        if (repeatInterval != null) 'repeatInterval': repeatInterval.inMinutes,
        if (isCompleted != null) 'isCompleted': isCompleted,
        if (metadata != null) 'metadata': metadata,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('reminders')
          .doc(reminderId)
          .update(updates);

      final reminders = _reminders[petId] ?? [];
      final index = reminders.indexWhere((r) => r.id == reminderId);
      
      if (index != -1) {
        reminders[index] = reminders[index].copyWith(
          title: title,
          description: description,
          dueDate: dueDate,
          notifyBefore: notifyBefore,
          repeat: repeat,
          repeatInterval: repeatInterval,
          isCompleted: isCompleted,
          metadata: metadata,
          updatedAt: DateTime.now(),
        );
        _reminders[petId] = reminders;

        await _rescheduleNotification(reminders[index]);
      }

      _error = null;

    } catch (e, stackTrace) {
      _error = _handleError('Failed to update reminder', e, stackTrace);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteReminder(String petId, String reminderId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore
          .collection('reminders')
          .doc(reminderId)
          .delete();

      await _cancelNotification(reminderId);
      _removeReminder(petId, reminderId);
      _error = null;

    } catch (e, stackTrace) {
      _error = _handleError('Failed to delete reminder', e, stackTrace);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> completeReminder(String petId, String reminderId) async {
    try {
      await updateReminder(
        reminderId: reminderId,
        petId: petId,
        isCompleted: true,
      );

      if (_shouldCreateNextReminder(reminderId)) {
        await _createNextReminder(reminderId);
      }

    } catch (e, stackTrace) {
      _error = _handleError('Failed to complete reminder', e, stackTrace);
      rethrow;
    }
  }

  Future<void> loadReminders(String petId, {bool silent = false}) async {
    try {
      if (!silent) {
        _isLoading = true;
        notifyListeners();
      }

      final snapshot = await _firestore
          .collection('reminders')
          .where('petId', isEqualTo: petId)
          .get();

      _reminders[petId] = snapshot.docs
          .map((doc) => PetReminder.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
      _lastUpdated[petId] = DateTime.now();

      if (!silent) _error = null;

    } catch (e, stackTrace) {
      _error = _handleError('Failed to load reminders', e, stackTrace);
      if (!silent) rethrow;
    } finally {
      if (!silent) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> _scheduleNotification(PetReminder reminder) async {
    try {
      final notificationTime = reminder.dueDate.subtract(reminder.notifyBefore);
      if (notificationTime.isBefore(DateTime.now())) return;

      await _notifications.zonedSchedule(
        reminder.id.hashCode,
        'Pet Care Reminder',
        reminder.title,
        TZDateTime.from(notificationTime, local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'pet_reminders',
            'Pet Reminders',
            channelDescription: 'Notifications for pet care reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: reminder.id,
      );

    } catch (e, stackTrace) {
      _logger.error('Failed to schedule notification', e, stackTrace);
    }
  }

  Future<void> _rescheduleNotification(PetReminder reminder) async {
    await _cancelNotification(reminder.id);
    if (!reminder.isCompleted) {
      await _scheduleNotification(reminder);
    }
  }

  Future<void> _cancelNotification(String reminderId) async {
    await _notifications.cancel(reminderId.hashCode);
  }

  void _removeReminder(String petId, String reminderId) {
    final reminders = _reminders[petId] ?? [];
    reminders.removeWhere((r) => r.id == reminderId);
    _reminders[petId] = reminders;
    notifyListeners();
  }

  Future<void> _refreshAllReminders({bool silent = true}) async {
    for (var petId in _reminders.keys) {
      if (_needsRefresh(petId)) {
        await loadReminders(petId, silent: silent);
      }
    }
  }

  Future<void> _checkUpcomingReminders() async {
    final now = DateTime.now();
    for (var reminders in _reminders.values) {
      for (var reminder in reminders) {
        if (!reminder.isCompleted &&
            reminder.dueDate.difference(now) <= reminder.notifyBefore) {
          await _scheduleNotification(reminder);
        }
      }
    }
  }

  bool _shouldCreateNextReminder(String reminderId) {
    final reminder = _findReminderById(reminderId);
    return reminder?.repeat == true && reminder?.repeatInterval != null;
  }

  Future<void> _createNextReminder(String reminderId) async {
    final reminder = _findReminderById(reminderId);
    if (reminder == null) return;

    final nextDueDate = reminder.dueDate.add(reminder.repeatInterval!);
    await addReminder(
      petId: reminder.petId,
      title: reminder.title,
      type: reminder.type,
      description: reminder.description,
      dueDate: nextDueDate,
      notifyBefore: reminder.notifyBefore,
      repeat: reminder.repeat,
      repeatInterval: reminder.repeatInterval,
      metadata: reminder.metadata,
    );
  }

  PetReminder? _findReminderById(String reminderId) {
    for (var reminders in _reminders.values) {
      final reminder = reminders.firstWhere(
        (r) => r.id == reminderId,
        orElse: () => null as PetReminder,
      );
      if (reminder != null) return reminder;
    }
    return null;
  }

  bool _needsRefresh(String petId) {
    final lastUpdate = _lastUpdated[petId];
    if (lastUpdate == null) return true;
    return DateTime.now().difference(lastUpdate) > _refreshInterval;
  }

  String _handleError(String operation, dynamic error, StackTrace stackTrace) {
    _logger.error(operation, error, stackTrace);
    return 'Failed to $operation: ${error.toString()}';
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _checkTimer?.cancel();
    super.dispose();
  }
}

class PetReminder {
  final String id;
  final String petId;
  final String title;
  final String type;
  final String? description;
  final DateTime dueDate;
  final Duration notifyBefore;
  final bool repeat;
  final Duration? repeatInterval;
  final bool isCompleted;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  PetReminder({
    required this.id,
    required this.petId,
    required this.title,
    required this.type,
    this.description,
    required this.dueDate,
    required this.notifyBefore,
    required this.repeat,
    this.repeatInterval,
    required this.isCompleted,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  PetReminder copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    Duration? notifyBefore,
    bool? repeat,
    Duration? repeatInterval,
    bool? isCompleted,
    Map<String, dynamic>? metadata,
    DateTime? updatedAt,
  }) {
    return PetReminder(
      id: id,
      petId: petId,
      title: title ?? this.title,
      type: type,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      notifyBefore: notifyBefore ?? this.notifyBefore,
      repeat: repeat ?? this.repeat,
      repeatInterval: repeatInterval ?? this.repeatInterval,
      isCompleted: isCompleted ?? this.isCompleted,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'petId': petId,
    'title': title,
    'type': type,
    'description': description,
    'dueDate': dueDate.toIso8601String(),
    'notifyBefore': notifyBefore.inMinutes,
    'repeat': repeat,
    'repeatInterval': repeatInterval?.inMinutes,
    'isCompleted': isCompleted,
    'metadata': metadata,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory PetReminder.fromJson(Map<String, dynamic> json) => PetReminder(
    id: json['id'],
    petId: json['petId'],
    title: json['title'],
    type: json['type'],
    description: json['description'],
    dueDate: DateTime.parse(json['dueDate']),
    notifyBefore: Duration(minutes: json['notifyBefore']),
    repeat: json['repeat'],
    repeatInterval: json['repeatInterval'] != null
        ? Duration(minutes: json['repeatInterval'])
        : null,
    isCompleted: json['isCompleted'],
    metadata: json['metadata'] ?? {},
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );
}
