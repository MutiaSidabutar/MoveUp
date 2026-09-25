import 'package:moveup/models/user_profile.dart';

// Validasi form autentikasi dan profil; mengembalikan pesan error atau null kalau valid
class Validators {
  static const minAge = 13;
  static const maxAge = 100;

  static final _email = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');
  static final _name = RegExp(r"^[A-Za-zÀ-ÿ .'-]+$");

  static String? name(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Nama wajib diisi';
    if (value.length < 3) return 'Nama minimal 3 huruf';
    if (value.length > 50) return 'Nama maksimal 50 huruf';
    if (!_name.hasMatch(value)) return 'Nama hanya boleh berisi huruf';
    return null;
  }

  static String? email(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Email wajib diisi';
    if (!_email.hasMatch(value)) return 'Format email tidak valid';
    return null;
  }

  // Untuk login cukup tidak kosong; aturan kekuatan hanya berlaku saat membuat password baru
  static String? requiredPassword(String? v) => (v == null || v.isEmpty) ? 'Password wajib diisi' : null;

  static String? newPassword(String? v) {
    final value = v ?? '';
    if (value.length < 8) return 'Password minimal 8 karakter';
    if (!value.contains(RegExp(r'[A-Z]'))) return 'Tambahkan minimal 1 huruf besar';
    if (!value.contains(RegExp(r'[a-z]'))) return 'Tambahkan minimal 1 huruf kecil';
    if (!value.contains(RegExp(r'[0-9]'))) return 'Tambahkan minimal 1 angka';
    return null;
  }

  static String? Function(String?) confirmPassword(String Function() original) =>
      (v) => v != original() ? 'Konfirmasi password tidak sama' : null;

  // 0 = kosong, 1 = lemah, 2 = sedang, 3 = kuat
  static int passwordStrength(String value) {
    if (value.isEmpty) return 0;
    var score = 0;
    if (value.length >= 8) score++;
    if (value.length >= 12) score++;
    if (value.contains(RegExp(r'[A-Z]')) && value.contains(RegExp(r'[a-z]'))) score++;
    if (value.contains(RegExp(r'[0-9]'))) score++;
    if (value.contains(RegExp(r'[^A-Za-z0-9]'))) score++;
    return score <= 2 ? 1 : (score <= 3 ? 2 : 3);
  }

  static String? birthDate(DateTime? v) {
    if (v == null) return 'Tanggal lahir wajib diisi';
    final age = ageOn(v, DateTime.now());
    if (age < minAge) return 'Usia minimal $minAge tahun';
    if (age > maxAge) return 'Periksa kembali tanggal lahir';
    return null;
  }

  static String? weight(String? v) => _range(v, 'Berat badan', 20, 300, 'kg');

  static String? height(String? v) => _range(v, 'Tinggi badan', 100, 250, 'cm');

  static double? parseNumber(String? v) => double.tryParse((v ?? '').trim().replaceAll(',', '.'));

  static String? _range(String? v, String label, double min, double max, String unit) {
    if (v == null || v.trim().isEmpty) return '$label wajib diisi';
    final n = parseNumber(v);
    if (n == null) return '$label harus berupa angka';
    if (n < min || n > max) return '$label harus ${min.round()}–${max.round()} $unit';
    return null;
  }
}
