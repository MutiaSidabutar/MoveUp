import 'package:flutter_test/flutter_test.dart';
import 'package:moveup/models/activity.dart';
import 'package:moveup/models/user_profile.dart';
import 'package:moveup/services/auth_service.dart';
import 'package:moveup/utils/validators.dart';

void main() {
  group('validasi akun', () {
    test('email', () {
      expect(Validators.email('alex@moveup.id'), isNull);
      expect(Validators.email(' alex.r+run@mail.co.id '), isNull);
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('alex@'), isNotNull);
      expect(Validators.email('alex.moveup.id'), isNotNull);
    });

    test('nama', () {
      expect(Validators.name('Alex Rahman'), isNull);
      expect(Validators.name("Siti Nur'aini"), isNull);
      expect(Validators.name('Al'), isNotNull);
      expect(Validators.name('Alex123'), isNotNull);
    });

    test('password baru wajib kuat', () {
      expect(Validators.newPassword('Lari2026'), isNull);
      expect(Validators.newPassword('Lari26'), contains('8 karakter'));
      expect(Validators.newPassword('lari2026'), contains('huruf besar'));
      expect(Validators.newPassword('LARI2026'), contains('huruf kecil'));
      expect(Validators.newPassword('LariPagi'), contains('angka'));
    });

    test('konfirmasi password', () {
      final confirm = Validators.confirmPassword(() => 'Lari2026');
      expect(confirm('Lari2026'), isNull);
      expect(confirm('Lari2025'), isNotNull);
    });

    test('kekuatan password', () {
      expect(Validators.passwordStrength(''), 0);
      expect(Validators.passwordStrength('abc'), 1);
      expect(Validators.passwordStrength('Lari2026'), 2);
      expect(Validators.passwordStrength('LariPagi#2026!'), 3);
    });
  });

  group('validasi profil', () {
    test('usia 13–100 tahun', () {
      final now = DateTime.now();
      expect(Validators.birthDate(null), isNotNull);
      expect(Validators.birthDate(DateTime(now.year - 20, 1, 1)), isNull);
      expect(Validators.birthDate(DateTime(now.year - 10, 1, 1)), contains('13'));
      expect(Validators.birthDate(DateTime(now.year - 120, 1, 1)), isNotNull);
    });

    test('usia dihitung sampai hari ulang tahun', () {
      expect(ageOn(DateTime(2000, 9, 26), DateTime(2026, 9, 25)), 25);
      expect(ageOn(DateTime(2000, 9, 25), DateTime(2026, 9, 25)), 26);
    });

    test('berat dan tinggi badan dalam rentang wajar', () {
      expect(Validators.weight('65'), isNull);
      expect(Validators.weight('65,5'), isNull);
      expect(Validators.weight('10'), isNotNull);
      expect(Validators.weight('abc'), contains('angka'));
      expect(Validators.height('170'), isNull);
      expect(Validators.height('90'), isNotNull);
    });
  });

  test('profil tersimpan dan terbaca ulang tanpa berubah', () {
    final profile = UserProfile(
      uid: 'u1',
      name: 'Alex Rahman',
      email: 'alex@moveup.id',
      gender: Gender.male,
      birthDate: DateTime(2000, 5, 17),
      weightKg: 65,
      heightCm: 170,
      level: FitnessLevel.intermediate,
      favoriteSports: const [SportType.run, SportType.ride],
    );
    final restored = UserProfile.fromMap('u1', profile.toMap());

    expect(restored.name, profile.name);
    expect(restored.gender, Gender.male);
    expect(restored.birthDate, profile.birthDate);
    expect(restored.level, FitnessLevel.intermediate);
    expect(restored.favoriteSports, [SportType.run, SportType.ride]);
    expect(restored.initials, 'AR');
    expect(restored.bmi, closeTo(22.49, 0.01));
    expect(restored.bmiCategory, 'Normal');
  });

  test('pesan error Firebase diterjemahkan', () {
    expect(AuthService.messageFor('invalid-credential'), 'Email atau password salah.');
    expect(AuthService.messageFor('email-already-in-use'), contains('sudah terdaftar'));
    expect(AuthService.messageFor('network-request-failed'), contains('internet'));
  });
}
