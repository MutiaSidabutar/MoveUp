
import 'package:flutter/material.dart';
import 'package:moveup/theme.dart';
import 'package:moveup/widgets.dart';

class ReminderScreen extends StatelessWidget {
  const ReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pengaturan Reminder"), backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Lari Pagi", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("Setiap Hari â€¢ 06:00"),
              trailing: Switch(value: true, onChanged: (v) {}, activeColor: Theme.of(context).primaryColor),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Gym", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("Senin, Rabu, Jumat â€¢ 17:00"),
              trailing: Switch(value: false, onChanged: (v) {}, activeColor: Theme.of(context).primaryColor),
            ),
            const Spacer(),
            PrimaryButton(text: "Tambah Reminder Baru", icon: Icons.add, onPressed: () {
              _showAddReminderSheet(context);
            })
          ],
        ),
      ),
    );
  }

  void _showAddReminderSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Tambah Reminder", style: AppTheme.display(24)),
              const SizedBox(height: 24),
              const TextField(decoration: InputDecoration(hintText: "Nama Aktivitas (misal: Lari)")),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: SecondaryButton(text: "Pilih Waktu", onPressed: (){})),
                ],
              ),
              const SizedBox(height: 24),
              PrimaryButton(text: "Simpan", onPressed: () => Navigator.pop(context)),
              const SizedBox(height: 20),
            ],
          ),
        );
      }
    );
  }
}
