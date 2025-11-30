// Archivo: main.dart

import 'package:content_generator_app/screens/ProjectsScreen.dart';
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/create_profile_screen.dart';
import 'screens/home_screen.dart';
import 'screens/signup_screen.dart';
// NOTA: No necesitamos importar recording_screen.dart aquí.

void main() {
  WidgetsFlutterBinding.ensureInitialized(); 
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
        '/signup': (context) => const SignUpScreen(),
        '/create-profile': (context) => const CreateProfileScreen(),
        '/home': (context) => const HomeScreen(),
        // 🔴 LÍNEA ELIMINADA: /recording ya no puede estar aquí
        '/Proyectos': (context) => const ProjectsScreen(),
      },
    );
  }
}