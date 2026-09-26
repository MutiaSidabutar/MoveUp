import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

// Pengaturan tampilan yang berlaku untuk semua akun di perangkat ini
class SettingsService extends ChangeNotifier {
  SettingsService._();

  static final instance = SettingsService._();

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/settings.json');
  }

  Future<void> load() async {
    try {
      final file = await _file();
      if (!await file.exists()) return;
      final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      _themeMode = ThemeMode.values.asNameMap()[json['themeMode']] ?? ThemeMode.system;
      notifyListeners();
    } catch (e) {
      debugPrint('Gagal memuat pengaturan: $e');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final file = await _file();
    await file.writeAsString(jsonEncode({'themeMode': mode.name}));
  }
}
