
import 'package:flutter/material.dart';
import 'package:moveup/widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Halo, Alex 👋", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text("Mari bergerak hari ini!", style: TextStyle(color: Colors.grey)),
                  ],
                ),
                const CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person_outline, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Progress Section
            const Center(
              child: CircularProgressCard(
                progress: 0.65,
                title: "6.5k",
                subtitle: "Langkah",
              ),
            ),
            const SizedBox(height: 32),
            
            // Stats Grid
            const Row(
              children: [
                Expanded(child: StatCard(title: "Kalori", value: "450 kcal", icon: Icons.local_fire_department_outlined, color: Colors.orange)),
                SizedBox(width: 12),
                Expanded(child: StatCard(title: "Durasi", value: "45 mnt", icon: Icons.timer_outlined, color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 32),
            
            // Mini Chart
            const Text("Progres Minggu Ini", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const ChartPlaceholder(),
            const SizedBox(height: 24),
            
            // Recent Activity
            const Text("Aktivitas Terakhir", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const ActivityCard(
              title: "Lari Pagi",
              date: "Hari ini, 06:30",
              duration: "30 mnt",
              calories: "320 kcal",
              icon: Icons.directions_run,
            ),
            const ActivityCard(
              title: "Jalan Santai",
              date: "Kemarin, 16:00",
              duration: "45 mnt",
              calories: "210 kcal",
              icon: Icons.directions_walk,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
