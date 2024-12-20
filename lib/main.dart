import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import for FirebaseAuth
import 'package:mobile_lab_3/screens/create_event_screen.dart';
import 'package:mobile_lab_3/screens/create_gift_screen.dart';
import 'package:mobile_lab_3/screens/events_screen.dart';
import 'package:mobile_lab_3/screens/friend_profile_screen.dart';
import 'package:mobile_lab_3/screens/gift_details.dart';
import 'package:mobile_lab_3/screens/gifts_screen.dart';
import 'package:mobile_lab_3/screens/home_screen.dart';
import 'package:mobile_lab_3/screens/profile_screen.dart';
import 'package:mobile_lab_3/screens/signup_screen.dart';
import 'package:mobile_lab_3/services/notification_service.dart';
import 'Screens/login_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    print("Firebase initialized successfully");
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  // Check if the user is logged in
  final User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null){
    runApp(MyApp(initialRoute: '/home'));
    NotificationService notificationService = NotificationService();
    await notificationService.initialize(false);
    print("NotificationService initialized successfully");
  }
  else{
    runApp(MyApp(initialRoute: '/login'));
  }
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  MyApp({required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login/Sign-Up',
      initialRoute: initialRoute, // Set initial route based on login status
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/home': (context) => HomeScreen(),
        '/events': (context) => EventsScreen(),
        '/create_event': (context) => CreateEventScreen(),
        '/profile': (context) => ProfileScreen(),
        '/gifts': (context) => GiftsScreen(),
        '/friend': (context) => FriendProfileScreen(),
        '/gift_details': (context) => GiftDetailsScreen(),
        '/create_gift': (context) => CreateGiftScreen(),
      },
    );
  }
}
