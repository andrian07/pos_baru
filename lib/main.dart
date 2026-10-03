import 'package:flutter/material.dart';

import 'screens/login_screen.dart';

void main() {
  runApp(const UltimaPosApp());
}

class UltimaPosApp extends StatelessWidget {
  const UltimaPosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ultima POS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0066FF)),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
