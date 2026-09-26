import 'package:flutter/material.dart';
import 'package:moveup/models/activity.dart';

const dayNames = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
const dayShortNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

// Jadwal latihan berulang. sportTypeId merujuk ke kategori olahraga, goalId (opsional) ke target.
class Reminder {
  const Reminder({
    required this.id,
    required this.title,
    required this.sportTypeId,
    required this.days,
    required this.hour,
    required this.minute,
    this.enabled = true,
    this.goalId,
  });

  final String id;
  final String title;
  final String sportTypeId;
  // Hari dalam seminggu seperti DateTime.weekday: 1 = Senin … 7 = Minggu
  final List<int> days;
  final int hour;
  final int minute;
  final bool enabled;
  final String? goalId;

  SportType get sportType => SportType.fromName(sportTypeId);

  TimeOfDay get time => TimeOfDay(hour: hour, minute: minute);

  String get timeLabel => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  String get daysLabel {
    final sorted = [...days]..sort();
    if (sorted.length == 7) return 'Setiap hari';
    if (sorted.join() == '12345') return 'Senin–Jumat';
    if (sorted.join() == '67') return 'Akhir pekan';
    return sorted.map((d) => dayShortNames[d - 1]).join(', ');
  }

  // Jadwal berikutnya setelah [now], null kalau pengingat nonaktif
  DateTime? nextAfter(DateTime now) {
    if (!enabled || days.isEmpty) return null;
    for (var i = 0; i < 8; i++) {
      final day = DateTime(now.year, now.month, now.day + i, hour, minute);
      if (days.contains(day.weekday) && day.isAfter(now)) return day;
    }
    return null;
  }

  Reminder copyWith({bool? enabled, String? Function()? goalId}) => Reminder(
        id: id,
        title: title,
        sportTypeId: sportTypeId,
        days: days,
        hour: hour,
        minute: minute,
        enabled: enabled ?? this.enabled,
        goalId: goalId == null ? this.goalId : goalId(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'sportTypeId': sportTypeId,
        'days': days,
        'hour': hour,
        'minute': minute,
        'enabled': enabled,
        'goalId': goalId,
      };

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
        id: json['id'] as String,
        title: json['title'] as String,
        sportTypeId: json['sportTypeId'] as String,
        days: ((json['days'] as List?) ?? []).map((d) => (d as num).toInt()).toList(),
        hour: (json['hour'] as num).toInt(),
        minute: (json['minute'] as num).toInt(),
        enabled: (json['enabled'] as bool?) ?? true,
        goalId: json['goalId'] as String?,
      );
}
