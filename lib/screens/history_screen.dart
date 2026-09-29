import 'package:flutter/material.dart';
import 'package:moveup/theme.dart';
import 'package:moveup/models/activity.dart';
import 'package:moveup/screens/activity_detail_screen.dart';
import 'package:moveup/screens/add_activity_screen.dart';
import 'package:moveup/services/activity_store.dart';
import 'package:moveup/utils/format.dart';
import 'package:moveup/widgets.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // null berarti semua jenis olahraga
  SportType? _filter;

  @override
  Widget build(BuildContext context) {
    final store = ActivityStore.instance;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("RIWAYAT", style: AppTheme.display(30, letterSpacing: 1.5)),
                PopupMenuButton<String>(
                  icon: Icon(_filter == null ? Icons.filter_alt_outlined : Icons.filter_alt),
                  tooltip: "Filter olahraga",
                  onSelected: (value) => setState(() => _filter = value == 'all' ? null : SportType.fromName(value)),
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'all', child: Text("Semua")),
                    for (final type in SportType.values)
                      PopupMenuItem(value: type.name, child: Text(type.label)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: store,
              builder: (context, _) {
                final activities =
                    store.activities.where((a) => _filter == null || a.type == _filter).toList();
                if (activities.isEmpty) {
                  // Kosong karena filter berbeda dengan kosong karena belum pernah mencatat
                  if (_filter != null) {
                    return EmptyStateWidget(
                      title: "Tidak ada ${_filter!.label.toLowerCase()}",
                      message: "Belum ada aktivitas dengan jenis ini.",
                      icon: Icons.filter_alt_off_outlined,
                    );
                  }
                  return EmptyStateWidget(
                    title: "Belum ada aktivitas",
                    message: "Aktivitas yang direkam atau dicatat manual akan muncul di sini.",
                    icon: Icons.history,
                    actionLabel: "Catat Manual",
                    onAction: () =>
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AddActivityScreen())),
                  );
                }

                final children = <Widget>[];
                String? lastMonth;
                for (final a in activities) {
                  final month = "${monthNames[a.startTime.month - 1]} ${a.startTime.year}";
                  if (month != lastMonth) {
                    children.add(Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(month, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ));
                    lastMonth = month;
                  }
                  children.add(ActivityCard(
                    title: a.title,
                    subtitle: formatRelativeDateTime(a.startTime),
                    primaryValue: "${formatKm(a.distanceMeters)} km",
                    secondaryValue: formatDurationShort(a.movingSeconds),
                    icon: a.type.icon,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ActivityDetailScreen(activity: a)),
                    ),
                  ));
                }
                return ListView(padding: const EdgeInsets.symmetric(horizontal: 20), children: children);
              },
            ),
          ),
        ],
      ),
    );
  }
}
