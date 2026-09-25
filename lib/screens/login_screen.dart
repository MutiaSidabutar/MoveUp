import 'package:flutter/material.dart';
import 'package:moveup/screens/sign_up_screen.dart';
import 'package:moveup/services/auth_service.dart';
import 'package:moveup/theme.dart';
import 'package:moveup/utils/validators.dart';
import 'package:moveup/widgets.dart';
import 'package:moveup/widgets/profile_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AuthService.signIn(_emailCtrl.text, _passwordCtrl.text);
      // AuthGate di halaman dasar akan menampilkan layar berikutnya
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } on AuthFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final emailCtrl = TextEditingController(text: _emailCtrl.text.trim());
    final formKey = GlobalKey<FormState>();
    final email = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Lupa Password"),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Masukkan email akun Anda. Kami akan mengirim tautan untuk membuat password baru."),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
                decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.mail_outline)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(context, emailCtrl.text.trim());
            },
            child: const Text("Kirim"),
          ),
        ],
      ),
    );
    emailCtrl.dispose();
    if (email == null || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await AuthService.sendPasswordReset(email);
      // Pesan dibuat sama untuk email terdaftar maupun tidak, supaya daftar akun tidak bisa ditebak
      messenger.showSnackBar(SnackBar(content: Text("Jika $email terdaftar, tautan reset password sudah dikirim.")));
    } on AuthFailure catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              Text("SELAMAT DATANG", style: AppTheme.display(38, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Text("Masuk untuk melanjutkan latihanmu", style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 16)),
              const SizedBox(height: 40),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.next,
                validator: Validators.email,
                decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.mail_outline)),
              ),
              const SizedBox(height: 16),
              PasswordField(
                controller: _passwordCtrl,
                label: "Password",
                validator: Validators.requiredPassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: _loading ? null : _forgotPassword, child: const Text("Lupa password?")),
              ),
              if (_error != null) _ErrorBanner(message: _error!),
              const SizedBox(height: 16),
              PrimaryButton(text: _loading ? "Memproses…" : "Masuk", onPressed: _loading ? () {} : _submit),
              const SizedBox(height: 24),
              const _OrDivider(),
              const SizedBox(height: 24),
              GoogleSignInButton(enabled: !_loading),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Belum punya akun?", style: TextStyle(color: scheme.onSurfaceVariant)),
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignUpScreen())),
                    child: const Text("Daftar", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text("ATAU", style: TextStyle(color: muted, fontSize: 12, letterSpacing: 2)),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

// Dipakai juga di layar pendaftaran
class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({super.key, this.enabled = true});

  final bool enabled;

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _loading = false;

  Future<void> _signIn() async {
    setState(() => _loading = true);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final signedIn = await AuthService.signInWithGoogle();
      if (signedIn) navigator.popUntil((route) => route.isFirst);
    } on AuthFailure catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: widget.enabled && !_loading ? _signIn : null,
        icon: _loading
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
            : const Text("G", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        label: const Text("Lanjutkan dengan Google", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: error.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: error, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: TextStyle(color: error))),
        ],
      ),
    );
  }
}
