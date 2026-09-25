import 'package:flutter/material.dart';
import 'package:moveup/services/auth_service.dart';
import 'package:moveup/utils/validators.dart';
import 'package:moveup/widgets.dart';
import 'package:moveup/widgets/profile_form.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await AuthService.changePassword(_currentCtrl.text, _newCtrl.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password berhasil diganti")));
      Navigator.pop(context);
    } on AuthFailure catch (e) {
      if (!mounted) return;
      setState(() => _error = e.code == 'invalid-credential' || e.code == 'wrong-password'
          ? 'Password saat ini salah.'
          : e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthService.hasPasswordLogin) {
      return Scaffold(
        appBar: AppBar(title: const Text("KEAMANAN AKUN")),
        body: const Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            "Anda masuk dengan akun Google, jadi password dan keamanan akun diatur melalui akun Google Anda.",
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text("KEAMANAN AKUN")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SectionLabel("Ganti password"),
            PasswordField(controller: _currentCtrl, label: "Password saat ini", validator: Validators.requiredPassword),
            const SizedBox(height: 16),
            PasswordField(
              controller: _newCtrl,
              label: "Password baru",
              validator: (v) => v == _currentCtrl.text ? "Password baru harus berbeda" : Validators.newPassword(v),
              onChanged: (_) => setState(() {}),
            ),
            PasswordStrengthBar(password: _newCtrl.text),
            const SizedBox(height: 16),
            PasswordField(
              controller: _confirmCtrl,
              label: "Konfirmasi password baru",
              validator: Validators.confirmPassword(() => _newCtrl.text),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w600)),
            ],
            const SizedBox(height: 32),
            PrimaryButton(text: _saving ? "Menyimpan…" : "Ganti Password", onPressed: _saving ? () {} : _save),
          ],
        ),
      ),
    );
  }
}
