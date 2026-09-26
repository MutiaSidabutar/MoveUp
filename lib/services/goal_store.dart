import 'package:moveup/models/goal.dart';
import 'package:moveup/services/json_list_store.dart';
import 'package:moveup/services/reminder_store.dart';
import 'package:moveup/services/sample_data.dart';

class GoalStore extends JsonListStore<Goal> {
  GoalStore._() : super('goals');

  static final instance = GoalStore._();

  List<Goal> get goals => items;

  @override
  Comparator<Goal> get order => (a, b) => b.createdAt.compareTo(a.createdAt);

  @override
  String idOf(Goal item) => item.id;

  @override
  Map<String, dynamic> encode(Goal item) => item.toJson();

  @override
  Goal decode(Map<String, dynamic> json) => Goal.fromJson(json);

  @override
  List<Goal> seed() => SampleData.goals(DateTime.now());

  // Pengingat yang terhubung tetap ada, hanya relasinya ke target dilepas
  @override
  Future<void> remove(String id) async {
    await super.remove(id);
    await ReminderStore.instance.detachGoal(id);
  }
}
