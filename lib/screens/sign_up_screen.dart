import 'package:flutter/material.dart';
import 'package:moveup/screens/login_screen.dart';
import 'package:moveup/services/auth_service.dart';
import 'package:moveup/theme.dart';
import 'package:moveup/utils/validators.dart';
import 'package:moveup/widgets.dart';
import 'package:moveup/widgets/profile_form.dart';

// Pendaftaran 3 langkah: akun, data tubuh, lalu preferensi olahraga
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  static const _titles = ["Buat Akun", "Data Tubuh", "Preferensi"];
  static const _subtitles = [
    "Data login untuk akun MoveUp Anda",
    "Dipakai untuk menghitung kalori dan BMI",
    "Bantu kami menyesuaikan pengalaman Anda",
  ];

  final _formKeys = List.generate(3, (_) => GlobalKey<FormState>());
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _draft = ProfileDraft();
  int _step = 0;
  bool _acceptedTerms = false;
  bool _termsError = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _next() {
    FocusScope.of(context).unfocus();
    final valid = _formKeys[_step].currentState!.validate();
    if (_step == 0) setState(() => _termsError = !_acceptedTerms);
    if (!valid || (_step == 0 && !_acceptedTerms)) return;
    if (_step < 2) {
      setState(() => _step++);
    } else {
      _submit();
    }
  }

  void _back() {
    if (_step == 0) {
      Navigator.pop(context);
    } else {
      setState(() => _step--);
    }
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Firebase menyimpan email dalam huruf kecil; aturan Firestore membandingkannya dengan email akun
      final email = _emailCtrl.text.trim().toLowerCase();
      await AuthService.signUp(
        email: email,
        password: _passwordCtrl.text,
        buildProfile: (uid) => _draft.toProfile(uid: uid, email: email),
      );
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } on AuthFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        // Email yang sudah dipakai harus diperbaiki di langkah pertama
        if (e.code == 'email-already-in-use' || e.code == 'invalid-email') _step = 0;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: _step == 0 && !_loading,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_loading) _back();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _loading ? null : _back),
          title: Text("LANGKAH ${_step + 1} DARI 3"),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    for (var i = 0; i < 3; i++)
                      Expanded(
                        child: Container(
                          height: 4,
                          margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                          decoration: BoxDecoration(
                            color: i <= _step ? scheme.primary : scheme.outline,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text(_titles[_step].toUpperCase(), style: AppTheme.display(36, letterSpacing: 1.5)),
                    const SizedBox(height: 4),
                    Text(_subtitles[_step], style: TextStyle(color: scheme.onSurfaceVariant)),
                    const SizedBox(height: 28),
                    // IndexedStack menjaga isian tiap langkah saat maju-mundur
                    IndexedStack(
                      index: _step,
                      children: [
                        Form(key: _formKeys[0], child: _buildAccountStep()),
                        Form(key: _formKeys[1], child: BodyInfoFields(draft: _draft, onChanged: () => setState(() {}))),
                        Form(key: _formKeys[2], child: PreferenceFields(draft: _draft, onChanged: () => setState(() {}))),
                      ],
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Text(_error!, style: TextStyle(color: scheme.error, fontWeight: FontWeight.w600)),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: PrimaryButton(
                  text: _loading ? "Membuat akun…" : (_step < 2 ? "Lanjut" : "Buat Akun"),
                  onPressed: _loading ? () {} : _next,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountStep() {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          initialValue: _draft.name,
          textCapitalization: TextCapitalization.words,
          autofillHints: const [AutofillHints.name],
          textInputAction: TextInputAction.next,
          validator: Validators.name,
          onChanged: (v) => _draft.name = v,
          decoration: const InputDecoration(labelText: "Nama lengkap", prefixIcon: Icon(Icons.person_outline)),
        ),
        const SizedBox(height: 16),
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
          validator: Validators.newPassword,
          textInputAction: TextInputAction.next,
          onChanged: (_) => setState(() {}),
        ),
        PasswordStrengthBar(password: _passwordCtrl.text),
        const SizedBox(height: 4),
        Text(
          "Minimal 8 karakter, dengan huruf besar, huruf kecil, dan angka.",
          style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        PasswordField(
          controller: _confirmCtrl,
          label: "Konfirmasi password",
          validator: Validators.confirmPassword(() => _passwordCtrl.text),
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 16),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: _acceptedTerms,
          onChanged: (v) => setState(() {
            _acceptedTerms = v ?? false;
            if (_acceptedTerms) _termsError = false;
          }),
          title: const Text("Saya menyetujui Syarat & Ketentuan serta Kebijakan Privasi MoveUp"),
          subtitle: _termsError
              ? Text("Anda harus menyetujui untuk melanjutkan", style: TextStyle(color: scheme.error))
              : null,
        ),
        const SizedBox(height: 16),
        GoogleSignInButton(enabled: !_loading),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Sudah punya akun?", style: TextStyle(color: scheme.onSurfaceVariant)),
            TextButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
              child: const Text("Masuk", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }
}
