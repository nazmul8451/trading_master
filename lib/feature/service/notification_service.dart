import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:math';

class NotificationModel {
  final String title;
  final String body;
  final DateTime timestamp;

  NotificationModel({
    required this.title,
    required this.body,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'body': body,
    'timestamp': timestamp.toIso8601String(),
  };

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        title: json['title'] ?? '',
        body: json['body'] ?? '',
        timestamp: DateTime.parse(json['timestamp']),
      );
}

class NotificationService {
  static const String storageKey = 'notifications_history';
  static const String unreadCountKey = 'unread_notifications_count';
  final GetStorage _storage = GetStorage();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> initialize() async {
    await requestPermission();
    await getToken();

    // Foreground listener for FCM
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      saveNotification(message);
    });

    // Initialize Local Notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: DarwinInitializationSettings(),
        );

    await _localNotifications.initialize(initializationSettings);
    tz.initializeTimeZones();
  }

  Future<void> requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: true,
    );

    // Request permission for local notifications on Android 13+
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> getToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      print("FCM Token: $token");
    } catch (e) {
      print("Error getting token: $e");
    }
  }

  // --- Local Notifications / Smart Reminders ---

  final List<String> _motivationalQuotes = [
    "ট্রেডিং হলো একটি ম্যারাথন, স্প্রিন্ট নয়। আজকের গোল কি পূরণ হয়েছে? 🏁",
    "Discipline is doing what needs to be done, even if you don't want to. Check your goals! 🧘‍♂️",
    "আজকের টার্গেট মিস করবেন না। ডিসিপ্লিনই আপনাকে সফল করবে। ✨",
    "A successful trader is a disciplined trader. Have you updated your journal today? 📈",
    "ছোট ছোট লাভই বড় ক্যাপিটাল তৈরি করে। আজকের গোলটি কি সাকসেস? 🏦",
    "Fear and greed are your enemies. Stay calm and stick to your plan. 🛡️",
    "Don't trade with emotions, trade with a plan. Is your daily target hit? 🎯",
    "সফল ট্রেডার হতে হলে রুলস মেনে চলা জরুরি। আজকের ট্রেড কি শেষ? 📝",
  ];

  Future<void> scheduleDailyGoalReminder({
    required String planId,
    required int step,
    required DateTime date,
  }) async {
    final scheduledTime = DateTime(
      date.year,
      date.month,
      date.day,
      20,
      0,
    ); // 8:00 PM
    if (scheduledTime.isBefore(DateTime.now())) return;

    final quote =
        _motivationalQuotes[Random().nextInt(_motivationalQuotes.length)];

    // Generate a unique ID for this specific day/step in this plan
    // We use a simple hash of planId and step
    final notificationId = (planId.hashCode + step).abs() % 100000;

    await _localNotifications.zonedSchedule(
      notificationId,
      'Goal Reminder: Step $step',
      quote,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'goal_reminders',
          'Goal Reminders',
          channelDescription: 'Motivational reminders for daily trading goals',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: planId,
    );
  }

  Future<void> cancelGoalReminder(String planId, int step) async {
    final notificationId = (planId.hashCode + step).abs() % 100000;
    await _localNotifications.cancel(notificationId);
  }

  // --- FCM / Notification History Logic ---

  void saveNotification(RemoteMessage message) {
    if (message.notification != null) {
      final newNotification = NotificationModel(
        title: message.notification!.title ?? 'No Title',
        body: message.notification!.body ?? 'No Body',
        timestamp: DateTime.now(),
      );

      List<dynamic> history = _storage.read(storageKey) ?? [];
      history.insert(0, newNotification.toJson());
      _storage.write(storageKey, history);

      int currentCount = _storage.read(unreadCountKey) ?? 0;
      _storage.write(unreadCountKey, currentCount + 1);
    }
  }

  int getUnreadCount() => _storage.read(unreadCountKey) ?? 0;
  void resetUnreadCount() => _storage.write(unreadCountKey, 0);

  List<NotificationModel> getNotifications() {
    List<dynamic> data = _storage.read(storageKey) ?? [];
    return data.map((item) => NotificationModel.fromJson(item)).toList();
  }

  void clearNotifications() => _storage.write(storageKey, []);
}
