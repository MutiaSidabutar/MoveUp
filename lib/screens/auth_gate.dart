import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moveup/models/user_profile.dart';
import 'package:moveup/screens/complete_profile_screen.dart';
import 'package:moveup/screens/main_screen.dart';
import 'package:moveup/screens/splash_screen.dart';
import 'package:moveup/screens/verify_email_screen.dart';
import 'package:moveup/services/activity_store.dart';
import 'package:moveup/services/auth_service.dart';
import 'package:moveup/services/goal_store.dart';
import 'package:moveup/services/profile_service.dart';
import 'package:moveup/services/reminder_store.dart';

// Halaman dasar aplikasi: memilih layar sesuai status login
// belum masuk → Splash, belum verifikasi → Verifikasi Email, belum ada profil → Lengkapi Profil, selain itu → Beranda
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Future<UserProfile?>? _profileFuture;
  String? _loadedUid;

  Future<UserProfile?> _loadFor(User user) {
    if (_loadedUid != user.uid || _profileFuture == null) {
      _loadedUid = user.uid;
      _profileFuture = ProfileService.instance.load(user.uid);
      // Ditunda ke microtask karena memuat data memberi notifikasi ke listener, tidak boleh saat build
      final uid = user.uid;
      Future.microtask(() {
        ActivityStore.instance.loadFor(uid);
        GoalStore.instance.loadFor(uid);
        ReminderStore.instance.loadFor(uid);
      });
    }
    return _profileFuture!;
  }

  void _retry() => setState(() => _profileFuture = null);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AuthService.demoSignedIn,
      builder: (context, demo, _) => demo ? const MainScreen() : _firebaseGate(context),
    );
  }

  Widget _firebaseGate(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.userChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const _Loading();
        final user = snapshot.data;
        if (user == null) {
          _loadedUid = null;
          _profileFuture = null;
          return const SplashScreen();
        }
        // currentUser dibaca ulang karena reload() memperbarui status verifikasi
        if (!(AuthService.currentUser?.emailVerified ?? user.emailVerified)) {
          return VerifyEmailScreen(onVerified: () => setState(() {}));
        }
        return ListenableBuilder(
          listenable: ProfileService.instance,
          builder: (context, _) => FutureBuilder<UserProfile?>(
            future: _loadFor(user),
            builder: (context, profileSnap) {
              if (profileSnap.connectionState != ConnectionState.done) return const _Loading();
              if (profileSnap.hasError) return _LoadError(onRetry: _retry);
              // Profil dari service lebih baru kalau baru saja disimpan lewat Lengkapi Profil
              final profile = ProfileService.instance.profile ?? profileSnap.data;
              return profile == null ? const CompleteProfileScreen() : const MainScreen();
            },
          ),
        );
      },
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 48),
              const SizedBox(height: 16),
              const Text("Gagal memuat profil. Periksa koneksi internet Anda.", textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: onRetry, child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text("Coba Lagi"),
              )),
              TextButton(onPressed: AuthService.signOut, child: const Text("Keluar")),
            ],
          ),
        ),
      ),
    );
  }
}
