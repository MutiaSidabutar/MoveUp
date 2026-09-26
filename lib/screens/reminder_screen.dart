import 'package:flutter/material.dart';
import 'package:moveup/models/reminder.dart';
import 'package:moveup/screens/reminder_form_screen.dart';
import 'package:moveup/services/goal_store.dart';
import 'package:moveup/services/reminder_store.dart';
import 'package:moveup/utils/format.dart';
import 'package:moveup/widgets.dart';

class ReminderScreen extends StatelessWidget {
  const ReminderScreen({super.key});

  void _open(BuildContext context, [Reminder? reminder]) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ReminderFormScreen(reminder: reminder)));
  }

  Future<void> _delete(BuildContext context, Reminder reminder) async {
    final messenger = ScaffoldMessenger.of(context);
    await ReminderStore.instance.remove(reminder.id);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text("\"${reminder.title}\" dihapus"),
        action: SnackBarAction(label: "Urungkan", onPressed: () => ReminderStore.instance.add(reminder)),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pengaturan Reminder"), backgroundColor: Colors.transparent, elevation: 0),
      body: ListenableBuilder(
        listenable: Listenable.merge([ReminderStore.instance, GoalStore.instance]),
        builder: (context, _) {
          final reminders = ReminderStore.instance.reminders;
          final now = DateTime.now();
          final next = reminders
              .map((r) => (r, r.nextAfter(now)))
              .where((e) => e.$2 != null)
              .fold<(Reminder, DateTime?)?>(null, (best, e) => best == null || e.$2!.isBefore(best.$2!) ? e : best);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: reminders.isEmpty
                    ? const EmptyStateWidget(
                        message: "Belum ada pengingat.\nBuat jadwal latihan rutinmu.",
                        icon: Icons.notifications_none,
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: [
                          if (next != null)
                            Card(
                              child: ListTile(
                                leading: const Icon(Icons.alarm),
                                title: const Text("Jadwal berikutnya"),
                                subtitle: Text("${next.$1.title} · ${formatRelativeDateTime(next.$2!)}"),
                              ),
                            ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              "Geser ke kiri untuk menghapus, ketuk untuk mengubah.",
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ),
                          for (final r in reminders) ...[
                            _ReminderTile(
                              reminder: r,
                              onTap: () => _open(context, r),
                              onDelete: () => _delete(context, r),
                            ),
                            const Divider(height: 1),
                          ],
                        ],
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: PrimaryButton(text: "Tambah Reminder Baru", icon: Icons.add, onPressed: () => _open(context)),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({required this.reminder, required this.onTap, required this.onDelete});

  final Reminder reminder;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final goal = reminder.goalId == null ? null : GoalStore.instance.byId(reminder.goalId!);
    final muted = reminder.enabled ? null : Colors.grey;

    return Dismissible(
      key: ValueKey(reminder.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        onTap: onTap,
        leading: Icon(reminder.sportType.icon, color: muted),
        title: Text(
          "${reminder.timeLabel}  ${reminder.title}",
          style: TextStyle(fontWeight: FontWeight.bold, color: muted),
        ),
        subtitle: Text("${reminder.daysLabel}${goal == null ? '' : ' · ${goal.title}'}"),
        trailing: Switch(
          value: reminder.enabled,
          onChanged: (v) => ReminderStore.instance.update(reminder.copyWith(enabled: v)),
        ),
      ),
    );
  }
}
