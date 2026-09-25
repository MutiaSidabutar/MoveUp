import 'package:flutter/material.dart';
import 'package:moveup/screens/dashboard_screen.dart';
import 'package:moveup/screens/gps_tracking_screen.dart';
import 'package:moveup/screens/history_screen.dart';
import 'package:moveup/screens/statistics_screen.dart';
import 'package:moveup/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    HistoryScreen(),
    SizedBox(), // Slot tombol Rekam di tengah, dibuka sebagai halaman terpisah
    StatisticsScreen(),
    ProfileScreen(),
  ];

  void _openRecorder() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const GpsTrackingScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      floatingActionButton: FloatingActionButton(
        elevation: 4,
        shape: const CircleBorder(),
        tooltip: "Rekam aktivitas",
        onPressed: _openRecorder,
        child: const Icon(Icons.fiber_manual_record, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            _openRecorder();
          } else {
            setState(() => _currentIndex = index);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: "Riwayat"),
          BottomNavigationBarItem(icon: Icon(Icons.add, color: Colors.transparent), label: "Rekam"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Statistik"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profil"),
        ],
      ),
    );
  }
}
