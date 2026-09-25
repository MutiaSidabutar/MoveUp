import 'package:flutter/material.dart';
import 'package:moveup/screens/login_screen.dart';
import 'package:moveup/theme.dart';
import 'package:moveup/widgets.dart';

// Langit berkabut di atas garis cakrawala dengan siluet pelari, seperti foto referensi tema
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const sky = [Color(0xFFF1F1EE), Color(0xFFBDBDB9)];
    const ground = Color(0xFF1A1A1A);

    return Scaffold(
      backgroundColor: ground,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 6,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: sky),
                  ),
                  alignment: Alignment.bottomCenter,
                  child: const Padding(
                    padding: EdgeInsets.only(right: 48),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Icon(Icons.directions_run, size: 56, color: ground),
                    ),
                  ),
                ),
              ),
              Container(height: 3, color: const Color(0xFF8E8E8A)),
              const Expanded(flex: 4, child: SizedBox()),
            ],
          ),
          const Positioned.fill(child: FilmGrain(opacity: 0.08)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  Text("MOVEUP", style: AppTheme.display(64, color: ground, letterSpacing: 8)),
                  Text(
                    "RUN · RIDE · HIKE",
                    style: AppTheme.display(16, color: ground.withValues(alpha: 0.6), letterSpacing: 4),
                  ),
                  const Spacer(),
                  const Text(
                    "Mulai langkah sehatmu hari ini, tanpa tekanan. Pantau setiap langkah, kayuhan, dan tanjakan.",
                    style: TextStyle(fontSize: 16, color: Color(0xFFBDBDB9), height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F1EE),
                        foregroundColor: ground,
                      ),
                      onPressed: () {
                        // push (bukan replace) supaya AuthGate tetap menjadi halaman dasar
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                      },
                      child: Text("MULAI SEKARANG", style: AppTheme.display(18, letterSpacing: 2)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
