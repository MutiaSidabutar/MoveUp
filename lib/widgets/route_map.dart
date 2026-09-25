import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:moveup/models/activity.dart';

const kOsmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
const kTileUserAgent = 'com.example.moveup';

// Peta dibuat abu-abu agar senada dengan tema monokrom; di tema gelap warnanya dibalik
const _grayscale = ColorFilter.matrix([
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0, 0, 0, 1, 0,
]);
const _darkGrayscale = ColorFilter.matrix([
  -0.18, -0.61, -0.06, 0, 215,
  -0.18, -0.61, -0.06, 0, 215,
  -0.18, -0.61, -0.06, 0, 215,
  0, 0, 0, 1, 0,
]);

TileLayer osmTileLayer(BuildContext context) {
  final filter = Theme.of(context).brightness == Brightness.dark ? _darkGrayscale : _grayscale;
  return TileLayer(
    urlTemplate: kOsmTileUrl,
    userAgentPackageName: kTileUserAgent,
    tileBuilder: (context, tile, _) => ColorFiltered(colorFilter: filter, child: tile),
  );
}

class OsmAttribution extends StatelessWidget {
  const OsmAttribution({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      color: Colors.white.withValues(alpha: 0.8),
      child: const Text('© OpenStreetMap', style: TextStyle(fontSize: 10, color: Colors.black)),
    );
  }
}

// Peta rute aktivitas yang sudah direkam, otomatis di-zoom ke seluruh rute
class RouteMap extends StatelessWidget {
  const RouteMap({super.key, required this.points, this.interactive = false});

  final List<TrackPoint> points;
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final coords = points.map((p) => LatLng(p.lat, p.lng)).toList();

    final segments = <List<LatLng>>[];
    for (var i = 0; i < points.length; i++) {
      if (i == 0 || points[i].segment != points[i - 1].segment) segments.add([]);
      segments.last.add(coords[i]);
    }

    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: coords.first,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            initialZoom: 16,
            initialCameraFit: coords.length > 1
                ? CameraFit.coordinates(coordinates: coords, padding: const EdgeInsets.all(32), maxZoom: 17)
                : null,
            interactionOptions: InteractionOptions(
              flags: interactive ? InteractiveFlag.all & ~InteractiveFlag.rotate : InteractiveFlag.none,
            ),
          ),
          children: [
            osmTileLayer(context),
            PolylineLayer(
              polylines: [
                for (final seg in segments)
                  Polyline(points: seg, color: scheme.primary, strokeWidth: 4, borderColor: scheme.onPrimary, borderStrokeWidth: 1.5),
              ],
            ),
            MarkerLayer(
              markers: [
                Marker(point: coords.first, width: 16, height: 16, child: _Dot(color: scheme.onPrimary, border: scheme.primary)),
                if (coords.length > 1)
                  Marker(point: coords.last, width: 16, height: 16, child: _Dot(color: scheme.primary, border: scheme.onPrimary)),
              ],
            ),
          ],
        ),
        const Positioned(right: 4, bottom: 4, child: OsmAttribution()),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color, required this.border});

  final Color color;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: border, width: 3),
      ),
    );
  }
}
