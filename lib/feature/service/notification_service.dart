import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_storage/get_storage.dart';

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
  final GetStorage _storage = GetStorage();

  Future<void> initialize() async {
    await requestPermission();
    await getToken();

    // Foreground listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      saveNotification(message);
    });
  }

  Future<void> requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: true,
    );
    print("Permission: ${settings.authorizationStatus}");
  }

  Future<void> getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print("FCM Token: $token");
  }

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
    }
  }

  List<NotificationModel> getNotifications() {
    List<dynamic> data = _storage.read(storageKey) ?? [];
    return data.map((item) => NotificationModel.fromJson(item)).toList();
  }

  void clearNotifications() {
    _storage.write(storageKey, []);
  }
}
