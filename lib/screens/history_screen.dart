
import 'package:flutter/material.dart';
import 'package:moveup/widgets.dart';
import 'package:moveup/screens/activity_detail_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Riwayat", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.filter_alt_outlined),
                  onPressed: () {},
                )
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text("Hari Ini", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                ),
                ActivityCard(
                  title: "Lari Pagi",
                  date: "06:30 - 07:00",
                  duration: "30 mnt",
                  calories: "320 kcal",
                  icon: Icons.directions_run,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActivityDetailScreen())),
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text("Kemarin", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                ),
                ActivityCard(
                  title: "Jalan Santai",
                  date: "16:00 - 16:45",
                  duration: "45 mnt",
                  calories: "210 kcal",
                  icon: Icons.directions_walk,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActivityDetailScreen())),
                ),
                ActivityCard(
                  title: "Bersepeda",
                  date: "07:00 - 08:00",
                  duration: "60 mnt",
                  calories: "450 kcal",
                  icon: Icons.directions_bike,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActivityDetailScreen())),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
