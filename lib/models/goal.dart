import 'package:flutter/material.dart';
import 'package:moveup/models/activity.dart';
import 'package:moveup/utils/format.dart';

enum GoalMetric {
  distance('Jarak', 'km', Icons.straighten, 2000),
  duration('Durasi', 'menit', Icons.timer_outlined, 10000),
  sessions('Sesi', 'sesi', Icons.repeat, 60),
  calories('Kalori', 'kcal', Icons.local_fire_department_outlined, 100000);

  const GoalMetric(this.label, this.unit, this.icon, this.maxTarget);

  final String label;
  final String unit;
  final IconData icon;
  // Batas atas yang masih masuk akal untuk satu periode, dipakai validasi form
  final double maxTarget;

  double valueOf(Activity a) => switch (this) {
        GoalMetric.distance => a.km,
        GoalMetric.duration => a.movingSeconds / 60,
        GoalMetric.sessions => 1,
        GoalMetric.calories => a.calories.toDouble(),
      };

  // Jarak memakai satu desimal, satuan lain dibulatkan
  String format(double v) => this == GoalMetric.distance
      ? v.toStringAsFixed(1).replaceAll('.', ',')
      : v.round().toString();
}

enum GoalPeriod {
  weekly('Mingguan', 'minggu ini'),
  monthly('Bulanan', 'bulan ini');

  const GoalPeriod(this.label, this.currentLabel);

  final String label;
  final String currentLabel;

  (DateTime, DateTime) rangeAt(DateTime now) {
    if (this == GoalPeriod.weekly) {
      final from = startOfWeek(now);
      return (from, from.add(const Duration(days: 7)));
    }
    return (DateTime(now.year, now.month), DateTime(now.year, now.month + 1));
  }
}

class GoalProgress {
  const GoalProgress(this.goal, this.current, this.activities, this.from, this.to);

  final Goal goal;
  final double current;
  // Aktivitas pada periode berjalan yang dihitung ke target ini
  final List<Activity> activities;
  final DateTime from;
  final DateTime to;

  double get fraction => goal.target <= 0 ? 0 : (current / goal.target).clamp(0.0, 1.0);
  bool get completed => current >= goal.target;
  double get remaining => (goal.target - current).clamp(0, double.infinity);
}

// Target latihan per periode. sportTypeId merujuk ke kategori olahraga; null berarti semua olahraga.
class Goal {
  const Goal({
    required this.id,
    required this.title,
    required this.sportTypeId,
    required this.metric,
    required this.period,
    required this.target,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String? sportTypeId;
  final GoalMetric metric;
  final GoalPeriod period;
  final double target;
  final DateTime createdAt;

  SportType? get sportType => sportTypeId == null ? null : SportType.fromName(sportTypeId!);

  String get categoryLabel => sportType?.label ?? 'Semua olahraga';

  IconData get icon => sportType?.icon ?? metric.icon;

  String get targetLabel => '${metric.format(target)} ${metric.unit}';

  bool matches(Activity a) => sportTypeId == null || a.type.id == sportTypeId;

  GoalProgress progress(Iterable<Activity> all, {DateTime? now}) {
    final (from, to) = period.rangeAt(now ?? DateTime.now());
    final related = all
        .where((a) => matches(a) && !a.startTime.isBefore(from) && a.startTime.isBefore(to))
        .toList();
    final current = related.fold<double>(0, (sum, a) => sum + metric.valueOf(a));
    return GoalProgress(this, current, related, from, to);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'sportTypeId': sportTypeId,
        'metric': metric.name,
        'period': period.name,
        'target': target,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
        id: json['id'] as String,
        title: json['title'] as String,
        sportTypeId: json['sportTypeId'] as String?,
        metric: GoalMetric.values.byName(json['metric'] as String),
        period: GoalPeriod.values.byName(json['period'] as String),
        target: (json['target'] as num).toDouble(),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
