import 'package:flutter/material.dart';
import 'package:moveup/models/activity.dart';
import 'package:moveup/services/activity_store.dart';
import 'package:moveup/services/goal_store.dart';
import 'package:moveup/services/reminder_store.dart';
import 'package:moveup/services/settings_service.dart';
import 'package:moveup/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<bool> _confirm(BuildContext context, String title, String message, String action) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _loadSample(BuildContext context) async {
    final ok = await _confirm(
      context,
      "Muat data simulasi?",
      "Semua aktivitas, target, dan pengingat di perangkat ini akan diganti dengan data contoh.",
      "Ganti Data",
    );
    if (!ok) return;
    await ActivityStore.instance.resetToSample();
    await GoalStore.instance.resetToSample();
    await ReminderStore.instance.resetToSample();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data simulasi dimuat")));
    }
  }

  Future<void> _clearAll(BuildContext context) async {
    final ok = await _confirm(
      context,
      "Hapus semua data?",
      "Semua aktivitas, target, dan pengingat akan dihapus permanen. Profil akun tidak ikut terhapus.",
      "Hapus",
    );
    if (!ok) return;
    await ActivityStore.instance.replaceAll([]);
    await GoalStore.instance.replaceAll([]);
    await ReminderStore.instance.replaceAll([]);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Semua data dihapus")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService.instance;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Pengaturan")),
      body: ListenableBuilder(
        listenable: Listenable.merge([settings, ActivityStore.instance, GoalStore.instance, ReminderStore.instance]),
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text("Tampilan", style: AppTheme.display(22)),
            const SizedBox(height: 12),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto), label: Text("Sistem")),
                ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode_outlined), label: Text("Terang")),
                ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode_outlined), label: Text("Gelap")),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (s) => settings.setThemeMode(s.first),
            ),
            const SizedBox(height: 32),
            Text("Data", style: AppTheme.display(22)),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  _countRow(Icons.directions_run, "Aktivitas", ActivityStore.instance.activities.length),
                  _countRow(Icons.track_changes, "Target", GoalStore.instance.goals.length),
                  _countRow(Icons.notifications_none, "Pengingat", ReminderStore.instance.reminders.length),
                  _countRow(Icons.category_outlined, "Kategori olahraga", SportType.values.length),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.dataset_outlined),
              title: const Text("Muat data simulasi"),
              subtitle: const Text("24 aktivitas, 6 target, dan 4 pengingat contoh"),
              onTap: () => _loadSample(context),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
              title: const Text("Hapus semua data", style: TextStyle(color: Colors.red)),
              subtitle: const Text("Aktivitas, target, dan pengingat di perangkat ini"),
              onTap: () => _clearAll(context),
            ),
            const SizedBox(height: 32),
            Text("Tentang", style: AppTheme.display(22)),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.info_outline),
              title: const Text("MoveUp"),
              subtitle: Text("Versi 1.0.0 · Pelacak olahraga", style: TextStyle(color: scheme.onSurfaceVariant)),
              onTap: () => showAboutDialog(
                context: context,
                applicationName: "MoveUp",
                applicationVersion: "1.0.0",
                applicationLegalese: "Rekam lari, jalan, bersepeda, hiking, dan renang. Pantau target dan jadwal latihanmu.",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _countRow(IconData icon, String label, int count) {
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 20),
      title: Text(label),
      trailing: Text("$count", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}
