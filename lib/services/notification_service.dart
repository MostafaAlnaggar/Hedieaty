import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:mobile_lab_3/controllers/user_controller.dart';

import '../main.dart';

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

    // // Listen to messages while the app is in foreground
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   print("Message received: ${message.notification?.title}");
    // });

    // Handle messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        // Use navigatorKey to show the dialog
        showToastNotification(
          title: message.notification!.title ?? 'No title',
          body: message.notification!.body ?? 'No body',
        );
      }

      // final context = navigatorKey.currentContext;
      // if (context != null) {
      //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("This is a snack bar")));
      // }
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
void showToastNotification({required String title, required String body}) {
  final navigatorState = navigatorKey.currentState;

  if (navigatorState != null) {
    final overlay = navigatorState.overlay;

    if (overlay != null) {
      final overlayEntry = OverlayEntry(
        builder: (context) {
          return Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: Container(
                color: Color(0xFFDB2367).withOpacity(0.9),
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 5),
                    Text(
                      body,
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );

      // Insert the overlay entry to display the notification
      overlay.insert(overlayEntry);

      // Remove the overlay entry after 3 seconds
      Future.delayed(Duration(seconds: 3), () {
        overlayEntry.remove();
      });
    }
  } else {
    print('Navigator state is null. Cannot show custom notification.');
  }
}