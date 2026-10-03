import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

// Foto aktivitas disalin ke folder aplikasi supaya tetap ada walau foto aslinya dihapus dari galeri.
// Activity hanya menyimpan nama file; lokasi folder ditentukan saat aplikasi dibuka.
class PhotoStore {
  PhotoStore._();

  static const maxPerActivity = 6;

  static Directory? _dir;

  static Future<void> init() async {
    try {
      final docs = await getApplicationDocumentsDirectory();
      _dir = await Directory('${docs.path}/photos').create(recursive: true);
    } catch (e) {
      debugPrint('Folder foto tidak tersedia: $e');
    }
  }

  // null kalau folder belum siap atau file sudah tidak ada
  static File? fileOf(String name) {
    final dir = _dir;
    if (dir == null) return null;
    final file = File('${dir.path}/$name');
    return file.existsSync() ? file : null;
  }

  static final _picker = ImagePicker();

  // Mengembalikan nama file foto yang berhasil disalin; kosong kalau pengguna membatalkan
  static Future<List<String>> pick({required bool camera, int limit = maxPerActivity}) async {
    if (limit <= 0 || _dir == null) return [];
    // Ukuran dibatasi supaya penyimpanan tidak cepat penuh
    const maxSide = 1600.0;
    final picked = camera
        ? [?await _picker.pickImage(source: ImageSource.camera, maxWidth: maxSide, maxHeight: maxSide, imageQuality: 85)]
        : await _picker.pickMultiImage(maxWidth: maxSide, maxHeight: maxSide, imageQuality: 85, limit: limit > 1 ? limit : null);
    final names = <String>[];
    for (final x in picked.take(limit)) {
      final ext = x.path.contains('.') ? x.path.substring(x.path.lastIndexOf('.')) : '.jpg';
      final name = 'img_${DateTime.now().microsecondsSinceEpoch}$ext';
      await File(x.path).copy('${_dir!.path}/$name');
      names.add(name);
    }
    return names;
  }

  static Future<void> deleteAll(Iterable<String> names) async {
    for (final name in names) {
      try {
        await fileOf(name)?.delete();
      } catch (e) {
        debugPrint('Gagal menghapus foto $name: $e');
      }
    }
  }
}
