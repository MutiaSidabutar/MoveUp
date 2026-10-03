import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:moveup/firebase_options.dart';
import 'package:moveup/screens/auth_gate.dart';
import 'package:moveup/services/settings_service.dart';
import 'package:moveup/theme.dart';
import 'package:moveup/services/photo_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SettingsService.instance.load();
  await PhotoStore.init();
  runApp(const MoveUpApp());
}

class MoveUpApp extends StatelessWidget {
  const MoveUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SettingsService.instance,
      builder: (context, _) => MaterialApp(
        title: 'MoveUp',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: SettingsService.instance.themeMode,
        home: const AuthGate(),
      ),
    );
  }
}
