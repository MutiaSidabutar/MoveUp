import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

// Daftar data milik satu akun yang disimpan sebagai file JSON di penyimpanan aplikasi.
// Akun yang baru pertama kali dibuka langsung diisi data simulasi dari [seed].
abstract class JsonListStore<T> extends ChangeNotifier {
  JsonListStore(this._fileName);

  final String _fileName;
  final List<T> _items = [];
  String? _uid;

  List<T> get items => List.unmodifiable(_items);

  String idOf(T item);
  Map<String, dynamic> encode(T item);
  T decode(Map<String, dynamic> json);
  List<T> seed();

  // Urutan tampilan; null berarti mengikuti urutan penambahan
  Comparator<T>? get order => null;

  // Dipanggil sebelum file dibaca, misalnya untuk memindahkan file versi lama
  Future<void> beforeLoad(File file) async {}

  T? byId(String id) {
    for (final item in _items) {
      if (idOf(item) == id) return item;
    }
    return null;
  }

  Future<File> fileFor(String uid) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/${_fileName}_$uid.json');
  }

  Future<void> loadFor(String uid) async {
    if (_uid == uid) return;
    _uid = uid;
    _items.clear();
    notifyListeners();
    try {
      final file = await fileFor(uid);
      await beforeLoad(file);
      final exists = await file.exists();
      final loaded = exists
          ? (jsonDecode(await file.readAsString()) as List<dynamic>)
              .map((e) => decode(e as Map<String, dynamic>))
              .toList()
          : seed();
      // Pengguna bisa saja keluar selagi file dibaca
      if (_uid != uid) return;
      _items
        ..clear()
        ..addAll(loaded);
      _sort();
      notifyListeners();
      if (!exists) await _save();
    } catch (e) {
      debugPrint('Gagal memuat $_fileName: $e');
    }
  }

  void clear() {
    _uid = null;
    _items.clear();
    notifyListeners();
  }

  Future<void> add(T item) async {
    _items.add(item);
    await _changed();
  }

  Future<void> update(T item) async {
    final i = _items.indexWhere((e) => idOf(e) == idOf(item));
    if (i < 0) return;
    _items[i] = item;
    await _changed();
  }

  Future<void> remove(String id) async {
    _items.removeWhere((e) => idOf(e) == id);
    await _changed();
  }

  Future<void> replaceAll(List<T> items) async {
    _items
      ..clear()
      ..addAll(items);
    await _changed();
  }

  Future<void> resetToSample() => replaceAll(seed());

  Future<void> _changed() async {
    _sort();
    notifyListeners();
    await _save();
  }

  void _sort() {
    final compare = order;
    if (compare != null) _items.sort(compare);
  }

  Future<void> _save() async {
    final uid = _uid;
    if (uid == null) return;
    final file = await fileFor(uid);
    // Tulis ke file sementara dulu supaya data tidak rusak kalau aplikasi mati di tengah penulisan
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(jsonEncode(_items.map(encode).toList()));
    await tmp.rename(file.path);
  }
}
