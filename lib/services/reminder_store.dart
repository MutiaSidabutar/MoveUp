import 'package:moveup/models/reminder.dart';
import 'package:moveup/services/json_list_store.dart';
import 'package:moveup/services/sample_data.dart';

class ReminderStore extends JsonListStore<Reminder> {
  ReminderStore._() : super('reminders');

  static final instance = ReminderStore._();

  List<Reminder> get reminders => items;

  // Diurutkan menurut jam supaya terbaca seperti jadwal harian
  @override
  Comparator<Reminder> get order => (a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute);

  @override
  String idOf(Reminder item) => item.id;

  @override
  Map<String, dynamic> encode(Reminder item) => item.toJson();

  @override
  Reminder decode(Map<String, dynamic> json) => Reminder.fromJson(json);

  @override
  List<Reminder> seed() => SampleData.reminders();

  List<Reminder> forGoal(String goalId) => reminders.where((r) => r.goalId == goalId).toList();

  Future<void> detachGoal(String goalId) async {
    final linked = forGoal(goalId);
    if (linked.isEmpty) return;
    await replaceAll([
      for (final r in reminders) r.goalId == goalId ? r.copyWith(goalId: () => null) : r,
    ]);
  }
}
