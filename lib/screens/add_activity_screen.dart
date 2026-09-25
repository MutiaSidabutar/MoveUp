import 'package:flutter/material.dart';
import 'package:moveup/models/activity.dart';
import 'package:moveup/services/activity_store.dart';
import 'package:moveup/utils/format.dart';
import 'package:moveup/widgets.dart';

// Input manual untuk aktivitas tanpa GPS (misalnya treadmill atau lupa merekam)
class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({super.key});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _hoursCtrl = TextEditingController();
  final _minutesCtrl = TextEditingController();
  final _distanceCtrl = TextEditingController();
  SportType _type = SportType.run;
  DateTime _start = DateTime.now();

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
    setState(() => _start = DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  Future<void> _save() async {
    final hours = int.tryParse(_hoursCtrl.text) ?? 0;
    final minutes = int.tryParse(_minutesCtrl.text) ?? 0;
    final seconds = hours * 3600 + minutes * 60;
    final km = double.tryParse(_distanceCtrl.text.replaceAll(',', '.')) ?? 0;
    if (seconds <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Isi durasi aktivitas terlebih dahulu")));
      return;
    }

    final title = _titleCtrl.text.trim();
    await ActivityStore.instance.add(Activity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _type,
      title: title.isEmpty ? defaultTitle(_type, _start) : title,
      description: _descCtrl.text.trim(),
      startTime: _start,
      movingSeconds: seconds,
      distanceMeters: km * 1000,
    ));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Aktivitas Manual"), backgroundColor: Colors.transparent, elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
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
                  onSelected: (_) => setState(() => _type = type),
                ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _titleCtrl,
            decoration: InputDecoration(labelText: "Judul", hintText: defaultTitle(_type, _start)),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event),
            title: Text("${formatDate(_start)} pukul ${formatTime(_start)}"),
            trailing: const Icon(Icons.edit, size: 18),
            onTap: _pickDateTime,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _hoursCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Jam"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _minutesCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Menit"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _distanceCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: "Jarak (km)"),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descCtrl,
            maxLines: 3,
            decoration: const InputDecoration(hintText: "Catatan (opsional)"),
          ),
          const SizedBox(height: 32),
          PrimaryButton(text: "Simpan Aktivitas", icon: Icons.check, onPressed: _save),
        ],
      ),
    );
  }
}
