import 'package:flutter_test/flutter_test.dart';
import 'package:moveup/models/activity.dart';
import 'package:moveup/utils/format.dart';

// Titik lurus ke utara tiap 0,001° lintang (~111,19 m), 30 detik per titik
List<TrackPoint> _straightLine(int count, {int segment = 0, double startLat = 0, double startT = 0}) => [
      for (var i = 0; i < count; i++) TrackPoint(startLat + i * 0.001, 0, startT + i * 30, segment),
    ];

Activity _activity(List<TrackPoint> points, {int seconds = 720, double meters = 2668.7}) => Activity(
      id: '1',
      type: SportType.run,
      title: 'Lari Pagi',
      startTime: DateTime(2026, 9, 25, 6, 30),
      movingSeconds: seconds,
      distanceMeters: meters,
      points: points,
    );

void main() {
  test('split per km dihitung dari titik GPS', () {
    final splits = _activity(_straightLine(25)).splits;

    expect(splits.length, 3);
    expect(splits[0].distanceMeters, 1000);
    expect(splits[0].paceSecPerKm, closeTo(269.8, 0.5));
    expect(splits[1].paceSecPerKm, closeTo(269.8, 0.5));
    expect(splits[2].distanceMeters, closeTo(668.7, 1));
  });

  test('perpindahan saat jeda (antar segmen) tidak dihitung', () {
    final points = [
      ..._straightLine(10),
      // Lanjut 5 km lebih jauh setelah jeda: celah ini tidak boleh masuk split
      ..._straightLine(10, segment: 1, startLat: 0.05, startT: 300),
    ];
    final splits = _activity(points).splits;
    final total = splits.fold<double>(0, (s, x) => s + x.distanceMeters);

    expect(total, closeTo(18 * 111.19, 2));
  });

  test('simpan dan muat ulang JSON tidak mengubah data', () {
    final original = _activity(_straightLine(5));
    final restored = Activity.fromJson(original.toJson());

    expect(restored.title, original.title);
    expect(restored.type, original.type);
    expect(restored.startTime, original.startTime);
    expect(restored.points.length, 5);
    expect(restored.points.last.t, 120);
  });

  test('MET mengikuti kecepatan dan jenis olahraga', () {
    expect(SportType.run.metAt(9.7), 9.8);
    // Di antara titik tabel: 8,0 km/j → 8,3 dan 8,4 km/j → 9,0
    expect(SportType.run.metAt(8.2), closeTo(8.65, 0.01));
    expect(SportType.run.metAt(30), 19.0);
    expect(SportType.walk.metAt(4.8), 3.5);
    expect(SportType.ride.metAt(10), 4.0);
    expect(SportType.hike.metAt(5), 6.0);
    // Kecepatan tidak diketahui (input manual tanpa jarak) memakai nilai default
    expect(SportType.run.metAt(0), SportType.run.defaultMet);
  });

  test('kalori lari cepat lebih besar daripada lari santai dengan durasi sama', () {
    // 1 jam, berat 65 kg
    final slow = SportType.run.caloriesFor(meters: 8000, seconds: 3600, weightKg: 65);
    final fast = SportType.run.caloriesFor(meters: 12900, seconds: 3600, weightKg: 65);

    expect(slow, (8.3 * 65).round());
    expect(fast, (11.8 * 65).round());
    expect(SportType.walk.caloriesFor(meters: 4800, seconds: 3600, weightKg: 65), (3.5 * 65).round());
    expect(SportType.run.caloriesFor(meters: 5000, seconds: 0, weightKg: 65), 0);
  });

  test('format pace, durasi, dan judul otomatis', () {
    expect(formatPace(312), '5:12');
    expect(formatDuration(3909), '1:05:09');
    expect(formatDuration(1935), '32:15');
    expect(formatKm(5230), '5,23');
    expect(defaultTitle(SportType.run, DateTime(2026, 1, 1, 6)), 'Lari Pagi');
    expect(defaultTitle(SportType.ride, DateTime(2026, 1, 1, 17)), 'Bersepeda Sore');
  });
}
