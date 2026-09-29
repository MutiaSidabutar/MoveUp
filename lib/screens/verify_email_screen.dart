import 'dart:async';

import 'package:flutter/material.dart';
import 'package:moveup/services/auth_service.dart';
import 'package:moveup/theme.dart';
import 'package:moveup/widgets.dart';

// Akun baru harus memverifikasi email sebelum bisa memakai aplikasi
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key, required this.onVerified});

  final VoidCallback onVerified;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  static const _resendCooldown = 60;

  Timer? _poll;
  Timer? _cooldownTimer;
  int _cooldown = _resendCooldown;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _startCooldown();
    // Cek otomatis supaya pengguna tidak perlu menekan tombol setelah klik tautan di email
    _poll = Timer.periodic(const Duration(seconds: 5), (_) => _check(silent: true));
  }

  @override
  void dispose() {
    _poll?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _cooldown = _resendCooldown);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_cooldown <= 1) t.cancel();
      setState(() => _cooldown--);
    });
  }

  Future<void> _check({bool silent = false}) async {
    if (_checking) return;
    _checking = true;
    try {
      final verified = await AuthService.reloadAndCheckVerified();
      if (verified) {
        _poll?.cancel();
        widget.onVerified();
      } else if (!silent && mounted) {
        showErrorMessage(context, "Email belum terverifikasi. Buka tautan di email Anda.");
      }
    } on AuthFailure catch (e) {
      if (!silent && mounted) showErrorMessage(context, e.message);
    } finally {
      _checking = false;
    }
  }

  Future<void> _resend() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await AuthService.resendVerification();
      _startCooldown();
      messenger.success("Email verifikasi dikirim ulang.");
    } on AuthFailure catch (e) {
      messenger.error(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final email = AuthService.currentUser?.email ?? '';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Icon(Icons.mark_email_unread_outlined, size: 72, color: scheme.primary),
              const SizedBox(height: 24),
              Text("VERIFIKASI EMAIL", style: AppTheme.display(36, letterSpacing: 1.5)),
              const SizedBox(height: 12),
              Text.rich(
                TextSpan(children: [
                  const TextSpan(text: "Kami telah mengirim tautan verifikasi ke "),
                  TextSpan(text: email, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(text: ". Buka tautan tersebut, lalu kembali ke aplikasi ini."),
                ]),
                style: TextStyle(fontSize: 16, height: 1.5, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Text("Tidak ada di kotak masuk? Periksa folder spam.", style: TextStyle(color: scheme.onSurfaceVariant)),
              const Spacer(),
              PrimaryButton(text: "Saya Sudah Verifikasi", onPressed: () => _check()),
              const SizedBox(height: 12),
              SecondaryButton(
                text: _cooldown > 0 ? "Kirim ulang dalam $_cooldown detik" : "Kirim Ulang Email",
                onPressed: _cooldown > 0 ? () {} : _resend,
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: AuthService.signOut,
                  child: const Text("Gunakan akun lain"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
