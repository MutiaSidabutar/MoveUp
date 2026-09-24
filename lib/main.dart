
import 'package:flutter/material.dart';
import 'package:moveup/theme.dart';
import 'package:moveup/screens/splash_screen.dart';

void main() {
  runApp(const MoveUpApp());
}

class MoveUpApp extends StatelessWidget {
  const MoveUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoveUp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
