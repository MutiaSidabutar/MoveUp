
import 'package:flutter/material.dart';
import 'package:moveup/widgets.dart';
import 'package:moveup/screens/gps_tracking_screen.dart';

class AddActivityScreen extends StatelessWidget {
  const AddActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mulai Aktivitas"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Pilih Jenis Olahraga", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildActivityOption(context, "Lari", Icons.directions_run, true),
                _buildActivityOption(context, "Jalan", Icons.directions_walk, false),
                _buildActivityOption(context, "Sepeda", Icons.directions_bike, false),
                _buildActivityOption(context, "Gym", Icons.fitness_center, false),
              ],
            ),
            const SizedBox(height: 32),
            const Text("Atau Input Manual", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(hintText: "Durasi (menit)"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(hintText: "Kalori Terbakar"),
              keyboardType: TextInputType.number,
            ),
            const Spacer(),
            PrimaryButton(
              text: "Mulai Pelacakan GPS",
              icon: Icons.navigation_outlined,
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const GpsTrackingScreen()));
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityOption(BuildContext context, String title, IconData icon, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).dividerColor.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: isSelected ? Theme.of(context).primaryColor : Colors.grey),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Theme.of(context).primaryColor : null)),
        ],
      ),
    );
  }
}
