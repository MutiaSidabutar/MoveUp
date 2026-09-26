import 'package:flutter/material.dart';
import 'package:moveup/models/activity.dart';
import 'package:moveup/models/goal.dart';
import 'package:moveup/models/reminder.dart';
import 'package:moveup/services/goal_store.dart';
import 'package:moveup/services/reminder_store.dart';
import 'package:moveup/utils/validators.dart';
import 'package:moveup/widgets.dart';

// Form tambah pengingat, sekaligus edit kalau [reminder] diisi.
// [initialGoal] dipakai saat dibuka dari detail target supaya relasinya langsung terisi.
class ReminderFormScreen extends StatefulWidget {
  const ReminderFormScreen({super.key, this.reminder, this.initialGoal});

  final Reminder? reminder;
  final Goal? initialGoal;

  @override
  State<ReminderFormScreen> createState() => _ReminderFormScreenState();
}

class _ReminderFormScreenState extends State<ReminderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final Reminder? _initial = widget.reminder;
  late final _titleCtrl = TextEditingController(text: _initial?.title ?? widget.initialGoal?.title);
  late SportType _sport = _initial?.sportType ?? widget.initialGoal?.sportType ?? SportType.run;
  late final Set<int> _days = {...?_initial?.days};
  late TimeOfDay _time = _initial?.time ?? const TimeOfDay(hour: 6, minute: 0);
  late bool _enabled = _initial?.enabled ?? true;
  late String? _goalId = _initial?.goalId ?? widget.initialGoal?.id;
  bool _saving = false;

  bool get _editing => _initial != null;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final reminder = Reminder(
      id: _initial?.id ?? 'rem-${DateTime.now().millisecondsSinceEpoch}',
      title: _titleCtrl.text.trim(),
      sportTypeId: _sport.id,
      days: _days.toList()..sort(),
      hour: _time.hour,
      minute: _time.minute,
      enabled: _enabled,
      goalId: _goalId,
    );
    final store = ReminderStore.instance;
    await (_editing ? store.update(reminder) : store.add(reminder));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(_editing ? "Reminder diperbarui" : "Reminder ditambahkan")));
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    final delete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus reminder?"),
        content: Text("\"${_initial!.title}\" akan dihapus."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (delete != true) return;
    await ReminderStore.instance.remove(_initial!.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Reminder dihapus")));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final goals = GoalStore.instance.goals;
    // Target yang dirujuk bisa saja sudah dihapus
    if (_goalId != null && goals.every((g) => g.id != _goalId)) _goalId = null;

    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? "Edit Reminder" : "Reminder Baru"),
        actions: [
          if (_editing) IconButton(icon: const Icon(Icons.delete_outline), tooltip: "Hapus", onPressed: _delete),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: "Nama Aktivitas", hintText: "Misal: Lari Pagi"),
              validator: Validators.title(label: "Nama aktivitas", max: 30),
            ),
            const SizedBox(height: 20),
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
                    selected: type == _sport,
                    onSelected: (_) => setState(() => _sport = type),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            FormField<Set<int>>(
              validator: (_) => _days.isEmpty ? "Pilih minimal satu hari" : null,
              builder: (field) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(child: Text("Hari", style: TextStyle(fontWeight: FontWeight.bold))),
                      TextButton(
                        onPressed: () {
                          setState(() => _days.length == 7 ? _days.clear() : _days.addAll([1, 2, 3, 4, 5, 6, 7]));
                          field.didChange(_days);
                        },
                        child: Text(_days.length == 7 ? "Kosongkan" : "Setiap hari"),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (var d = 1; d <= 7; d++)
                        FilterChip(
                          label: Text(dayShortNames[d - 1]),
                          selected: _days.contains(d),
                          showCheckmark: false,
                          onSelected: (on) {
                            setState(() => on ? _days.add(d) : _days.remove(d));
                            field.didChange(_days);
                          },
                        ),
                    ],
                  ),
                  if (field.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        field.errorText!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule),
              title: const Text("Waktu"),
              trailing: Text(_time.format(context), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              onTap: _pickTime,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _goalId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: "Terkait dengan Target (opsional)"),
              items: [
                const DropdownMenuItem(value: null, child: Text("Tidak terkait")),
                for (final g in goals)
                  DropdownMenuItem(value: g.id, child: Text(g.title, overflow: TextOverflow.ellipsis)),
              ],
              onChanged: (v) => setState(() => _goalId = v),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Aktif"),
              subtitle: const Text("Nonaktifkan untuk menjeda tanpa menghapus"),
              value: _enabled,
              onChanged: (v) => setState(() => _enabled = v),
            ),
            const SizedBox(height: 24),
            _saving
                ? const Center(child: CircularProgressIndicator())
                : PrimaryButton(
                    text: _editing ? "Simpan Perubahan" : "Simpan Reminder",
                    icon: Icons.check,
                    onPressed: _save,
                  ),
          ],
        ),
      ),
    );
  }
}
