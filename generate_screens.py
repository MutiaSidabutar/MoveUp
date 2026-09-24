import os

def create_file(path, content):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

def main():
    base_dir = r"c:\Users\Lenovo\program\flut_ter\moveup\lib"
    
    # 1. Main file
    create_file(os.path.join(base_dir, "main.dart"), """
import 'package:flutter/material.dart';
import 'package:moveup/theme.dart';
import 'package:moveup/screens/splash_screen.dart';
import 'package:moveup/screens/main_screen.dart';

void main() {
  runApp(const MoveUpApp());
}

class MoveUpApp extends StatelessWidget {
  const MoveUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoveUp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
""")

    # 2. Theme file
    create_file(os.path.join(base_dir, "theme.dart"), """
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF10B981); // Energetic green
  static const Color primaryDarkColor = Color(0xFF059669);
  
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: const Color(0xFFF9FAFB),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: primaryColor,
        surface: Colors.white,
        onSurface: Color(0xFF111827),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Color(0xFF9CA3AF),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: const Color(0xFF111827),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: primaryColor,
        surface: Color(0xFF1F2937),
        onSurface: Color(0xFFF9FAFB),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: const Color(0xFF374151),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF1F2937),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF374151), width: 1),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1F2937),
        selectedItemColor: primaryColor,
        unselectedItemColor: Color(0xFF9CA3AF),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
""")

    # 3. Widgets file
    create_file(os.path.join(base_dir, "widgets.dart"), """
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

// Button Components
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;

  const PrimaryButton({super.key, required this.text, required this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
            Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const SecondaryButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// Cards
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class ActivityCard extends StatelessWidget {
  final String title;
  final String date;
  final String duration;
  final String calories;
  final IconData icon;
  final VoidCallback? onTap;

  const ActivityCard({
    super.key,
    required this.title,
    required this.date,
    required this.duration,
    required this.calories,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(date, style: const TextStyle(fontSize: 12)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(duration, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(calories, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// Progress Ring
class CircularProgressCard extends StatelessWidget {
  final double progress;
  final String title;
  final String subtitle;

  const CircularProgressCard({super.key, required this.progress, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 120,
          width: 120,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 10,
            backgroundColor: Theme.of(context).dividerColor.withOpacity(0.1),
            color: Theme.of(context).primaryColor,
            strokeCap: StrokeCap.round,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        )
      ],
    );
  }
}

// Empty State
class EmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyStateWidget({super.key, required this.message, this.icon = LucideIcons.inbox});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}

// Chart Placeholder
class ChartPlaceholder extends StatelessWidget {
  const ChartPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.barChart2, size: 48, color: Theme.of(context).primaryColor.withOpacity(0.5)),
            const SizedBox(height: 8),
            const Text("Grafik Statistik", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
""")

    # 4. Screens
    create_file(os.path.join(base_dir, "screens", "splash_screen.dart"), """
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:moveup/screens/login_screen.dart';
import 'package:moveup/widgets.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(LucideIcons.activity, size: 80, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(height: 32),
              const Text(
                "MoveUp",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "Mulai langkah sehatmu hari ini, tanpa tekanan. Pantau aktivitasmu dengan mudah.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
              ),
              const Spacer(),
              PrimaryButton(
                text: "Mulai Sekarang",
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
""")

    create_file(os.path.join(base_dir, "screens", "login_screen.dart"), """
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:moveup/screens/main_screen.dart';
import 'package:moveup/widgets.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text("Selamat Datang!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("Silakan masuk untuk melanjutkan", style: TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 40),
              
              const TextField(
                decoration: InputDecoration(
                  hintText: "Email",
                  prefixIcon: Icon(LucideIcons.mail),
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Password",
                  prefixIcon: Icon(LucideIcons.lock),
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: "Masuk",
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
                },
              ),
              const SizedBox(height: 24),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text("ATAU", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 24),
              SecondaryButton(
                text: "Lanjutkan dengan Google",
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
""")

    create_file(os.path.join(base_dir, "screens", "main_screen.dart"), """
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:moveup/screens/dashboard_screen.dart';
import 'package:moveup/screens/history_screen.dart';
import 'package:moveup/screens/add_activity_screen.dart';
import 'package:moveup/screens/statistics_screen.dart';
import 'package:moveup/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const DashboardScreen(),
    const HistoryScreen(),
    const Scaffold(), // Placeholder for add activity which is a modal or push route
    const StatisticsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddActivityScreen()));
        },
        child: const Icon(LucideIcons.plus, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex == 2 ? 0 : _currentIndex, // Prevent selecting the middle button
        onTap: (index) {
          if (index != 2) {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(LucideIcons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(LucideIcons.clock), label: "Riwayat"),
          BottomNavigationBarItem(icon: Icon(Icons.add, color: Colors.transparent), label: ""),
          BottomNavigationBarItem(icon: Icon(LucideIcons.barChart2), label: "Statistik"),
          BottomNavigationBarItem(icon: Icon(LucideIcons.user), label: "Profil"),
        ],
      ),
    );
  }
}
""")

    create_file(os.path.join(base_dir, "screens", "dashboard_screen.dart"), """
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
                  child: Icon(LucideIcons.user, color: Colors.white),
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
                Expanded(child: StatCard(title: "Kalori", value: "450 kcal", icon: LucideIcons.flame, color: Colors.orange)),
                SizedBox(width: 12),
                Expanded(child: StatCard(title: "Durasi", value: "45 mnt", icon: LucideIcons.timer, color: Colors.blue)),
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
              icon: LucideIcons.footprints,
            ),
            const ActivityCard(
              title: "Jalan Santai",
              date: "Kemarin, 16:00",
              duration: "45 mnt",
              calories: "210 kcal",
              icon: LucideIcons.personStanding,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
""")

    create_file(os.path.join(base_dir, "screens", "add_activity_screen.dart"), """
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
                _buildActivityOption(context, "Lari", LucideIcons.footprints, true),
                _buildActivityOption(context, "Jalan", LucideIcons.personStanding, false),
                _buildActivityOption(context, "Sepeda", LucideIcons.bike, false),
                _buildActivityOption(context, "Gym", LucideIcons.dumbbell, false),
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
              icon: LucideIcons.navigation,
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
""")

    create_file(os.path.join(base_dir, "screens", "gps_tracking_screen.dart"), """
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class GpsTrackingScreen extends StatelessWidget {
  const GpsTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fake Map Background
          Container(
            color: const Color(0xFFE5E5E5),
            width: double.infinity,
            height: double.infinity,
            child: const Center(
              child: Text("Peta Live (Mock)", style: TextStyle(color: Colors.grey, fontSize: 24)),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(LucideIcons.arrowLeft, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),

          // Bottom Stats Panel
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("12:45", style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold)),
                  const Text("Menit", style: TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMiniStat("2.4", "KM"),
                      _buildMiniStat("5:12", "Pace"),
                      _buildMiniStat("150", "Kcal"),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.pause, color: Colors.white, size: 40),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMiniStat(String val, String label) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
""")

    create_file(os.path.join(base_dir, "screens", "history_screen.dart"), """
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
                  icon: const Icon(LucideIcons.filter),
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
                  icon: LucideIcons.footprints,
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
                  icon: LucideIcons.personStanding,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActivityDetailScreen())),
                ),
                ActivityCard(
                  title: "Bersepeda",
                  date: "07:00 - 08:00",
                  duration: "60 mnt",
                  calories: "450 kcal",
                  icon: LucideIcons.bike,
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
""")

    create_file(os.path.join(base_dir, "screens", "activity_detail_screen.dart"), """
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ActivityDetailScreen extends StatelessWidget {
  const ActivityDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Aktivitas"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Map Placeholder
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(child: Icon(LucideIcons.map, size: 48, color: Colors.grey)),
            ),
            const SizedBox(height: 24),
            
            // Achievement Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                        child: Icon(LucideIcons.footprints, color: Theme.of(context).primaryColor, size: 32),
                      ),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Lari Pagi", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text("15 Okt 2026, 06:30", style: TextStyle(color: Colors.grey)),
                        ],
                      )
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Divider(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDetailStat("5.2", "KM"),
                      _buildDetailStat("32:15", "Waktu"),
                      _buildDetailStat("340", "Kalori"),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
""")

    create_file(os.path.join(base_dir, "screens", "statistics_screen.dart"), """
import 'package:flutter/material.dart';
import 'package:moveup/widgets.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Statistik", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            // Toggle
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(child: Text("Mingguan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: const Center(child: Text("Bulanan", style: TextStyle(fontWeight: FontWeight.bold))),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Big numbers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem("Total Sesi", "4"),
                _buildStatItem("Durasi", "2j 15m"),
                _buildStatItem("Jarak", "12 km"),
              ],
            ),
            const SizedBox(height: 32),
            
            const Text("Aktivitas Harian", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const ChartPlaceholder(),
            const SizedBox(height: 32),
            
            const Text("Kalori Terbakar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const ChartPlaceholder(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String val) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
""")

    create_file(os.path.join(base_dir, "screens", "profile_screen.dart"), """
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
              child: Icon(LucideIcons.user, color: Colors.white, size: 40),
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
            _buildMenuItem(context, LucideIcons.target, "Target (Goal Setting)", onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalsScreen()));
            }),
            _buildMenuItem(context, LucideIcons.bell, "Pengaturan Reminder", onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ReminderScreen()));
            }),
            _buildMenuItem(context, LucideIcons.shield, "Keamanan Akun"),
            const SizedBox(height: 20),
            _buildMenuItem(context, LucideIcons.logOut, "Logout", color: Colors.red),
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
      trailing: const Icon(LucideIcons.chevronRight, size: 20),
    );
  }
}
""")

    create_file(os.path.join(base_dir, "screens", "goals_screen.dart"), """
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Target Saya"), backgroundColor: Colors.transparent, elevation: 0),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(LucideIcons.plus),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildGoalCard(context, "Jalan Kaki Harian", "10,000 Langkah", 0.7, true),
          _buildGoalCard(context, "Bakar Kalori", "2,000 Kcal / Minggu", 1.0, false), // Completed
          _buildGoalCard(context, "Olahraga 3x Seminggu", "2/3 Sesi", 0.66, true),
        ],
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, String title, String subtitle, double progress, bool isActive) {
    bool isCompleted = progress >= 1.0;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text("Tercapai 🎉", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                  )
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Theme.of(context).dividerColor.withOpacity(0.1),
              color: isCompleted ? Colors.orange : Theme.of(context).primaryColor,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            )
          ],
        ),
      ),
    );
  }
}
""")

    create_file(os.path.join(base_dir, "screens", "reminder_screen.dart"), """
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
            PrimaryButton(text: "Tambah Reminder Baru", icon: LucideIcons.plus, onPressed: () {
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
              const Text("Tambah Reminder", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
""")

if __name__ == "__main__":
    main()
