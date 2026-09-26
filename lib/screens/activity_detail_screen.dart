import 'package:flutter/material.dart';
import 'package:moveup/theme.dart';
import 'package:moveup/models/activity.dart';
import 'package:moveup/screens/add_activity_screen.dart';
import 'package:moveup/screens/goal_detail_screen.dart';
import 'package:moveup/services/activity_store.dart';
import 'package:moveup/services/goal_store.dart';
import 'package:moveup/services/profile_service.dart';
import 'package:moveup/utils/format.dart';
import 'package:moveup/widgets/route_map.dart';

class ActivityDetailScreen extends StatelessWidget {
  const ActivityDetailScreen({super.key, required this.activity});

  final Activity activity;

  Future<void> _confirmDelete(BuildContext context, Activity activity) async {
    final delete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus aktivitas?"),
        content: Text("\"${activity.title}\" akan dihapus permanen."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (delete != true) return;
    await ActivityStore.instance.remove(activity.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Aktivitas dihapus")));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Dibaca ulang dari store supaya hasil edit langsung tampil
    return ListenableBuilder(
      listenable: Listenable.merge([ActivityStore.instance, GoalStore.instance]),
      builder: (context, _) => _build(context, ActivityStore.instance.byId(activity.id) ?? activity),
    );
  }

  Widget _build(BuildContext context, Activity activity) {
    final primary = Theme.of(context).primaryColor;
    final (paceLabel, paceValue) = paceOrSpeed(activity);
    final splits = activity.splits;
    final all = ActivityStore.instance.activities;
    // Target yang periode berjalannya ikut dihitung dari aktivitas ini
    final goals = [
      for (final g in GoalStore.instance.goals)
        if (g.progress(all).activities.any((a) => a.id == activity.id)) g,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(activity.type.label),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: "Edit",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddActivityScreen(activity: activity)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: "Hapus",
            onPressed: () => _confirmDelete(context, activity),
          ),
        ],
      ),
      body: ListView(
        children: [
          if (activity.points.isNotEmpty) SizedBox(height: 300, child: RouteMap(points: activity.points, interactive: true)),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      child: Text(ProfileService.instance.profile?.initials ?? '?', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ProfileService.instance.profile?.name ?? 'Pengguna', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          "${formatDate(activity.startTime)} pukul ${formatTime(activity.startTime)}",
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(activity.title, style: AppTheme.display(30)),
                if (activity.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(activity.description),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    _DetailStat(label: "Jarak", value: "${formatKm(activity.distanceMeters)} km"),
                    _DetailStat(label: "$paceLabel rata-rata", value: paceValue),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _DetailStat(label: "Waktu bergerak", value: formatDuration(activity.movingSeconds)),
                    _DetailStat(label: "Kalori", value: "${activity.calories} kcal"),
                  ],
                ),
                if (splits.isNotEmpty) ...[
                  const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Divider()),
                  Text("Split", style: AppTheme.display(22)),
                  const SizedBox(height: 12),
                  _SplitsTable(splits: splits, showsSpeed: activity.type.showsSpeed),
                ],
                if (goals.isNotEmpty) ...[
                  const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Divider()),
                  Text("Target Terkait", style: AppTheme.display(22)),
                  const SizedBox(height: 8),
                  for (final goal in goals)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(goal.icon),
                      title: Text(goal.title),
                      subtitle: Text("${goal.period.label} · ${goal.targetLabel}"),
                      trailing: const Icon(Icons.chevron_right, size: 20),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => GoalDetailScreen(goalId: goal.id)),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailStat extends StatelessWidget {
  const _DetailStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: AppTheme.display(28)),
        ],
      ),
    );
  }
}

// Tabel pace per kilometer; batang lebih panjang berarti lebih cepat
class _SplitsTable extends StatelessWidget {
  const _SplitsTable({required this.splits, required this.showsSpeed});

  final List<KmSplit> splits;
  final bool showsSpeed;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final maxSpeed = splits.map((s) => s.speedKmh).reduce((a, b) => a > b ? a : b);
    const headerStyle = TextStyle(color: Colors.grey, fontSize: 12);

    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 48, child: Text("Km", style: headerStyle)),
            SizedBox(width: 64, child: Text(showsSpeed ? "km/j" : "Pace", style: headerStyle)),
          ],
        ),
        const SizedBox(height: 8),
        for (final split in splits)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 48,
                  child: Text(split.distanceMeters >= 1000 ? "${split.index}" : formatKm(split.distanceMeters)),
                ),
                SizedBox(
                  width: 64,
                  child: Text(
                    showsSpeed ? formatSpeed(split.speedKmh) : formatPace(split.paceSecPerKm),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: maxSpeed == 0 ? 0 : (split.speedKmh / maxSpeed).clamp(0.05, 1.0),
                      child: Container(
                        height: 14,
                        decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(3)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
