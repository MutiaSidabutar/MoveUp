import 'package:flutter/material.dart';
import 'package:moveup/models/activity.dart';
import 'package:moveup/services/photo_store.dart';
import 'package:moveup/theme.dart';
import 'package:moveup/widgets.dart';
import 'package:moveup/widgets/route_map.dart';

// Satu foto dari folder aplikasi; kalau filenya hilang tampil ikon pengganti
class ActivityPhoto extends StatelessWidget {
  const ActivityPhoto(this.name, {super.key, this.fit = BoxFit.cover});

  final String name;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final file = PhotoStore.fileOf(name);
    final placeholder = ColoredBox(
      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
      child: Center(child: Icon(Icons.broken_image_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant)),
    );
    if (file == null) return placeholder;
    return Image.file(
      file,
      fit: fit,
      // Thumbnail cukup dibaca dalam ukuran kecil supaya daftar tetap ringan
      cacheWidth: fit == BoxFit.cover ? 600 : null,
      errorBuilder: (_, _, _) => placeholder,
    );
  }
}

// Isian foto di form aktivitas: deretan thumbnail, tombol tambah (kamera/galeri), dan hapus per foto
class PhotoPickerField extends StatelessWidget {
  const PhotoPickerField({super.key, required this.photos, required this.onChanged});

  final List<String> photos;
  final ValueChanged<List<String>> onChanged;

  Future<void> _add(BuildContext context) async {
    final camera = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text("Ambil dari kamera"),
              onTap: () => Navigator.pop(context, true),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text("Pilih dari galeri"),
              onTap: () => Navigator.pop(context, false),
            ),
          ],
        ),
      ),
    );
    if (camera == null || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final added = await PhotoStore.pick(camera: camera, limit: PhotoStore.maxPerActivity - photos.length);
      if (added.isNotEmpty) onChanged([...photos, ...added]);
    } catch (_) {
      messenger.error(camera ? "Kamera tidak bisa dibuka." : "Foto tidak bisa dibuka dari galeri.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final full = photos.length >= PhotoStore.maxPerActivity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel("Foto (${photos.length}/${PhotoStore.maxPerActivity})"),
        SizedBox(
          height: 96,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final (i, name) in photos.indexed)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.control),
                        child: SizedBox.square(dimension: 96, child: ActivityPhoto(name)),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Material(
                          color: Colors.black54,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => onChanged([...photos]..removeAt(i)),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(Icons.close, size: 16, color: Colors.white, semanticLabel: "Hapus foto"),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (!full)
                InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.control),
                  onTap: () => _add(context),
                  child: Container(
                    width: 96,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.control),
                      border: Border.all(color: scheme.outline, width: 1.5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined, color: scheme.onSurfaceVariant),
                        const SizedBox(height: AppSpacing.xs),
                        Text("Tambah", style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// Peta rute dan foto aktivitas yang bisa digeser, dengan penanda posisi "1/3".
// Mengetuk foto membuka tampilan layar penuh.
class ActivityMedia extends StatefulWidget {
  const ActivityMedia({super.key, required this.activity, this.height = 180, this.showMap = true});

  final Activity activity;
  final double height;
  final bool showMap;

  static bool hasMedia(Activity a) => a.hasRoute || a.photos.isNotEmpty;

  @override
  State<ActivityMedia> createState() => _ActivityMediaState();
}

class _ActivityMediaState extends State<ActivityMedia> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final a = widget.activity;
    final withMap = widget.showMap && a.hasRoute;
    final pages = <Widget>[
      // AbsorbPointer supaya geseran pindah halaman, bukan menggeser peta
      if (withMap) AbsorbPointer(child: RouteMap(points: a.points)),
      for (final (i, name) in a.photos.indexed)
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PhotoViewerScreen(photos: a.photos, initialIndex: i)),
          ),
          child: ActivityPhoto(name),
        ),
    ];
    if (pages.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          PageView(onPageChanged: (i) => setState(() => _page = i), children: pages),
          if (pages.length > 1)
            Positioned(
              top: AppSpacing.sm,
              right: AppSpacing.sm,
              child: _Badge("${_page + 1}/${pages.length}"),
            ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(AppRadius.sheet)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

// Thumbnail persegi untuk daftar Riwayat: foto pertama, lalu peta rute, lalu ikon olahraga
class ActivityThumbnail extends StatelessWidget {
  const ActivityThumbnail({super.key, required this.activity, this.size = 84});

  final Activity activity;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final Widget child;
    if (activity.photos.isNotEmpty) {
      child = ActivityPhoto(activity.photos.first);
    } else if (activity.hasRoute) {
      child = IgnorePointer(child: RouteMap(points: activity.points, compact: true));
    } else {
      child = ColoredBox(
        color: scheme.primary.withValues(alpha: 0.08),
        child: Icon(activity.type.icon, color: scheme.primary, size: size * 0.4),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.control),
      child: SizedBox.square(dimension: size, child: child),
    );
  }
}

// Foto layar penuh; bisa digeser antar foto dan dicubit untuk zoom
class PhotoViewerScreen extends StatefulWidget {
  const PhotoViewerScreen({super.key, required this.photos, this.initialIndex = 0});

  final List<String> photos;
  final int initialIndex;

  @override
  State<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<PhotoViewerScreen> {
  late int _index = widget.initialIndex;
  late final _controller = PageController(initialPage: widget.initialIndex);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text("${_index + 1} dari ${widget.photos.length}", style: const TextStyle(color: Colors.white)),
      ),
      body: PageView(
        controller: _controller,
        onPageChanged: (i) => setState(() => _index = i),
        children: [
          for (final name in widget.photos)
            InteractiveViewer(minScale: 1, maxScale: 4, child: Center(child: ActivityPhoto(name, fit: BoxFit.contain))),
        ],
      ),
    );
  }
}
