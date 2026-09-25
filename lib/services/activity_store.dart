import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:moveup/models/activity.dart';
import 'package:path_provider/path_provider.dart';

// Menyimpan aktivitas sebagai file JSON di penyimpanan aplikasi, terpisah per akun
class ActivityStore extends ChangeNotifier {
  ActivityStore._();

  static final instance = ActivityStore._();

  final List<Activity> _activities = [];
  String? _uid;

  // Terbaru di depan
  List<Activity> get activities => List.unmodifiable(_activities);

  Future<File> _file(String uid) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/activities_$uid.json');
  }

  Future<void> loadFor(String uid) async {
    if (_uid == uid) return;
    _uid = uid;
    _activities.clear();
    notifyListeners();
    try {
      final file = await _file(uid);
      await _migrateLegacyFile(file);
      if (!await file.exists()) return;
      final list = jsonDecode(await file.readAsString()) as List<dynamic>;
      // Pengguna bisa saja keluar selagi file dibaca
      if (_uid != uid) return;
      _activities
        ..clear()
        ..addAll(list.map((e) => Activity.fromJson(e as Map<String, dynamic>)));
      _sort();
      notifyListeners();
    } catch (e) {
      debugPrint('Gagal memuat aktivitas: $e');
    }
  }

  // Aktivitas yang direkam sebelum ada fitur akun diberikan ke akun pertama yang masuk
  Future<void> _migrateLegacyFile(File target) async {
    final legacy = File('${target.parent.path}/activities.json');
    if (!await target.exists() && await legacy.exists()) await legacy.rename(target.path);
  }

  void clear() {
    _uid = null;
    _activities.clear();
    notifyListeners();
  }

  Future<void> add(Activity activity) async {
    _activities.add(activity);
    _sort();
    notifyListeners();
    await _save();
  }

  Future<void> remove(String id) async {
    _activities.removeWhere((a) => a.id == id);
    notifyListeners();
    await _save();
  }

  List<Activity> between(DateTime from, DateTime to) =>
      _activities.where((a) => !a.startTime.isBefore(from) && a.startTime.isBefore(to)).toList();

  void _sort() => _activities.sort((a, b) => b.startTime.compareTo(a.startTime));

  Future<void> _save() async {
    final uid = _uid;
    if (uid == null) return;
    final file = await _file(uid);
    // Tulis ke file sementara dulu supaya data tidak rusak kalau aplikasi mati di tengah penulisan
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(jsonEncode(_activities.map((a) => a.toJson()).toList()));
    await tmp.rename(file.path);
  }
}
