import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/create_profile_screen.dart';
import 'screens/recording_screen.dart';
import 'screens/home_screen.dart'; // <--- IMPORT NUEVO

void main() { 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Content Gen App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF4461F2),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4461F2),
          primary: const Color(0xFF4461F2),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/create-profile': (context) => const CreateProfileScreen(),
        '/home': (context) => const HomeScreen(), // <--- NUEVA RUTA
        '/recording': (context) => const RecordingScreen(),
      },
    );
  }
}