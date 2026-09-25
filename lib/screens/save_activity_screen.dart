import 'package:flutter/material.dart';
import 'package:moveup/theme.dart';
import 'package:moveup/models/activity.dart';
import 'package:moveup/screens/activity_detail_screen.dart';
import 'package:moveup/services/activity_store.dart';
import 'package:moveup/utils/format.dart';
import 'package:moveup/widgets.dart';
import 'package:moveup/widgets/route_map.dart';

// Layar setelah menekan "Selesai": beri judul dan deskripsi sebelum disimpan
class SaveActivityScreen extends StatefulWidget {
  const SaveActivityScreen({super.key, required this.draft});

  final Activity draft;

  @override
  State<SaveActivityScreen> createState() => _SaveActivityScreenState();
}

class _SaveActivityScreenState extends State<SaveActivityScreen> {
  late final _titleCtrl = TextEditingController(text: widget.draft.title);
  final _descCtrl = TextEditingController();
  late SportType _type = widget.draft.type;
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _changeType(SportType type) {
    // Ikut ganti judul otomatis, kecuali pengguna sudah menulis judul sendiri
    if (_titleCtrl.text == defaultTitle(_type, widget.draft.startTime)) {
      _titleCtrl.text = defaultTitle(type, widget.draft.startTime);
    }
    setState(() => _type = type);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final d = widget.draft;
    final title = _titleCtrl.text.trim();
    final activity = Activity(
      id: d.id,
      type: _type,
      title: title.isEmpty ? defaultTitle(_type, d.startTime) : title,
      description: _descCtrl.text.trim(),
      startTime: d.startTime,
      movingSeconds: d.movingSeconds,
      distanceMeters: d.distanceMeters,
      points: d.points,
    );
    await ActivityStore.instance.add(activity);
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ActivityDetailScreen(activity: activity)));
  }

  Future<void> _discard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Buang aktivitas?"),
        content: const Text("Aktivitas ini tidak akan disimpan."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Buang", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (discard == true && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.draft;
    final preview = Activity(
      id: d.id,
      type: _type,
      title: d.title,
      startTime: d.startTime,
      movingSeconds: d.movingSeconds,
      distanceMeters: d.distanceMeters,
    );
    final (paceLabel, paceValue) = paceOrSpeed(preview);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_saving) _discard();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Simpan Aktivitas"), backgroundColor: Colors.transparent, elevation: 0),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: "Judul")),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(hintText: "Bagaimana aktivitasnya? Ceritakan di sini"),
            ),
            const SizedBox(height: 24),
            const Text("Jenis Olahraga", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final type in SportType.values)
                  ChoiceChip(
                    avatar: Icon(type.icon, size: 18),
                    label: Text(type.label),
                    selected: type == _type,
                    onSelected: (_) => _changeType(type),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _stat("Jarak", "${formatKm(d.distanceMeters)} km"),
                        _stat(paceLabel, paceValue),
                        _stat("Waktu", formatDuration(d.movingSeconds)),
                      ],
                    ),
                  ),
                  if (d.points.isNotEmpty)
                    SizedBox(height: 160, child: AbsorbPointer(child: RouteMap(points: d.points))),
                ],
              ),
            ),
            const SizedBox(height: 32),
            PrimaryButton(text: _saving ? "Menyimpan…" : "Simpan Aktivitas", onPressed: _saving ? () {} : _save),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _saving ? null : _discard,
              child: const Text("Buang aktivitas", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(value, style: AppTheme.display(22)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
