import 'package:flutter/material.dart';
import 'package:moveup/theme.dart';
import 'package:moveup/models/activity.dart';
import 'package:moveup/screens/activity_detail_screen.dart';
import 'package:moveup/screens/add_activity_screen.dart';
import 'package:moveup/services/activity_store.dart';
import 'package:moveup/utils/format.dart';
import 'package:moveup/widgets.dart';
import 'package:moveup/widgets/activity_feed_card.dart';

// Beranda: ringkasan minggu ini dan feed aktivitas
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = ActivityStore.instance;

    return SafeArea(
      child: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final activities = store.activities;
          final now = DateTime.now();
          final weekStart = startOfWeek(now);
          final week = store.between(weekStart, weekStart.add(const Duration(days: 7)));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Text("BERANDA", style: AppTheme.display(30, letterSpacing: 1.5)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit_note),
                    tooltip: "Tambah aktivitas manual",
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddActivityScreen())),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _WeekSummaryCard(week: week, todayIndex: now.weekday - 1),
              const SizedBox(height: 16),
              if (activities.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: EmptyStateWidget(
                    message: "Belum ada aktivitas.\nTekan Rekam untuk mulai bergerak!",
                    icon: Icons.directions_run,
                  ),
                )
              else
                for (final activity in activities)
                  ActivityFeedCard(
                    activity: activity,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ActivityDetailScreen(activity: activity)),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _WeekSummaryCard extends StatelessWidget {
  const _WeekSummaryCard({required this.week, required this.todayIndex});

  final List<Activity> week;
  final int todayIndex;

  @override
  Widget build(BuildContext context) {
    final perDay = List<double>.filled(7, 0);
    var meters = 0.0;
    var seconds = 0;
    for (final a in week) {
      perDay[a.startTime.weekday - 1] += a.km;
      meters += a.distanceMeters;
      seconds += a.movingSeconds;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Minggu Ini", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                _summaryStat("Aktivitas", "${week.length}"),
                _summaryStat("Jarak", "${formatKm(meters)} km"),
                _summaryStat("Waktu", formatDurationShort(seconds)),
              ],
            ),
            const SizedBox(height: 16),
            SimpleBarChart(values: perDay, labels: dayInitials, highlightIndex: todayIndex, height: 60),
          ],
        ),
      ),
    );
  }

  Widget _summaryStat(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(value, style: AppTheme.display(22)),
        ],
      ),
    );
  }
}
