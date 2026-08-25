import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyAzN4vJZlYmGVzm8sCsz1bEPawQEiKIc6k',
      appId: '1:311998863107:android:2853688e5735168c2cfb36',
      messagingSenderId: '311998863107',
      projectId: 'trivianinja-bff5c',
      storageBucket: 'trivianinja-bff5c.firebasestorage.app',
    ),
  );
  runApp(const TriviaGameApp());
}

class TriviaGameApp extends StatelessWidget {
  const TriviaGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game 7',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}