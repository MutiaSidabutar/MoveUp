import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:moveup/firebase_options.dart';
import 'package:moveup/screens/auth_gate.dart';
import 'package:moveup/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      home: const AuthGate(),
    );
  }
}
