import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:moveup/models/user_profile.dart';

class ProfileService extends ChangeNotifier {
  ProfileService._();

  static final instance = ProfileService._();

  // Dipakai untuk kalori kalau profil belum dimuat
  static const defaultWeightKg = 65.0;

  UserProfile? _profile;

  UserProfile? get profile => _profile;

  double get weightKg => _profile?.weightKg ?? defaultWeightKg;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      FirebaseFirestore.instance.collection('users').doc(uid);

  // Mengembalikan null kalau pengguna belum melengkapi profil
  Future<UserProfile?> load(String uid) async {
    final snap = await _doc(uid).get();
    final data = snap.data();
    _profile = data == null ? null : UserProfile.fromMap(uid, data);
    notifyListeners();
    return _profile;
  }

  Future<void> save(UserProfile profile, {bool isNew = false}) async {
    await _doc(profile.uid).set({
      ...profile.toMap(),
      if (isNew) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    _profile = profile;
    notifyListeners();
  }

  void clear() {
    _profile = null;
    notifyListeners();
  }
}
