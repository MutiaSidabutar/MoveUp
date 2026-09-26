import 'package:flutter/material.dart';
import 'package:moveup/models/activity.dart';
import 'package:moveup/models/goal.dart';
import 'package:moveup/services/goal_store.dart';
import 'package:moveup/utils/validators.dart';
import 'package:moveup/widgets.dart';

// Form tambah target, sekaligus edit kalau [goal] diisi
class GoalFormScreen extends StatefulWidget {
  const GoalFormScreen({super.key, this.goal});

  final Goal? goal;

  @override
  State<GoalFormScreen> createState() => _GoalFormScreenState();
}

class _GoalFormScreenState extends State<GoalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late SportType? _sport = widget.goal?.sportType;
  late GoalMetric _metric = widget.goal?.metric ?? GoalMetric.distance;
  late GoalPeriod _period = widget.goal?.period ?? GoalPeriod.weekly;
  late final _targetCtrl = TextEditingController(text: widget.goal == null ? '' : widget.goal!.metric.format(widget.goal!.target));
  late String _lastSuggestion = _suggestedTitle();
  late final _titleCtrl = TextEditingController(text: widget.goal?.title ?? _lastSuggestion);
  bool _saving = false;

  bool get _editing => widget.goal != null;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  String _suggestedTitle() {
    final sport = _sport?.label ?? 'Olahraga';
    final per = _period == GoalPeriod.weekly ? 'per minggu' : 'per bulan';
    final target = Validators.parseNumber(_targetCtrl.text);
    final amount = target == null ? _metric.label.toLowerCase() : '${_metric.format(target)} ${_metric.unit}';
    return '$sport $amount $per';
  }

  // Judul ikut berubah selama pengguna belum menulis judul sendiri
  void _update(VoidCallback change) {
    final wasSuggested = _titleCtrl.text == _lastSuggestion;
    setState(change);
    _lastSuggestion = _suggestedTitle();
    if (wasSuggested) _titleCtrl.text = _lastSuggestion;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final goal = Goal(
      id: widget.goal?.id ?? 'goal-${DateTime.now().millisecondsSinceEpoch}',
      title: _titleCtrl.text.trim(),
      sportTypeId: _sport?.id,
      metric: _metric,
      period: _period,
      target: Validators.parseNumber(_targetCtrl.text)!,
      createdAt: widget.goal?.createdAt ?? DateTime.now(),
    );
    final store = GoalStore.instance;
    await (_editing ? store.update(goal) : store.add(goal));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(_editing ? "Target diperbarui" : "Target ditambahkan")));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_editing ? "Edit Target" : "Target Baru")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text("Kategori Olahraga", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text("Semua"),
                  selected: _sport == null,
                  onSelected: (_) => _update(() => _sport = null),
                ),
                for (final type in SportType.values)
                  ChoiceChip(
                    avatar: Icon(type.icon, size: 18),
                    label: Text(type.label),
                    selected: type == _sport,
                    onSelected: (_) => _update(() => _sport = type),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            const Text("Ukuran Target", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final m in GoalMetric.values)
                  ChoiceChip(
                    avatar: Icon(m.icon, size: 18),
                    label: Text(m.label),
                    selected: m == _metric,
                    onSelected: (_) => _update(() => _metric = m),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            const Text("Periode", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SegmentedButton<GoalPeriod>(
              segments: [
                for (final p in GoalPeriod.values) ButtonSegment(value: p, label: Text(p.label)),
              ],
              selected: {_period},
              onSelectionChanged: (s) => _update(() => _period = s.first),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _targetCtrl,
              keyboardType: TextInputType.numberWithOptions(decimal: _metric == GoalMetric.distance),
              decoration: InputDecoration(labelText: "Target", suffixText: _metric.unit),
              // Judul saran ikut diperbarui saat angka target diketik
              onChanged: (_) => _update(() {}),
              validator: (v) {
                final error = Validators.positiveNumber(label: "Target", max: _metric.maxTarget, unit: _metric.unit)(v);
                if (error != null) return error;
                final n = Validators.parseNumber(v)!;
                if (_metric != GoalMetric.distance && n != n.roundToDouble()) return "Target harus bilangan bulat";
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: "Nama Target"),
              validator: Validators.title(label: "Nama target", max: 40),
            ),
            const SizedBox(height: 32),
            _saving
                ? const Center(child: CircularProgressIndicator())
                : PrimaryButton(
                    text: _editing ? "Simpan Perubahan" : "Simpan Target",
                    icon: Icons.check,
                    onPressed: _save,
                  ),
          ],
        ),
      ),
    );
  }
}
