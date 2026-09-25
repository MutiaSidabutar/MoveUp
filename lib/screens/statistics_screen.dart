import 'package:flutter/material.dart';
import 'package:moveup/theme.dart';
import 'package:moveup/models/activity.dart';
import 'package:moveup/services/activity_store.dart';
import 'package:moveup/utils/format.dart';
import 'package:moveup/widgets.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _monthly = false;
  // null berarti semua jenis olahraga
  SportType? _sport;

  bool _matches(Activity a) => _sport == null || a.type == _sport;

  @override
  Widget build(BuildContext context) {
    final store = ActivityStore.instance;

    return SafeArea(
      child: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final now = DateTime.now();
          final DateTime from;
          final DateTime to;
          final List<String> labels;
          final int todayIndex;
          if (_monthly) {
            from = DateTime(now.year, now.month);
            to = DateTime(now.year, now.month + 1);
            final days = to.difference(from).inDays;
            labels = [for (var d = 1; d <= days; d++) d == 1 || d % 5 == 0 ? "$d" : ""];
            todayIndex = now.day - 1;
          } else {
            from = startOfWeek(now);
            to = from.add(const Duration(days: 7));
            labels = dayInitials;
            todayIndex = now.weekday - 1;
          }

          final period = store.between(from, to).where(_matches).toList();
          final distance = List<double>.filled(labels.length, 0);
          final calories = List<double>.filled(labels.length, 0);
          var meters = 0.0;
          var seconds = 0;
          for (final a in period) {
            final i = _monthly ? a.startTime.day - 1 : a.startTime.weekday - 1;
            distance[i] += a.km;
            calories[i] += a.calories;
            meters += a.distanceMeters;
            seconds += a.movingSeconds;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("STATISTIK", style: AppTheme.display(30, letterSpacing: 1.5)),
                const SizedBox(height: 20),
                _buildToggle(context),
                const SizedBox(height: 12),
                _buildSportFilter(),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem("Total Sesi", "${period.length}"),
                    _buildStatItem("Durasi", formatDurationShort(seconds)),
                    _buildStatItem("Jarak", "${formatKm(meters, decimals: 1)} km"),
                  ],
                ),
                const SizedBox(height: 32),
                Text("Jarak (km)", style: AppTheme.display(22)),
                const SizedBox(height: 16),
                SimpleBarChart(values: distance, labels: labels, highlightIndex: todayIndex),
                const SizedBox(height: 32),
                Text("Kalori Terbakar", style: AppTheme.display(22)),
                const SizedBox(height: 16),
                SimpleBarChart(values: calories, labels: labels, highlightIndex: todayIndex),
                const SizedBox(height: 32),
                Text("Rekor Pribadi", style: AppTheme.display(22)),
                const SizedBox(height: 12),
                ..._buildRecords(store.activities.where(_matches).toList()),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildToggle(BuildContext context) {
    Widget option(String label, bool monthly) {
      final selected = _monthly == monthly;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _monthly = monthly),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected ? Theme.of(context).primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(color: selected ? Theme.of(context).colorScheme.onPrimary : null, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [option("Mingguan", false), option("Bulanan", true)]),
    );
  }

  Widget _buildSportFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChoiceChip(
            label: const Text("Semua"),
            selected: _sport == null,
            onSelected: (_) => setState(() => _sport = null),
          ),
          for (final type in SportType.values) ...[
            const SizedBox(width: 8),
            ChoiceChip(
              avatar: Icon(type.icon, size: 18),
              label: Text(type.label),
              selected: _sport == type,
              onSelected: (_) => setState(() => _sport = type),
            ),
          ],
        ],
      ),
    );
  }

  // Rekor dihitung terpisah per olahraga supaya bersepeda tidak mengalahkan lari
  List<Widget> _buildRecords(List<Activity> activities) {
    final cards = [
      for (final type in SportType.values)
        if (activities.any((a) => a.type == type))
          _buildSportRecords(type, activities.where((a) => a.type == type).toList()),
    ];
    if (cards.isEmpty) {
      return const [Text("Rekor muncul setelah Anda menyimpan aktivitas.", style: TextStyle(color: Colors.grey))];
    }
    return cards;
  }

  Widget _buildSportRecords(SportType type, List<Activity> list) {
    final longest = list.reduce((a, b) => a.distanceMeters >= b.distanceMeters ? a : b);
    final longestTime = list.reduce((a, b) => a.movingSeconds >= b.movingSeconds ? a : b);
    // Minimal 1 km supaya rekaman sangat pendek tidak jadi rekor kecepatan
    final eligible = list.where((a) => a.km >= 1).toList();
    final fastest = eligible.isEmpty ? null : eligible.reduce((a, b) => a.speedKmh >= b.speedKmh ? a : b);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Icon(type.icon, size: 20),
                const SizedBox(width: 8),
                Text(type.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          _recordTile(Icons.straighten, "Jarak terjauh", "${formatKm(longest.distanceMeters)} km", longest),
          _recordTile(Icons.timer_outlined, "Durasi terlama", formatDuration(longestTime.movingSeconds), longestTime),
          if (fastest != null)
            type.showsSpeed
                ? _recordTile(Icons.bolt, "Kecepatan rata-rata tertinggi", "${formatSpeed(fastest.speedKmh)} km/j", fastest)
                : _recordTile(Icons.bolt, "Pace tercepat", "${formatPace(fastest.paceSecPerKm)} /km", fastest),
        ],
      ),
    );
  }

  Widget _recordTile(IconData icon, String label, String value, Activity from) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(label),
      subtitle: Text("${from.title} · ${formatDate(from.startTime)}"),
      trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildStatItem(String label, String val) {
    return Column(
      children: [
        Text(val, style: AppTheme.display(30)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
