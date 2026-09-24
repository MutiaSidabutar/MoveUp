
import 'package:flutter/material.dart';
import 'package:moveup/screens/goals_screen.dart';
import 'package:moveup/screens/reminder_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person_outline, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 16),
            const Text("Alex Rahman", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Text("Pemula Olahraga", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            
            // Body stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBodyStat(context, "Berat", "65 kg"),
                Container(height: 40, width: 1, color: Colors.grey[300]),
                _buildBodyStat(context, "Tinggi", "170 cm"),
                Container(height: 40, width: 1, color: Colors.grey[300]),
                _buildBodyStat(context, "BMI", "22.5"),
              ],
            ),
            const SizedBox(height: 40),
            
            // Menus
            _buildMenuItem(context, Icons.track_changes, "Target (Goal Setting)", onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalsScreen()));
            }),
            _buildMenuItem(context, Icons.notifications_none, "Pengaturan Reminder", onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ReminderScreen()));
            }),
            _buildMenuItem(context, Icons.security, "Keamanan Akun"),
            const SizedBox(height: 20),
            _buildMenuItem(context, Icons.logout, "Logout", color: Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyStat(BuildContext context, String label, String val) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, {Color? color, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (color ?? Theme.of(context).primaryColor).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color ?? Theme.of(context).primaryColor),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
      trailing: const Icon(Icons.chevron_right, size: 20),
    );
  }
}
