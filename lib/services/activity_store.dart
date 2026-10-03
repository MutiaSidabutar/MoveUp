import 'dart:io';

import 'package:moveup/models/activity.dart';
import 'package:moveup/services/json_list_store.dart';
import 'package:moveup/services/sample_data.dart';

// Menyimpan aktivitas sebagai file JSON di penyimpanan aplikasi, terpisah per akun
class ActivityStore extends JsonListStore<Activity> {
  ActivityStore._() : super('activities');

  static final instance = ActivityStore._();

  // Terbaru di depan
  List<Activity> get activities => items;

  @override
  Comparator<Activity> get order => (a, b) => b.startTime.compareTo(a.startTime);

  @override
  String idOf(Activity item) => item.id;

  @override
  Map<String, dynamic> encode(Activity item) => item.toJson();

  @override
  Activity decode(Map<String, dynamic> json) => Activity.fromJson(json);

  @override
  List<Activity> seed() => SampleData.activities(DateTime.now());

  // Data simulasi lama dibuat sebelum ada rute contoh; lengkapi supaya petanya tampil
  @override
  List<Activity>? upgrade(List<Activity> loaded) {
    var changed = false;
    final result = <Activity>[];
    for (final a in loaded) {
      final route = a.points.isEmpty ? SampleData.routeFor(a.id, a.type, a.distanceMeters, a.movingSeconds) : const <TrackPoint>[];
      changed |= route.isNotEmpty;
      result.add(route.isEmpty ? a : a.copyWith(points: route));
    }
    return changed ? result : null;
  }

  // Aktivitas yang direkam sebelum ada fitur akun diberikan ke akun pertama yang masuk
  @override
  Future<void> beforeLoad(File file) async {
    final legacy = File('${file.parent.path}/activities.json');
    if (!await file.exists() && await legacy.exists()) await legacy.rename(file.path);
  }

  List<Activity> between(DateTime from, DateTime to) =>
      activities.where((a) => !a.startTime.isBefore(from) && a.startTime.isBefore(to)).toList();
}
