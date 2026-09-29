import 'package:flutter/material.dart';
import 'package:moveup/models/goal.dart';
import 'package:moveup/screens/goal_detail_screen.dart';
import 'package:moveup/screens/goal_form_screen.dart';
import 'package:moveup/services/activity_store.dart';
import 'package:moveup/services/goal_store.dart';
import 'package:moveup/widgets.dart';
import 'package:moveup/widgets/goal_progress_card.dart';

enum _GoalFilter {
  all('Semua'),
  ongoing('Berjalan'),
  done('Tercapai');

  const _GoalFilter(this.label);

  final String label;
}

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  _GoalFilter _filter = _GoalFilter.all;

  bool _matches(GoalProgress p) => switch (_filter) {
        _GoalFilter.all => true,
        _GoalFilter.ongoing => !p.completed,
        _GoalFilter.done => p.completed,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Target Saya")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalFormScreen())),
        icon: const Icon(Icons.add),
        label: const Text("Target Baru"),
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([GoalStore.instance, ActivityStore.instance]),
        builder: (context, _) {
          final activities = ActivityStore.instance.activities;
          final all = [for (final g in GoalStore.instance.goals) g.progress(activities)];
          final shown = all.where(_matches).toList();
          final doneCount = all.where((p) => p.completed).length;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
            children: [
              Text(
                all.isEmpty ? "Belum ada target" : "$doneCount dari ${all.length} target tercapai pada periode ini",
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  for (final f in _GoalFilter.values)
                    ChoiceChip(
                      label: Text(f.label),
                      selected: f == _filter,
                      onSelected: (_) => setState(() => _filter = f),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (shown.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 48),
                  child: all.isEmpty
                      ? EmptyStateWidget(
                          title: "Belum ada target",
                          message: "Tentukan jarak, durasi, atau jumlah latihan yang ingin dicapai.",
                          icon: Icons.track_changes,
                          actionLabel: "Buat Target",
                          onAction: () =>
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalFormScreen())),
                        )
                      : const EmptyStateWidget(
                          message: "Tidak ada target di filter ini",
                          icon: Icons.filter_alt_off_outlined,
                        ),
                )
              else
                for (final p in shown)
                  GoalProgressCard(
                    progress: p,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => GoalDetailScreen(goalId: p.goal.id)),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}
