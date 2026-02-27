import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
 
  Future<void> requestPermission()async{
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


}