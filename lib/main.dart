import 'package:flutter/material.dart';
import 'register_page.dart';

void main() {
  runApp(const TradeXApp());
}

class TradeXApp extends StatelessWidget {
  const TradeXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: ' Apex Trades ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF00B4DB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0083B0),
          primary: const Color(0xFF0083B0),
          secondary: const Color(0xFF00FFFF),
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const RegisterPage(),
    );
  }
}

// Simple data model to pass user info
class UserData {
  final String fullName;
  final String email;
  final String country;

  UserData({required this.fullName, required this.email, required this.country});
}
//