import 'package:flutter/material.dart';
import 'package:moveup/models/activity.dart';
import 'package:moveup/services/activity_store.dart';
import 'package:moveup/utils/format.dart';
import 'package:moveup/utils/validators.dart';
import 'package:moveup/widgets.dart';

// Input manual untuk aktivitas tanpa GPS (misalnya treadmill atau lupa merekam),
// sekaligus form edit kalau [activity] diisi
class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({super.key, this.activity});

  final Activity? activity;

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  late final Activity? _initial = widget.activity;
  late final _titleCtrl = TextEditingController(text: _initial?.title);
  late final _descCtrl = TextEditingController(text: _initial?.description);
  late final _hoursCtrl = TextEditingController(text: _initial == null ? '' : '${_initial.movingSeconds ~/ 3600}');
  late final _minutesCtrl =
      TextEditingController(text: _initial == null ? '' : '${(_initial.movingSeconds % 3600 / 60).round()}');
  late final _distanceCtrl = TextEditingController(
    text: _initial == null || _initial.distanceMeters == 0 ? '' : formatKm(_initial.distanceMeters),
  );
  late SportType _type = _initial?.type ?? SportType.run;
  late DateTime _start = _initial?.startTime ?? DateTime.now();
  String? _dateError;
  bool _saving = false;

  bool get _editing => _initial != null;

  // Durasi dan jarak rekaman GPS berasal dari rute, jadi tidak boleh diubah manual
  bool get _fromGps => _initial?.points.isNotEmpty ?? false;

  @override
  void dispose() {
    for (final c in [_titleCtrl, _descCtrl, _hoursCtrl, _minutesCtrl, _distanceCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_start));
    if (time == null) return;
    setState(() {
      _start = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      _dateError = null;
    });
  }

  int get _seconds =>
      (int.tryParse(_hoursCtrl.text.trim()) ?? 0) * 3600 + (int.tryParse(_minutesCtrl.text.trim()) ?? 0) * 60;

  Future<void> _save() async {
    final formValid = _formKey.currentState!.validate();
    setState(() => _dateError = _start.isAfter(DateTime.now()) ? 'Waktu mulai tidak boleh di masa depan' : null);
    if (!formValid || _dateError != null) return;

    setState(() => _saving = true);
    final title = _titleCtrl.text.trim();
    final activity = Activity(
      id: _initial?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: _type,
      title: title.isEmpty ? defaultTitle(_type, _start) : title,
      description: _descCtrl.text.trim(),
      startTime: _start,
      movingSeconds: _fromGps ? _initial!.movingSeconds : _seconds,
      distanceMeters: _fromGps ? _initial!.distanceMeters : (Validators.parseNumber(_distanceCtrl.text) ?? 0) * 1000,
      points: _initial?.points ?? const [],
    );
    final store = ActivityStore.instance;
    await (_editing ? store.update(activity) : store.add(activity));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(_editing ? "Aktivitas diperbarui" : "Aktivitas ditambahkan")));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? "Edit Aktivitas" : "Aktivitas Manual"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            const Text("Jenis Olahraga", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final type in SportType.values)
                  ChoiceChip(
                    avatar: Icon(type.icon, size: 18),
                    label: Text(type.label),
                    selected: type == _type,
                    onSelected: (_) => setState(() => _type = type),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: "Judul", hintText: defaultTitle(_type, _start)),
              validator: Validators.title(label: "Judul", max: 60, required: false),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event),
              title: Text("${formatDate(_start)} pukul ${formatTime(_start)}"),
              subtitle: _dateError == null
                  ? null
                  : Text(_dateError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              trailing: const Icon(Icons.edit, size: 18),
              onTap: _pickDateTime,
            ),
            const SizedBox(height: 12),
            if (_fromGps)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  "Durasi dan jarak berasal dari rekaman GPS sehingga tidak dapat diubah.",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _hoursCtrl,
                    enabled: !_fromGps,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Jam"),
                    validator: Validators.wholeNumber(label: "Jam", max: 23),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _minutesCtrl,
                    enabled: !_fromGps,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Menit"),
                    validator: (v) {
                      final error = Validators.wholeNumber(label: "Menit", max: 59)(v);
                      if (error != null || _fromGps) return error;
                      return _seconds <= 0 ? "Isi durasi aktivitas" : null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _distanceCtrl,
              enabled: !_fromGps,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: "Jarak (km)", hintText: "Kosongkan kalau tidak ada"),
              validator: _fromGps ? null : Validators.positiveNumber(label: "Jarak", max: 500, unit: "km", required: false),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              maxLength: 300,
              decoration: const InputDecoration(hintText: "Catatan (opsional)"),
            ),
            const SizedBox(height: 24),
            _saving
                ? const Center(child: CircularProgressIndicator())
                : PrimaryButton(
                    text: _editing ? "Simpan Perubahan" : "Simpan Aktivitas",
                    icon: Icons.check,
                    onPressed: _save,
                  ),
          ],
        ),
      ),
    );
  }
}
