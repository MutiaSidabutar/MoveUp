import 'package:flutter/material.dart';
import 'package:moveup/services/auth_service.dart';
import 'package:moveup/services/profile_service.dart';
import 'package:moveup/theme.dart';
import 'package:moveup/utils/validators.dart';
import 'package:moveup/widgets.dart';
import 'package:moveup/widgets/profile_form.dart';

// Muncul kalau akun sudah ada tetapi profilnya belum tersimpan (misalnya koneksi putus saat mendaftar)
class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _draft = ProfileDraft(name: AuthService.currentUser?.displayName ?? '');
  bool _saving = false;
  bool _acceptedTerms = false;
  bool _termsError = false;

  Future<void> _save() async {
    final valid = _formKey.currentState!.validate();
    setState(() => _termsError = !_acceptedTerms);
    if (!valid || !_acceptedTerms) return;
    final user = AuthService.currentUser!;
    setState(() => _saving = true);
    try {
      await ProfileService.instance.save(_draft.toProfile(uid: user.uid, email: user.email!), isNew: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal menyimpan profil. Coba lagi.")));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [TextButton(onPressed: AuthService.signOut, child: const Text("Keluar"))],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text("LENGKAPI PROFIL", style: AppTheme.display(36, letterSpacing: 1.5)),
            const SizedBox(height: 4),
            Text(
              "Satu langkah lagi sebelum mulai bergerak.",
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 28),
            TextFormField(
              initialValue: _draft.name,
              textCapitalization: TextCapitalization.words,
              validator: Validators.name,
              onChanged: (v) => _draft.name = v,
              decoration: const InputDecoration(labelText: "Nama lengkap", prefixIcon: Icon(Icons.person_outline)),
            ),
            const SizedBox(height: 20),
            BodyInfoFields(draft: _draft, onChanged: () => setState(() {})),
            const SizedBox(height: 28),
            PreferenceFields(draft: _draft, onChanged: () => setState(() {})),
            const SizedBox(height: 16),
            // Pengguna Google melewati langkah pertama pendaftaran, jadi persetujuan diminta di sini
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
                  ? Text("Anda harus menyetujui untuk melanjutkan",
                      style: TextStyle(color: Theme.of(context).colorScheme.error))
                  : null,
            ),
            const SizedBox(height: 16),
            PrimaryButton(text: _saving ? "Menyimpan…" : "Simpan Profil", onPressed: _saving ? () {} : _save),
          ],
        ),
      ),
    );
  }
}
