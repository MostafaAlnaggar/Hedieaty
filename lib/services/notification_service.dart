import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:mobile_lab_3/controllers/user_controller.dart';

Future<void> saveTokenToFirebase(String token) async {
  try {
    UserController userController = UserController();
    // Get the current user details
    final currentUser = await userController.getCurrentUser();

    if (currentUser == null) {
      print("No current user found.");
      return;
    }

    final userId = currentUser.uid;

    // Reference to the user's document
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

    // Update or set the FCM token
    await userDoc.set({
      'fcmToken': token,
    }, SetOptions(merge: true)); // Use merge to keep existing data
    print("FCM Token saved to Firebase.");
  } catch (e) {
    print("Error saving FCM Token: $e");
  }
}


class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize(bool initFirebase) async {
    // Request notification permissions for iOS
    await _firebaseMessaging.requestPermission();

    // Get the device token
    String? token = await _firebaseMessaging.getToken();
    print("FCM Token: $token");

    if (token != null && initFirebase) {
      // Save the token to Firebase
      await saveTokenToFirebase(token);
    }
    // Listen to messages while the app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Message received: ${message.notification?.title}");
    });

    // Handle messages when the app is opened from a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Message opened app: ${message.notification?.title}");
    });

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print("App opened from notification: ${message.notification?.title}");
        // Handle the notification data here
      }
    });

  }

  Future<void> sendPushNotification({
    required String recipientToken,
    required String title,
    required String body,
  }) async {
    const String projectId = 'hediaty-94232';

    const String serviceAccountKeyPath =
        'assets/hediaty-94232-firebase-adminsdk-aicza-37f3e9828b.json';
    try {
      final accountCredentials = json.decode(await rootBundle.loadString(serviceAccountKeyPath));

      final serviceAccountCredentials =
      ServiceAccountCredentials.fromJson(accountCredentials);
      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
      final client =
      await clientViaServiceAccount(serviceAccountCredentials, scopes);

      final url = Uri.parse(
          'https://fcm.googleapis.com/v1/projects/$projectId/messages:send');

      final payload = {
        "message": {
          "token": recipientToken,
          "notification": {
            "title": title,
            "body": body,
          },
          "data": {
            "click_action": "FLUTTER_NOTIFICATION_CLICK",
          },
        },
      };

      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully: ${response.body}');
      } else {
        print('Failed to send notification: ${response.statusCode} ${response.body}');
      }

    } catch (e) {
      print('Error sending notification: $e');
    }
  }
}
