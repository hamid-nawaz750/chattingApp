import 'package:chatting_app/View/Authentication_Screens/SignIn_Screen.dart';
import 'package:chatting_app/View/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart'; // ✅ Correct import
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Initialize OneSignal (Corrected)
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose); // Enable debugging logs
  OneSignal.initialize("d885040c-3b0d-4787-9d2e-c53fcd6b79fd"); // Set App ID

  // ✅ Request notification permission (Corrected)
  await OneSignal.Notifications.requestPermission(true); // Ask for permission

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SigninScreen(),
    );
  }
}
